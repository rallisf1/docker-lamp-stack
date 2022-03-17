#!/bin/bash
chown -R 82:82 ./public_html
chown 82:82 ./logs/php-errors.log
chown 999:999 ./logs/mariadb-slow.log