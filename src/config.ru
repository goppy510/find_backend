# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

if ENV['RAILS_ENV'] == 'production'
  require 'unicorn/worker_killer'
  lower_limit_megabyte = 350 * (1024**2)
  upper_limit_megabyte = 450 * (1024**2)
  use Unicorn::WorkerKiller::Oom, [ lower_limit_megabyte, upper_limit_megabyte ]
end

require ::File.expand_path('../config/environment', __FILE__)
run Rails.application
Rails.application.load_server
