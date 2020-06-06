resource "kubernetes_config_map" "smapp-web-app-conf" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "smapp-web-app-conf"
    namespace = var.namespace
  }

  data = {
    "app.config.json" = <<JSON
      {
       "apiBaseURL":  "https://api.app.${var.domain}",
       "platformURL": "https://core.${var.domain}",
       "webSocketURL": "wss://api.app.${var.domain}",
       "authServerUrl":  "https://auth.${var.domain}",
       "oAuthConfig": {
          "customQueryParams": {
            "preview": "true"
          },
          "clientId": "smapp-web",
          "loginUrl": "https://auth.${var.domain}/oauth/authorize",
          "oidc": false,
          "redirectUri": "https://###.app.${var.domain}",
          "scope": "core.smapp",
          "silentRefreshRedirectUri": "https://###.app.${var.domain}/assets/silent-refresh.html"
        }
      }
      JSON
  }
}


resource "kubernetes_config_map" "smapp-web-nginx-conf" {
  metadata {
    name      = "smapp-web-nginx-conf"
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
            add_header Content-Security-Policy "default-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; script-src 'unsafe-eval' 'unsafe-inline' 'self' https://www.google-analytics.com https://cdn.mouseflow.com https://cdn4.mxpnl.com https://widget.intercom.io https://js.intercomcdn.com https://aframe.io https://dist.3d.io https://unpkg.com https://cdn.rawgit.com https://code.archilogic.com https://polyfill.io blob:; img-src 'self' https: data:; object-src 'none'; manifest-src 'self'; font-src 'self' data: https://fonts.googleapis.com https://fonts.gstatic.com https://js.intercomcdn.com; frame-src 'self' https://*.${var.domain} https://*.core.${var.domain} https://*.app.${var.domain} https://viewer.archilogic.com; connect-src 'self' https://o2.mouseflow.com https://restcountries.eu https://*.mixpanel.com https://*.${var.domain} https://*.core.${var.domain} https://*.app.${var.domain} https://*.intercom.io wss://*.intercom.io https://microservices.archilogic.com https://storage.3d.io https://spaces.archilogic.com https://cdn.aframe.io https://storage-nocdn.3d.io https://viewer.archilogic.com https://maps.googleapis.com https://api.mapbox.com https://events.mapbox.com wss://*.app.${var.domain}; frame-ancestors https://*.core.${var.domain} https://*.${var.domain} https://*.core.${var.domain} https://*.app.${var.domain};";
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
