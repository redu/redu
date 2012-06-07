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

set :output, "log/whenever.log"
bin_folder = @environment.eql?('development') ? "bin" : "ey_bundler_binstubs"

unless @environment.eql?('production')
  every 30.minute do
    runner "PackageInvoice.refresh_states!"
    runner "LicensedInvoice.refresh_states!"

    # Comentado para evitar custos em staging
    #command "cd #{@path} && #{bin_folder}/backup perform -t production_backup" \
      #" -r backup"
  end
else
  every 1.day, :at => '21 pm' do
    runner "PackageInvoice.refresh_states!"
    runner "LicensedInvoice.refresh_states!"
  end

  every 1.day, :at => '23 pm' do
    command "cd #{@path} && #{bin_folder}/backup perform -t production_backup" \
      " -r backup"
  end
end

