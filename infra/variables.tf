variable "db_password" {
  sensitive = false
  type      = string
}

variable "docker_hub" {
  sensitive = true
  type      = string
}