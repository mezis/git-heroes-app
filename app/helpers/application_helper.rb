module ApplicationHelper
  def button_toggle(*records, state)
    record = records.last
    title = state ? 'On' : 'Off'
    is_current_state = record.enabled? == state
    colour = is_current_state ?
      state ?
      'btn-success' :
      'btn-danger' :
      'btn-secondary'
    link_to title, 
      [*records, enabled: !record.enabled?], 
      remote: true, 
      method: :patch,
      class: "btn btn-primary btn-small #{colour} #{record.class.name.underscore}--update-link",
      'data-disable-with': '...'
  end

  def button_toggles(*records)
    content_tag(:div, nil, class: 'btn-group btn-group-sm') do
      [
        button_toggle(*records, false),
        button_toggle(*records, true)
      ].join.html_safe
    end
  end

  def breadcrumbs(things = {})
    things = { 'Git Heroes' => root_path }.merge(things)
    content_tag(:ol, class:'breadcrumb') do
      buffer = []
      things.to_a.reverse.each_with_index do |(title,thing),idx|
        buffer << content_tag(:li, nil, class:(idx == 0 ? 'active' : nil)) do
          link_to(title, thing)
        end
      end
      buffer.reverse.join.html_safe
    end
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
    message ||= 'View on Github →'
    target ||= "_#{object.class.name.underscore}_#{object.id}"
    link_to message, url, target: target
  end
end

