class BuildTask < ApplicationRecord
  belongs_to :configuration_build
  has_many :build_task_runs
  has_many :build_task_run_outputs, through: :build_task_runs

  scope :for_stage, -> (stage) { where(stage: stage) }
  scope :for_build, -> (build_id) { where(configuration_build_id: build_id) }

  STATES = %w(available running failed success)
  STATES.each { |state| scope state, -> { where(state: state) } }
  scope :not_complete, -> { where(state: %w(available running)) }
  validates_inclusion_of :state, in: STATES

  def as_json(options = nil)
    {
      task_id: id,
      build_id: configuration_build.id,
      stage: stage,
      task: task,
      configuration_name: configuration_build.configuration.name,
      components: configuration_build.configuration.components.order(:container_name).each_with_object({}) { |component, results|
        results[component.container_name] = {
          repository_name: component.repository.name,
          repository_uri: component.repository.uri,
          branch: component.branch,
          dockerfile: component.dockerfile,
          image_name: configuration_build.image_name_for(component),
          runtime_env: component.component_variables.select(&:runtime_env?).each_with_object({}) { |cv, results| results[cv.name] = cv.value },
          build_args: component.component_variables.select(&:build_arg?).each_with_object({}) { |cv, results| results[cv.name] = cv.value },
          tmpfs: component.tmpfs,
        }
      }
    }
  end

  def complete?
    %w(failed success).include?(state)
  end

  def not_complete?
    %w(available running).include?(state)
  end
end
