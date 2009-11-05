#!/bin/bash
source ~/.bash_profile
cd /var/www/apps/yogatoday/current
export RAILS_ENV=production
rake --trace subscriptions:charge_due_accounts >> /var/www/apps/yogatoday/current/log/charge_due_accts.log 2>&1
