module ApplicationHelper
  def button_toggle(*records, target_state)
    record = records.last
    title = target_state ? 'Off' : 'On'
    button_to title, 
      [*records, enabled:target_state], 
      remote: true, 
      method: :patch,
      class: "#{record.class.name.underscore}--update-link",
      disabled: (target_state == record.enabled?),
      'data-disable-with': 'Updating'
  end

  def button_toggles(*records)
    button_toggle(*records, false) +
    button_toggle(*records, true)
  end

  def breadcrumbs(things = {})
    things = { 'Home' => root_path }.merge(things)
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

