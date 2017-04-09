A vagrant configuration for running microsites locally. Filesystem syncing via unison is expected.

## Prerequisites

1. vagrant
1. ansible
1. unison

## Installing a microsites vagrant host

1. Add microsites.local to your `hosts` file as  `10.255.21.10`
1. `git clone https://github.com/mlibrary/microsites-vagrant`
1. `cd microsites-vagrant`
1. `vagrant up`

## Starting with microsites

1. Copy database credentials from `credentials/mysql/microsites` to `microsites/wp-config.php`
1. Install a fresh database, or load a database with `bin/db import`
1. Visit at http://microsites.local/

## Importing and exporting a database from box

Use `db import [db-file]` and `db export [db-file]`  to import and export a file respectively.

If a file name is not provided. The default is `$USER.microsites.sql.gz`.
