A vagrant configuration for running microsites.

## Prerequisites

1. vagrant
1. ansible
1. unison

## Installing a microsites vagrant host

1. Add microsites.local to your `hosts` file as  `10.255.21.10`
1. `git clone https://github.com/mlibrary/microsites-vagrant`
1. `cd microsites-vagrant`
1. `git clone https://github.com/mlibrary/microsites`
1. `vagrant up`
1. `./unison-init`
1. `unison up`

## Starting with microsites

1. Copy database credentials from `credentials/mysql/microsites` to `microsites/wp-config.php`
1. Install a fresh database, or load a database
1. Visit at http://microsites.local/
