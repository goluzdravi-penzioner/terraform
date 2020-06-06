resource "kubernetes_config_map" "coap-gateway-conf" {
  metadata {
    name      = "coap-gateway-conf"
    namespace = var.namespace
  }

  data = {
    CAPTURE_ADDRESS           = "https://data-gateway.core.${var.domain}/v2/up"
    DATA-GATEWAY_OUT_COAPKEY  = var.data_gateway_key
  }
}
