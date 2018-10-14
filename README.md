# Docker developer stack for Drupal 8

## Goals
- Fully functional site in less than 5 minutes
- Install & maintain latest version using composer
- drush command-line utility
- Working email system
- Varnish frontend cache
- Ready to deploy to a swarm/cloud

## Requirements
* Docker
* Docker Compose

## Run locally
Clone the repository and start docker:

    $ git clone git@github.com:pheelay/docker-drupal8.git
    $ cd docker-drupal8
    $ docker-compose up

Docker will pull & build the containers. Composer, drush and a built-in script will bootstrap a Drupal 8 site.

Once bootstrapping is complete, you can access the site in your browser:

* http://localhost/

## To access Drupal Admin
``drush`` outputs a randomly generated admin password during the site installation. If you missed it, you can access the site using a one-time login link:

    docker exec -it docker-drupal8_drupal_1 drush uli

You may need to replace ``default`` with ``localhost`` in the URL returned by drush.

## Mailcatcher
Emails sent by the application are captured and redirected to mailcatcher. You can access mailcatcher at:

* http://localhost:1080/

The Contact Us page on Drupal should work out-of-the-box.

## Improvements & Security Considerations
The stack is targeted at developers. Consider the following before deploying to cloud for testing:

- Changing all default passwords and using Docker secrets or other to remove plain-text passwords.
- The customised drupal container drops to an unprivileged user. The other containers currently do not.
- User Namespaces (Docker 1.10) could be used to map the root users to a non-root outside the containers.
- fballiano/varnish is a community image. Consider replacing with a self-maintained container.
- Drupal may need to be configured with Varnish for cache to work correctly.
- Complete the Drupal configuration (tmp/private folders, cron, Trusted Host setting).
- Include some sample content.
- Drupal update is not yet tested.
- Option to mount the Drupal html volume on the host which allows read & write and works on all platforms.

