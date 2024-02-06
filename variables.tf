variable "yc_token" {
  description = "OAuth-токен"
  // Тип значения переменной
  type = string
  // Значение по умолчанию, которое используется если не задано другое
  # default = "какое-то значение по умолчанию"
  // Прячет значение переменной из всех выводов
  // По умолчанию false
  # sensitive = true
}

variable "datadog_api_url" {
  description = "DataDog API url"
  type        = string
}

variable "datadog_api_key" {
  description = "DataDog API key"
  type        = string
}

variable "datadog_app_key" {
  description = "DataDog APP key"
  type        = string
}

variable "compute_instance_name" {
  description = "YandexCloud compute instance name"
  type        = string
  default     = "teraform-test"
}

variable "compute_disk_name" {
  description = "YandexCloud compute disk name"
  type        = string
  default     = "teraform-disk"
}

variable "folder_id" {
  description = "YandexCloud catalog id"
  type        = string
}