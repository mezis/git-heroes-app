require 'csv'

ActionController::Renderers.add :csv do |obj, options|
  str = obj.map { |x|
    [x].flatten
  }.map(&:to_csv).join
  send_data str, type: Mime::CSV
end
