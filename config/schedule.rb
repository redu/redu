# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

log_dir = Dir.pwd + "/log/"
log_dir += "../../current/" if @environment.eql?('production')
set :output, log_dir + "whenever.log"

unless @environment.eql?('production')
  every 1.minute do
    runner "PackageInvoice.refresh_states!"
    runner "LicensedInvoice.refresh_states!"
  end
else
  every 1.day, :at => '21 pm' do
    runner "PackageInvoice.refresh_states!"
    runner "LicensedInvoice.refresh_states!"
  end
end

