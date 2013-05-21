# -*- encoding : utf-8 -*-
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

set :output, "#{@path}/log/whenever.log"

unless @environment.eql?('production')
  every 30.minute do
    runner "PackageInvoice.refresh_states!"
    runner "LicensedInvoice.refresh_states!"
  end
else
  # 1am horário local
  every 1.day, :at => '9pm' do
    runner "PackageInvoice.refresh_states!"
    runner "LicensedInvoice.refresh_states!"
  end

  # 4am horário local
  every :day, :at => '0am' do
    runner "Subject.destroy_subjects_unfinalized"
  end

  # 3am horário local
  every :day, :at => '11pm' do
    command "s3cmd sync --delete-removed --exclude=thumb_*/*" \
      " --include=ckeditor/*" \
      " s3://redu_uploads s3://redu-backup-static-files/redu_uploads/"
    command "s3cmd sync --delete-removed" \
      " s3://redu-videos s3://redu-backup-static-files/redu-videos/"
    command "s3cmd sync --delete-removed" \
      " s3://redu_files s3://redu-backup-static-files/redu_files/"
  end
end

