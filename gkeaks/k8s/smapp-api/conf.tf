resource "kubernetes_config_map" "smapp-api-conf" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "smapp-api-conf"
    namespace = var.namespace
  }

  data = {
    DEFAULT_TIME_ZONE                    = "Europe/Zurich"
    SMARTAPP_CRON_JOB_SCHEDULER_TIMEZONE = "Europe/Zurich"
    SMARTAPP_CRON_JOB_OCCUPANCY_ENABLED  = "false"
    SMARTAPP_CRON_JOB_OCCUPANCY_SCHEDULE = "*/15 * * * *"
    SMARTAPP_REDIS_HOST                  = var.redis_host
    SMARTAPP_REDIS_PORT                  = local.redis_port
    SMARTAPP_REDIS_PASSWORD              = var.redis_password
    SMARTAPP_REDIS_SSL_ENABLED           = local.redis_ssl_enabled
    SMARTAPP_DB_SERVER                   = var.db_host
    SMARTAPP_DB_PORT                     = "3306"
    SMARTAPP_DB_CONNECTION_LIMIT         = "50"
    SMARTAPP_DB_USERNAME                 = local.db_user
    SMARTAPP_DB_PASSWORD                 = var.db_pass
    SMARTAPP_DB_DATABASE                 = var.db_name
    APP_CACHE_CONCURRENT_REQUESTS        = "8"
    APP_CACHE_SAMPLE_LIMIT               = "80000"
    APP_CACHE_ERROR_TIMEOUT              = "4000"
    APP_CACHE_ENTITY_CACHE_TIMEOUT       = "240000"
    APP_CACHE_CHECK_LIMIT                = "5"
    APP_CACHE_DEBUG                      = "false"
    DEBUG                                = "false"
    PORT                                 = "8080"
    PLATFORM_API_URL                     = "https://api.core.${var.domain}"
    AUTH_JWKS_URL                        = "http://auth-service-internal/.well-known/jwks.json"
    ENVS_API_KEY                         = var.environments_api_key
  }
}

resource "kubernetes_config_map" "smapp-api-cron-conf" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "smapp-api-cron-conf"
    namespace = var.namespace
  }

  data = {
    DEFAULT_TIME_ZONE                    = "Europe/Zurich"
    SMARTAPP_CRON_JOB_SCHEDULER_TIMEZONE = "Europe/Zurich"
    SMARTAPP_CRON_JOB_OCCUPANCY_ENABLED  = "true"
    SMARTAPP_CRON_JOB_OCCUPANCY_SCHEDULE = "*/15 * * * *"
    SMARTAPP_REDIS_HOST                  = var.redis_host
    SMARTAPP_REDIS_PORT                  = local.redis_port
    SMARTAPP_REDIS_PASSWORD              = var.redis_password
    SMARTAPP_REDIS_SSL_ENABLED           = local.redis_ssl_enabled
    SMARTAPP_DB_SERVER                   = var.db_host
    SMARTAPP_DB_PORT                     = "3306"
    SMARTAPP_DB_CONNECTION_LIMIT         = "50"
    SMARTAPP_DB_USERNAME                 = local.db_user
    SMARTAPP_DB_PASSWORD                 = var.db_pass
    SMARTAPP_DB_DATABASE                 = var.db_name
    APP_CACHE_CONCURRENT_REQUESTS        = "8"
    APP_CACHE_SAMPLE_LIMIT               = "80000"
    APP_CACHE_ERROR_TIMEOUT              = "4000"
    APP_CACHE_ENTITY_CACHE_TIMEOUT       = "240000"
    APP_CACHE_CHECK_LIMIT                = "5"
    APP_CACHE_DEBUG                      = "false"
    DEBUG                                = "false"
    PORT                                 = "8080"
    PLATFORM_API_URL                     = "https://api.core.${var.domain}"
    AUTH_JWKS_URL                        = "http://auth-service-internal/.well-known/jwks.json"
    ENVS_API_KEY                         = var.environments_api_key
  }
}

locals {
  db_user           = "${var.cloud_env == "google" ? var.db_user : "${var.db_user}@${var.mysql_name}"}"
  redis_port        = "${var.redis_ssl_port == 0 ? var.redis_port : var.redis_ssl_port}"
  redis_ssl_enabled = "${var.redis_ssl_port == 0 ? "false" : "true"}"
}
