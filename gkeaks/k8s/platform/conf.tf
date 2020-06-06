resource "kubernetes_config_map" "platform-app-conf" {
  metadata {
    name      = "platform-app-conf"
    namespace = var.namespace
  }

  data = {
    "app.config.json" = <<JSON
      {
        "APIBaseURL": "https://api.core.${var.domain}",
        "MQTTBaseURL": "tcp://data-gateway.core.${var.domain}:8883",
        "authServerUrl": "https://auth.${var.domain}",
        "coapBaseURL": "coap://data-gateway.core.${var.domain}:5683",
        "oauthConfig": {
          "clientId": "akenza-core",
          "loginUrl": "https://auth.${var.domain}/oauth/authorize",
          "oidc": false,
          "redirectUri": "https://core.${var.domain}",
          "scope": "core.api core.ui",
          "silentRefreshRedirectUri": "https://core.${var.domain}/assets/silent-refresh.html"
        },
        "uplinkBaseURL": "https://data-gateway.core.${var.domain}/v2",
        "disableSharedIntegrations": true,
        "v3PortalUrl": "https://preview.core.${var.domain}/",
        "tenant": {
          "intercom": true,
          "name": "${var.product_name}",
          "statusPageURL": "${var.status_page}"
        }
      }
      JSON
  }
}

resource "kubernetes_config_map" "platform-nginx-conf" {
  metadata {
    name      = "platform-nginx-conf"
    namespace = var.namespace
  }

  data = {
    "nginx.conf" = <<JSON
        worker_processes 1;
        events {
          worker_connections 1024;
        }
        http {
          charset utf-8;
          default_type application/octet-stream;
          include mime.types;
          sendfile on;
          gzip on;
          gzip_disable "msie6";
          gzip_comp_level 6;
          gzip_min_length 1100;
          gzip_buffers 16 8k;
          gzip_proxied any;
          gunzip on;
          gzip_static always;
          gzip_types text/plain text/css text/js text/xml text/javascript application/javascript application/x-javascript application/json application/xml application/xml+rss;
          gzip_vary on;
          tcp_nopush on;
          keepalive_timeout 30;
          port_in_redirect off;
          server_tokens off;
          server {
            add_header Cache-Control no-cache;
            add_header Access-Control-Allow-Origin *;
            add_header X-XSS-Protection "1; mode=block";
            add_header Strict-Transport-Security "max-age=31536000; includeSubdomains; ";
            add_header X-Content-Type-Options nosniff;
            add_header Referrer-Policy "no-referrer";
            add_header Content-Security-Policy "default-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; script-src 'unsafe-inline' 'self' https://www.google-analytics.com https://cdn.mouseflow.com https://cdn4.mxpnl.com https://widget.intercom.io https://js.intercomcdn.com; img-src 'self' https://www.google-analytics.com https://intercom.hubcap.video https://messenger-apps.intercom.io https://i.imgur.com https://downloads.intercomcdn.com data:; object-src 'none'; manifest-src 'self'; font-src 'self' data: https://fonts.googleapis.com https://fonts.gstatic.com https://js.intercomcdn.com; frame-src 'self' https://*.${var.domain}; connect-src 'self' https://o2.mouseflow.com https://restcountries.eu https://*.mixpanel.com https://*.${var.domain} https://*.intercom.io wss://*.intercom.io; frame-ancestors https://*.${var.domain};";
            listen 8080;
            server_name localhost;
            location / {
                root /usr/share/nginx/html;
                try_files $uri $uri/ /index.html =404;
            }
            error_page 404 /index.html;
            location ~ /\. {
                deny all;
                return 404;
            }
          }
        }
        JSON
  }
}
