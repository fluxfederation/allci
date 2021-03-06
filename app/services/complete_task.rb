class CompleteTask < StoreTaskOutput
  def initialize(task_id:, runner_name:, output:, exit_code:, failed:)
    super task_id: task_id, runner_name: runner_name, output: output
    @exit_code = exit_code
    @failed = failed
  end

  def call
    BuildTask.transaction do
      store_output
      store_exit_codes
      update_task_run_state
      update_task_state
      update_build_state
      task
    end
  end

protected
  def store_exit_codes
    @exit_code.each do |container_name, exit_code|
      output_for(container_name).exit_code = exit_code
    end
  end

  def update_task_run_state
    task_run.finished_at = Time.now
    task_run.state = @failed ? "failed" : "success"
    task_run.save!
  end

  def update_task_state
    if !task.complete?
      if @failed
        task.state = "failed"
      elsif task.build_task_runs.running.present?
        task.state = "running"
      else
        task.state = "success"
      end
    end
    task.save!
  end

  def update_build_state
    if task.configuration_build.not_complete? && !task.configuration_build.build_tasks.not_complete.exists? && task.configuration_build.lock!.not_complete?
      build_failed = task.configuration_build.build_tasks.failed.exists?
      task.configuration_build.update!(state: build_failed ? "failed" : "success")
    end
  end
end
