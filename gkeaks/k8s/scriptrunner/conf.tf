resource "kubernetes_config_map" "scriptrunner-conf" {
  metadata {
    name      = "scriptrunner-conf"
    namespace = var.namespace
  }

  data = {
    VERSION                                                        = "v1.2.1"
    SECURITY_BASIC_ENABLED                                         = "false"
    EVAL_TIMEOUT                                                   = "1000"
    EVAL_TIMEOUT_NICE                                              = "800"
    EVAL_INSTANCES                                                 = "4"
    SERVER_PORT                                                    = "8080"
    MANAGEMENT_SERVER_PORT                                         = "8880"
    OPENTRACING_JAEGER_RATE-LIMITING-SAMPLER_MAX-TRACES-PER-SECOND = 2
  }
}
