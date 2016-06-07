module ApplicationHelper
  def button_toggle(*records, state, field)
    record = records.last
    title = state ? 'On' : 'Off'
    is_current_state = record.public_send(field) == state

    classes = [
      'btn-toggle',
      is_current_state ? 'btn-toggle--active' : 'btn-toggle--inactive',
      state ? 'btn-toggle--on' : 'btn-toggle--off',
      policy(record).update? ? nil : 'disabled',
      "#{record.class.name.underscore}--update-link",
    ].compact.join(' ')

    link_to title, 
      [*records, field => !record.public_send(field)], 
      remote: true, 
      method: :patch,
      class: classes,
      'data-disable-with': nil
  end

  def button_toggles(*records, field: :enabled)
    content_tag(:div, nil, class: 'btn-toggles') do
      [
        button_toggle(*records, false, field),
        button_toggle(*records, true, field)
      ].join.html_safe
    end
  end

  def breadcrumb(title, thing)
    tag = 
      content_tag(:li, nil) do
        link_to(title, thing, class: 'nav-link')
      end
    content_for :breadcrumbs, tag
  end

  # a link_to that join+compacts the class option (if any)
  def link_to(*args, &block)
    options = args.extract_options!
    if classes = options[:class] && classes.kind_of?(Array)
      options[:class] = classes.compact.join(' ')
    end
    super(*args, options, &block)
  end

  def link_to_user(user, &block)
    if block_given?
      link_to [current_organisation, user], &block
    else 
      link_to "@#{user.login}", [current_organisation, user]
    end
  end

  def github_team_url
    "https://github.com/orgs/#{current_organisation.name}/teams"
  end

  def github_members_url
    "https://github.com/orgs/#{current_organisation.name}/people"
  end

  def github_link(object, message:nil, target:nil)
    case object
    when User, Organisation
      url = "https://github.com/#{object.login}"
    when Team
      url = "https://github.com/orgs/#{object.organisation.login}/teams/#{object.name.downcase.gsub(' ', '-')}"
    when PullRequest
      url = "https://github.com/#{object.repository.owner.login}/#{object.repository.name}/pull/#{object.github_number}"
    else
      url = object.to_s
      target ||= '_blank'
    end
    message ||= [
      'View on Github ',
      content_tag(:span, nil, class: 'octicon octicon-link-external')
    ].join.html_safe
    target ||= "_#{object.class.name.underscore}_#{object.id}"
    link_to message, url, target: target
  end

  def flash_colour(key)
    case key.to_s
    when 'success' then 'success'
    when 'alert' then 'danger'
    when 'notice' then 'info'
    else 'warning'
    end
  end

  def chord_graph_data_attrs(resource)
    case resource
    when Team
      {
        'data-series-url': organisation_team_metrics_path(resource.organisation, resource, format:'csv'),
        'data-matrix-url': organisation_team_metrics_path(resource.organisation, resource, format:'json')
      } 
    when Organisation
      {
        'data-series-url': organisation_chord_path(resource, format:'csv'),
        'data-matrix-url': organisation_chord_path(resource, format:'json')
      } 
    end
  end

  def pull_request_label_color(pr)
    case pr.status.to_s
    when 'open' then 'success'
    when 'closed' then 'default'
    when 'merged' then 'default'
    else raise 'unknown PR status'
    end
  end

  def phrase(&block)
    @phrases ||= []
    @phrases << capture(&block).html_safe
  end

  def make_sentence
    @phrases = []
    yield
    sentence = @phrases.map(&:strip).to_sentence
    sentence.html_safe + '.'
  end
end

