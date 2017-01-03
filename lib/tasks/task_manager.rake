require 'rake'

namespace :task_manager do

  task :start => :environment do
    TaskManager.start
  end
  
end