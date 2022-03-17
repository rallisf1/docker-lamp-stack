FROM adhocore/phpfpm:7.4
# disable PHP extensions per https://github.com/adhocore/docker-phpfpm#php74
RUN docker-php-ext-disable calendar event grpc igbinary lzf msgpack pgsql psr ssh2 sysvmsg tidy yaf ast phalcon rdkafka hrtime mysqlnd pcov pdo_pgsql swoole ev mongodb swoole_async tideways_xhprof xdebug zephir_parser

COPY ./ffmpeg/ffmpeg /usr/local/sbin/ffmpeg
COPY ./ffmpeg/ffprobe /usr/local/sbin/ffprobe

RUN chmod +x /usr/local/sbin/ffmpeg /usr/local/sbin/ffprobe