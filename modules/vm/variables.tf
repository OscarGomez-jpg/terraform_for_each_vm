variable "servers" {
  type        = set(string)
  description = "lista de servidores que vamos a desplegar"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
  description = "tipo de instancia EC2 por defecto"
}

variable "instance_types" {
  type        = map(string)
  default     = {}
  description = "tipos de instancia específicos por servidor (opcional)"
}

variable "subnet_id" {
  type        = string
  description = "id de la subnet de los servidores"
}

variable "vpc_id" {
  type        = string
  description = "id del VPC"
}

variable "key_name" {
  type        = string
  description = "nombre del key pair para SSH (sin password, más seguro)"
}

variable "prefix_name" {
  type        = string
  description = "prefijo de los recursos"
}