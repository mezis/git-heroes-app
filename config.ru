# This file is used by Rack-based servers to start the application.

if ENV['FORCE_SSL'] =~ /ON|TRUE|1/i
  require 'rack/ssl'
  use Rack::SSL
end

require ::File.expand_path('../config/environment', __FILE__)
run Rails.application
