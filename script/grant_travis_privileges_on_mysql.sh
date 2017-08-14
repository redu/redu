#!/usr/bin/env bash
set -x
set -e
sudo service mysql stop || echo "mysql not stopped"
sudo  mysqld_safe &
sleep 4
sudo mysql -e "GRANT ALL PRIVILEGES ON redu_test.* to 'travis'@'%';"
sudo service mysql restart || echo "mysql failed to restart"
sleep 4
