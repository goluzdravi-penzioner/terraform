resource "kubernetes_config_map" "data-gateway-conf" {
  metadata {
    name      = "data-gateway-conf"
    namespace = var.namespace
  }

  data = {
    SPRING_DATASOURCE_URL                                          = "jdbc:mysql://${var.db_address}:3306/cera?user=${local.db_user}&serverTimezone=UTC&useLegacyDatetimeCode=false"
    SPRING_DATASOURCE_PASSWORD                                     = var.db_pass
    SPRING_DATA_MONGODB_URI                                        = var.mongo_uri
    SPRING_DATA_MONGODB_DATABASE                                   = "mellolam"
    SCRIPTRUNNERURL                                                = "http://scriptrunner-internal/v1/run"
    CONNECTIVITYSERVICEURL                                         = "http://integration-service-internal"
    SERVER_PORT                                                    = "8080"
    MANAGEMENT_SERVER_PORT                                         = "8880"
    OPENTRACING_JAEGER_RATE-LIMITING-SAMPLER_MAX-TRACES-PER-SECOND = 2
    SERVICE_MELLARIUSV2_URL                                        = "http://mellarius-v2-internal"
    SERVICE_MELLARIUSV2_KEY                                        = var.mellariusv2_key
    SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWK-SET-URI          = "http://auth-service-internal/.well-known/jwks.json"
    MQTTDOWNLINKURL                                                = "http://mqtt-gateway-internal/mqttDownlink"
    MQTTKEY                                                        = var.mqttkey
    COAPKEY                                                        = var.coapkey
    APIKEY                                                         = var.apikey
    MELLARIUSKEY                                                   = var.mellariuskey
    CONNECTIVITYSERVICEKEY                                         = var.connectivityservicekey
    TIMERSERVICEKEY                                                = var.timerservicekey
  }
}

locals {
  db_user = "${var.cloud_env == "google" ? var.db_user : "${var.db_user}@${var.mysql_name}"}"
}
