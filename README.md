# Intro
This repo was created to help me transition some projects from classic web hosting panels like cPanel/Plesk to their own VPS server using docker. It is not tuned for hosting multiple domains, although it includes a proxy and auto-ssl, and there is no dashboard/cli to manage the config files. Feel free to fork and create pull requests.

## What's included

- MariaDB latest version [official]
- PHP FPM 7.4, instructions how to switch version further below [prepackaged by [adhocore](https://github.com/adhocore/docker-phpfpm)]
- FFmpeg [precompiled by [johnvansickle](https://johnvansickle.com/ffmpeg/)]
- Apache latest version [official]
- Redis latest version [official]
- Nginx Proxy Manager for static file caching and auto-ssl [official]

## Prequisites
- x86_64 Linux server, preferably Ubuntu LTS (although it can work on other platforms with modifications)
- [Docker](https://docs.docker.com/engine/install/) and [docker-compose](https://docs.docker.com/compose/install/) installed
- git package installed _e.g. apt install git_

## How to use
1. `git clone https://github.com/rallisf1/docker-lamp-stack.git`
2. edit mysql root password in `docker-compose.yml`
3. move your app/website files inside public_html, if your app is served through a public folder update `httpd.conf` accordingly
4. run `docker-compose up -d`
5. run `chmod +x fix_perms.sh && ./fix_perms.sh` in order to fix the volume permissions.
If you need to expose more logs/config files note that php runs as user:group `81:81` and mysql as `999:999`
6. open `http://your-ip:81` and configure nginx proxy manager as per [documentation](https://nginxproxymanager.com/setup/#initial-run)

## Configuration and defaults
- `mariadb.cnf` is the default mariadb config which you can override, I have only enabled slow query logs
- `httpd.conf` is the default apache2 configuration tuned with mpm-event and configured to use the included php
- `php/php.ini` is the default php.ini for php 7.4 (make sure to update it if you switch versions) but with memory/request limits greatly increased
- `php/www.conf` is the default php-fpm configuration tuned for medium traffic production

## Logs
Inside `logs` you will find slow query logs as well as php errors, you can expose more logs by adding the corresponding volumes in `docker-compose.yml`.

## Guides
- How to manage my docker containers?
Frankly, since I use multiple servers, I use Portainer to manage all of them through its agent. For single server setup though I think it's redundant and docker cli should cover everything.
- How do I change the PHP version?
In `php/DockerFile` change the `from` version according to [documentation](https://github.com/adhocore/docker-phpfpm#usage). You can also add/remove PHP extensions in the same place.
- I have made a change to the Dockerfile/docker-compose.yml configuration, how do I rebuild without losing data?
`docker-compose up -d --force-recreate`
- How do I add another user to the database?
First check the subnet your containers are using `docker network inspect mylampnetwork` , should be something like 172.17.0.0/16. Then log in to the mariadb container with `docker exec mydbcontainer -it bash` and run the following commands changing the database, username, ip and password accordingly:
```
mysql -uroot -pMARIADB_ROOT_PASSWORD
# if you already have a database skip the next command
CREATE DATABASE mydb;
GRANT ALL PRIVILEGES ON mydb.* TO 'NONROOTUSER'@'172.17.0.%' IDENTIFIED BY 'SUPER_STRONG_PASSWORD';
FLUSH PRIVILEGES;
exit;
exit
```
- How to import my database dump?
Place your .sql file in the same directory you'll be running this command and run `docker exec -i mydbcontainer sh -c 'exec mysql -uroot -pMARIADB_ROOT_PASSWORD mydb' < mydump.sql`
- How to export a database dump (e.g. for backup) ?
`docker exec mydbcontainer sh -c 'exec mysqldump -uroot -pMARIADB_ROOT_PASSWORD --single-transaction --routines --triggers --lock-tables mydb' > ./mydb-backup.sql`
- How do I see how many resources my containers consume?
`docker stats`

## FAQ

- Is this setup production ready?
Frankly, it can be improved but for my use and purpose it is and I use it in production.
- How do you secure this setup?
Host-wise I use CSF firewall and fail2ban. I also monitor my servers with [netdata.cloud](https://netdata.cloud). The php app/website is partially secured through nginx's modsecurity. If you need more protection for your app I advice you to use Cloudflare (or any other cloud-based) CDN & WAF.
- How do you do backups?
Currently backups are handled by a simple bash script running on cron. The script just rsycns public_html and creates a db dump which also copies with scp to a remote storage server. I'm looking into borg though.
- Can you add X feature for me?
Not really, I will try to help on my spare time but honestly I'm just sharing what I learned.
