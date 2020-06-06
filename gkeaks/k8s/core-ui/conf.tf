resource "kubernetes_config_map" "core-ui-app-conf" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "core-ui-app-conf"
    namespace = var.namespace
  }

  data = {
    "app.config.json" = <<JSON
      {
        "APIBaseURL": "https://api.core.${var.domain}",
        "authServerUrl":  "https://auth.${var.domain}",
        "oauthConfig": {
          "clientId": "new-core",
          "customQueryParams": {
            "preview": "true"
          },
          "loginUrl": "https://auth.${var.domain}/oauth/authorize",
          "oidc": false,
          "redirectUri": "https://preview.core.${var.domain}",
          "scope": "core.api core.ui",
          "silentRefreshRedirectUri": "https://preview.core.${var.domain}/assets/silent-refresh.html"
        },
        "oldCoreBaseUrl": "https://core.${var.domain}",
        "tenant": {
          "documentationURL": "${var.documentation_url}",
          "headerHeight": 56,
          "name": "${var.product_name}",
          "statusPageURL": "${var.status_page}",
          "title": "${var.product_name}"
        },
        "uplinkBaseURL": "https://data-gateway.core.${var.domain}/v2"
      }
      JSON
  }
}

resource "kubernetes_config_map" "core-ui-nginx-conf" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "core-ui-nginx-conf"
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
            add_header Content-Security-Policy "default-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; script-src 'unsafe-inline' 'self' data: https://www.google-analytics.com https://cdn.mouseflow.com https://cdn4.mxpnl.com https://widget.intercom.io https://js.intercomcdn.com; img-src 'self' https://www.google-analytics.com https://intercom.hubcap.video https://messenger-apps.intercom.io https://i.imgur.com https://downloads.intercomcdn.com data:; object-src 'none'; manifest-src 'self'; font-src 'self' data: https://fonts.googleapis.com https://fonts.gstatic.com https://js.intercomcdn.com; frame-src 'self' https://*.${var.domain}; connect-src 'self' https://o2.mouseflow.com https://restcountries.eu https://*.mixpanel.com https://*.core.${var.domain} https://*.intercom.io wss://*.intercom.io; frame-ancestors https://*.${var.domain}; worker-src blob:;";
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
