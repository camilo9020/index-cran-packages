require 'rufus-scheduler'
require './lib/index_cran_packages.rb'
require 'dotenv'

Dotenv.load

scheduler = Rufus::Scheduler.new

scheduler.cron '0 6 * * *' do
  index_cran_packages = IndexCranPackages.new(ENV['CRAN_SERVER_URL'], ENV['FILE_NAME_PATH'])
  index_cran_packages.execute
end

print 'Scheduler programmed to run every day at 6am'

# Start the scheduler
scheduler.join
print "Scheduler started at #{DateTime.now}"