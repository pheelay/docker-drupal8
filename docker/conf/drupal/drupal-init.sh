#!/bin/bash
#
# drupal-init.sh
#
# Create a new Drupal site from source or update existing site.
#
# Author: Phil Franks 
# GitHub: https://github.com/pheelay/docker-drupal8
# Date:   2018-10-13
#

## Default values
SITE_NAME=${SITE_NAME:-Default Site Name}
MYSQL_HOSTNAME=${MYSQL_HOSTNAME:-mysql}
MYSQL_USERNAME=${MYSQL_USERNAME:-root}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-test}
MYSQL_DATABASE=${MYSQL_DATABASE:-drupal}

## 
echo "Running $0"

## Missing composer.json => new project
if [ ! -f composer.json ]
then
  ## Install latest Drupal using composer. The directory must be empty.
  rm -f README.md
  composer create-project drupal/drupal .
  
  ## Install drush cli (https://www.drush.org/)
  composer require        drush/drush

## Update to latest available version
else
  composer update drupal/core --with-dependencies
fi

## Missing Drupal settings.php => Install a site
if [ ! -r sites/default/settings.php ] 
then

  ## Wait for mysql
  while true
  do
    mysql -u${MYSQL_USERNAME} -p${MYSQL_PASSWORD} -h${MYSQL_HOSTNAME} -s -e 'SHOW DATABASES' |grep -q -e ${MYSQL_DATABASE} > /dev/null 2>&1
    [ $? -eq 0 ] && break
    
    echo "$0 - MySQL not ready. Waiting ..."
    sleep 3
  done

  ## Initial installation, using drush
  drush site:install \
    --db-url="mysql://${MYSQL_USERNAME}:${MYSQL_PASSWORD}@${MYSQL_HOSTNAME}/${MYSQL_DATABASE}" -y \
    --site-name="${SITE_NAME}"
    
  ## Set permissions on files folder for user uploadable content
  chown -R www-data:www-data sites/default/files/
  
  ## Allow Drupal manage settings.php (Non-production only)
  chown www-data:www-data sites/default/settings.php

fi

## Run any outstanding database updates & rebuild cache
drush -y updatedb
drush cache-rebuild
  
## Show status of the site on startup
drush status
