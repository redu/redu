Delayed::Worker.delay_jobs = !(Rails.env.test? || Rails.env.development?)
# Delayed::Worker.delay_jobs = true

