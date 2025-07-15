variable "project_id" {
  type        = string
  description = "ID проекта"
  default     = "xenon-pier-459606-n2"
}

variable "region" {
  type        = string
  description = "Регион Google Cloud"
  default     = "europe-north1"
}

variable "zone" {
  type        = string
  description = "Зона Google Cloud"
  default     = "europe-north1-c"
}

variable "vm_name_1" {
  type        = string
  description = "Имя виртуальной машины"
  default     = "terraform-vm-1"
}

variable "vm_name_2" {
  type        = string
  description = "Имя виртуальной машины"
  default     = "terraform-vm-2"
}

variable "machine_type" {
  type        = string
  description = "Тип машины (например, e2-medium)"
  default     = "e2-small"
}

variable "image" {
  type        = string
  description = "Образ операционной системы"
  default     = "ubuntu-minimal-2204-jammy-v20250530"
}

variable "disk_size_gb" {
  type        = number
  description = "Размер диска в гигабайтах"
  default     = 40
}

variable "disk_type" {
  type        = string
  description = "Тип диска (например, pd-standard)"
  default     = "pd-balanced"
}

variable "vm_tags" {
  type        = list(string)
  description = "Теги для виртуальной машины"
  default     = ["allow-ssh", "allow-http"]
}

variable "credentials_file" {
  type        = string
  description = "Path to service account key file"
  default     = "creds.json"
}

variable "service_account_email" {
  type        = string
  description = "Сервисный аккаунт"
  default     = "543116208909-compute@developer.gserviceaccount.com"
}
