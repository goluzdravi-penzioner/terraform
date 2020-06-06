resource "kubernetes_config_map" "mqtt-gateway-conf" {
  metadata {
    name      = "mqtt-gateway-conf"
    namespace = var.namespace
  }

  data = {
    APIKEY             = var.data_gateway_key
    CAPTUREURL         = "https://data-gateway.core.${var.domain}/v1/capture"
    MQTT_PUB_USERNAME  = var.broker_password
    MQTT_PUB_PASSWORD  = var.broker_password
    MQTT_PUB_CLIENTID  = "Akenza Core Gateway Publisher (Azure)"
    MQTT_PUB_BROKERURL = "tcp://mqtt-broker-internal:1883"
    MQTT_SUB_USERNAME  = var.broker_password
    MQTT_SUB_PASSWORD  = var.broker_password
    MQTT_SUB_CLIENTID  = "Akenza Core Gateway Subscriber (Azure)"
    MQTT_SUB_BROKERURL = "tcp://mqtt-broker-internal:1883"
  }
}
