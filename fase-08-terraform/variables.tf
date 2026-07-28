variable "container_name" {
  description = "Nome do container Docker"
  type        = string
  default     = "meu-site-terraform"
}

variable "external_port" {
  description = "Porta externa exposta na VM"
  type        = number
  default     = 8090
}
