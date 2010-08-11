#!/bin/sh

CURRENT_PATH = "/u/apps/redu/current"

cd ${CURRENT_PATH} && /home/ubuntu/.gem/ruby/1.8/bin/rake RAILS_ENV=production s3:backup:db >/dev/null 2>&1