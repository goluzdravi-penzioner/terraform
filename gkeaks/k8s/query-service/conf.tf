resource "kubernetes_config_map" "query-service-conf" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "query-service-conf"
    namespace = var.namespace
  }

  data = {
    SPRING_DATA_MONGODB_URI                                        = "${var.mongo_uri}"
    SECURITY_RESOURCE_JWK_KEY-SET-URI                              = "http://auth-service-internal/.well-known/jwks.json"
    OPENTRACING_JAEGER_RATE-LIMITING-SAMPLER_MAX-TRACES-PER-SECOND = 2
    SERVICES_PERMISSIONS_URL                                       = "http://mellarius-v2-internal"
    SERVICES_GROUPS_URL                                            = "http://mellarius-v2-internal"
  }
}
