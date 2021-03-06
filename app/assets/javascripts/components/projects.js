(function() {
  const { Project } = Application.Models

  Application.Components.Projects = {
    oninit: Project.loadList,

    view: function({ attrs }) {
      return m(
        'section.projects',
        m('h3', 'Projects'),
        m(
          'ul',
          Project.visible().map(
            project => m(Application.Components.Project, { key: project.id, project })
          )
        )
      )
    }
  }

  Application.Components.Project = {
    view: function({ attrs }) {
      const { project } = attrs
      const { name, id, labels } = project
      return m(
        'li.project',
        m(
          'a',
          {
            href: `/projects/${id}`,
            oncreate: m.route.link
          },
          m(
            'svg',
            { width: 40, height: 40, viewbox: '0 0 40 40' },
            m('circle', { cx: 20, cy: 20, r: 20 })
          ),
          m(
            '.details',
            m('b', name),
            m('small.labels', labels.map(label => label.name).join(', '))
          ),
          m(
            '.timing',
            m('.duration', duration(165)),
            m('small.last', 'of ' + duration(373))
          )
        )
      )
    }
  }

  function duration(seconds) {
    const hours = Math.floor(seconds / 3600)
    const minutes = Math.floor((seconds % 3600) / 60)
    seconds = seconds % 60
    let result = `${minutes}:${seconds < 10 ? '0' : ''}${seconds}`
    if (hours > 0) result = `${hours}:${minutes < 10 ? '0' : ''}` + result
    return result
  }
})()
