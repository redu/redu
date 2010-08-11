#!/bin/sh

CURRENT_PATH="/u/apps/redu/current"
RAKE="/home/ubuntu/.gem/ruby/1.8/bin/rake"

cd ${CURRENT_PATH} && ${RAKE} RAILS_ENV=production s3:backup:db >/dev/null 2>&1
