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
}

// Terraform должен знать ключ, для выполнения команд по API
provider "yandex" {
  zone  = "ru-central1-a"
  token = var.yc_token
}

resource "yandex_compute_instance" "default" {
  name        = "teraform-test"
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

resource "yandex_compute_instance" "default2" {
  name        = "teraform-test2"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"
  folder_id   = var.folder_id // идентификатор каталога Yandex Cloud

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.default2.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.default.id
    nat       = true
  }

  metadata = {
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
  name      = "teraform-disk"
  type      = "network-ssd"
  zone      = "ru-central1-a"
  image_id  = "fd83s8u085j3mq231ago" // идентификатор образа Ubuntu
  folder_id = var.folder_id          // идентификатор каталога Yandex Cloud

  labels = {
    environment = "test"
  }
}

resource "yandex_compute_disk" "default2" {
  name      = "teraform-disk2"
  size = 93 // NB size must be divisible by 93  
  type = "network-ssd-nonreplicated"
  zone = "ru-central1-a"
  # type      = "network-ssd"
  # zone      = "ru-central1-a"
  image_id  = "fd83s8u085j3mq231ago" // идентификатор образа Ubuntu
  folder_id = var.folder_id         

  labels = {
    environment = "test"
  }
}

resource "yandex_lb_network_load_balancer" "default" {
  name = "my-network-load-balancer"
  folder_id = var.folder_id

  listener {
    name = "my-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.default.id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}


resource "yandex_lb_target_group" "default" {
  name      = "my-target-group"
  region_id = "ru-central1"
  folder_id = var.folder_id

  target {
    subnet_id = yandex_vpc_subnet.default.id
    address   = yandex_compute_instance.default.network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.default.id
    address   = yandex_compute_instance.default2.network_interface.0.ip_address
  }

  // Всегда массив
  depends_on = [yandex_compute_instance.default, yandex_compute_instance.default2]
}