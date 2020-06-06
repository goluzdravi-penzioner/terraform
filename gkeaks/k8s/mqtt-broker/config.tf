resource "kubernetes_config_map" "mqtt-broker-acl-conf" {
  metadata {
    name      = "mqtt-broker-acl-conf"
    namespace = var.namespace
  }

  data = {
    "aclfile.conf" = <<CONF
        topic  write /up/#
        topic  read  /down/#
        pattern read /down/%u/#
        pattern write /up/%u/#
        user ${var.broker_password}
        topic /#
      CONF
  }
}

resource "kubernetes_config_map" "mqtt-broker-mosquitto-conf" {
  metadata {
    name      = "mqtt-broker-mosquitto-conf"
    namespace = var.namespace
  }

  data = {
    "mosquitto.conf" = <<CONF
        persistence true
        persistence_location /mosquitto/data/
        persistence_file mosquitto.db
        log_type all
        connection_messages true
        log_timestamp true
        allow_anonymous true
        acl_file /etc/mosquitto/aclfile.conf
        listener 1883
      CONF
  }
}
