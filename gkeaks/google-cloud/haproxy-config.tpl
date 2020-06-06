#!/bin/bash 
set -x

apt-get update 
apt-get install -y haproxy
rm -rfv /etc/haproxy/haproxy.cfg

echo "global
        log /dev/log    local0
        log /dev/log    local1 notice
        chroot /var/lib/haproxy
        stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
        stats timeout 30s
        user haproxy
        group haproxy
        daemon

        # Default SSL material locations
        ca-base /etc/ssl/certs
        crt-base /etc/ssl/private

        # Default ciphers to use on SSL-enabled listening sockets.
        # For more information, see ciphers(1SSL). This list is from:
        #  https://hynek.me/articles/hardening-your-web-servers-ssl-ciphers/
        # An alternative list with additional directives can be obtained from
        #  https://mozilla.github.io/server-side-tls/ssl-config-generator/?server=haproxy
        ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS
        ssl-default-bind-options no-sslv3

defaults REDIS
  mode tcp
  timeout connect  10s
  timeout server  30s
  timeout client  30s
frontend ft_redis
  bind 0.0.0.0:6379 name redis
  default_backend bk_redis
backend bk_redis
  option tcp-check
  tcp-check connect
  tcp-check send PING\r\n
  tcp-check expect string +PONG
  tcp-check send info\ replication\r\n
  tcp-check expect string role:master
  tcp-check send QUIT\r\n
  tcp-check expect string +OK
  server redis1 ${redis_host}:6379 check inter 1s
frontend ft_redis_smapp
  bind 0.0.0.0:6380 name redis_smapp
  default_backend bk_redis_smapp
backend bk_redis_smapp
  option tcp-check
  tcp-check connect
  tcp-check send PING\r\n
  tcp-check expect string +PONG
  tcp-check send info\ replication\r\n
  tcp-check expect string role:master
  tcp-check send QUIT\r\n
  tcp-check expect string +OK
  server redis1 ${redis_host_smapp}:6379 check inter 1s" > /etc/haproxy/haproxy.cfg

service haproxy restart