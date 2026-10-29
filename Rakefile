# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

require 'solr_wrapper/rake_task' unless Rails.env.production?


desc 'Start the Prometheus exporter (for persistent processes like resque workers)'
task start_prometheus: :environment do
  Yabeda::Prometheus::Exporter.start_metrics_server!
end

task('resque:work').enhance([:start_prometheus])
