# -*- encoding : utf-8 -*-
Delayed::Worker.delay_jobs = true
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_run_time = 60.minutes
Delayed::Worker.default_priority = 10
# Delayed::Worker.delay_jobs = true
