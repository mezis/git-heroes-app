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
end

