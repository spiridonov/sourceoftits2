namespace :resque do

  task :setup => :environment do
    require 'resque'
    require 'resque_scheduler'
    require 'resque/scheduler'

    Resque.schedule = YAML.load_file("#{Rails.root}/config/resque_schedule.yml")
    Dir["#{Rails.root}/app/jobs/*.rb"].each { |file| require file }
  end

end
