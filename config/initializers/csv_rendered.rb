require 'csv'

ActionController::Renderers.add :csv do |data, options|
  output = ''
  # Array of hashes: take header from keys
  if data.first.kind_of?(Hash)
    output << data.first.keys.to_csv
  end
  data.each do |datum|
    converted = case datum
      when Array then [datum].flatten
      when Hash then datum.values
      else datum
    end
    output << converted.to_csv
  end
  send_data output, type: Mime::CSV
end
