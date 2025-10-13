variable "region" {
  type        = string
  description = "Región de AWS donde se desplegará la infraestructura (ej: us-east-1)"
  default     = "us-east-1"
}

variable "prefix_name" {
  type        = string
  description = "Prefijo para nombres de recursos"
}

variable "key_name" {
  type        = string
  description = "Nombre del Key Pair de AWS para acceso SSH a las instancias"
}

variable "servers" {
  type        = set(string)
  description = "Nombres de los servidores que se van a desplegar"
}