terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      # required_version = ">= 0.13"
    }
    datadog = {
      source = "DataDog/datadog"
      # required_version = ">= 3.3.0"
    }
  }
  # required_version = ">= 0.13"
}

// Terraform должен знать ключ, для выполнения команд по API

// Определение переменной, которую нужно будет задать
# variable "yc_token" {}

provider "yandex" {
  zone  = "ru-central1-a"
  token = var.yc_token
}

resource "yandex_compute_instance" "default" {
  name        = var.compute_instance_name
  platform_id = "standard-v1"
  zone        = "ru-central1-a"
  folder_id   = var.folder_id // идентификатор каталога Yandex Cloud

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.default.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat       = true
  }

  metadata = {
    # ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data = "${file("meta.txt")}"
  }
}

resource "yandex_vpc_network" "default" {
  folder_id = var.folder_id // идентификатор каталога Yandex Cloud
}

resource "yandex_vpc_subnet" "default" {
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["10.5.0.0/24"]
  folder_id      = var.folder_id
}

resource "yandex_compute_disk" "default" {
  name      = var.compute_disk_name
  type      = "network-ssd"
  zone      = "ru-central1-a"
  image_id  = "fd83s8u085j3mq231ago" // идентификатор образа Ubuntu
  folder_id = var.folder_id          // идентификатор каталога Yandex Cloud

  labels = {
    environment = "test"
  }
}