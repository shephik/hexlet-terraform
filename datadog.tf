provider "datadog" {
  api_url = var.datadog_api_url
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
}

// Можно посмотреть инфо по уже созданным ресурсам
data "yandex_compute_instance" "default_instance" {
  folder_id = var.folder_id
  name      = "teraform-test"
}

# output "host" {
#   value = data.yandex_compute_instance.default_instance.network_interface.0.nat_ip_address
# }

# output "host_id" {
#   value = data.yandex_compute_instance.default_instance.instance_id
# }

resource "datadog_monitor" "watchdog_monitor" {
  name               = "Name for monitor watchdog_monitor"
  type               = "metric alert"
  message            = "Monitor triggered. Notify: @hipchat-channel"
  escalation_message = "Escalation message @pagerduty"

  query = "avg(last_1h):avg:aws.ec2.cpu{environment:watchdog_monitor,host:fhmj26h5t1aogqskak68.auto.internal} by {host} > 4"

  monitor_thresholds {
    warning           = 2
    warning_recovery  = 1
    critical          = 4
    critical_recovery = 3
  }
}

resource "datadog_monitor" "network_monitor" {
  name               = "network_monitor"
  type               = "service check"
  message            = "Problems with network"
  escalation_message = "Alarm"

  query = "'http.can_connect'.over('host:${data.yandex_compute_instance.default_instance.instance_id}.auto.internal','instance:my_study_website').by('*').last(2).count_by_status()"

  monitor_thresholds {
    warning           = 1
    warning_recovery  = 1
    critical          = 1
    critical_recovery = 1
  }
}