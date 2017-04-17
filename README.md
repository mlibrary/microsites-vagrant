A vagrant configuration for running microsites locally. Filesystem syncing via unison is expected for vagrant. Experimental support for running under docker is available.

# Vagrant

## Prerequisites

1. vagrant
1. vagrant-triggers plugin
1. ansible
1. unison
1. ruby

## Installing a microsites vagrant host

1. Add microsites.local to your `/etc/hosts` file as `10.255.21.10`
1. `git clone https://github.com/mlibrary/microsites-vagrant`
1. `cd microsites-vagrant`
1. `vagrant up`
1. Follow instructions in `vagrant up` output to get an Oauth access token for https://box.it.umich.edu.
1. Create `.config` from `.config.EXAMPLE`.

# Docker

### Prerequisites

1. docker
1. ansible
1. ansible-container
1. ruby

### Instructions

1. Add microsites.local to your `/etc/hosts` file as `10.255.21.10`
1. `git clone https://github.com/mlibrary/microsites-vagrant`
1. `cd microsites-vagrant`
1. `docker network create --subnet 10.255.21.0/24  microsites`
1. `ansible-container build`
1.

        docker \
          run -itd \
         --net microsites \
         --ip 10.255.21.10 \
         --name microsites \
         -v "$PWD/microsites:/microsites" \
         microsites-vagrant-web

7. `git clone https://github.com/mlibrary/microsites`
8. `(cd rb && bundle install --path .bundle)`
9. `bin/box setup`
10. `bin/wp-config`
11. Follow the instructions in `bin/box setup` output to get an Oauth access token for https://box.itd.umich.edu.
12. Create `.config` from `.config.EXAMPLE`.

## Starting with microsites' WordPress

1. Install a fresh database, or load a database with `bin/db import`
1. Visit at http://microsites.local/

## Importing and exporting a database from box

The database import depends on the `.config` file.  Look at `.config.EXAMPLE`.
Use `bin/db import [db-file]` and `bin/db export [db-file]` to import and export a file respectively.

If a file name is not provided. The default is `$USER.microsites.sql.gz`.
