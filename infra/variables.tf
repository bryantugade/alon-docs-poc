variable "resource_group_name" {
  description = "Existing Resource Group name"
  type        = string
  default     = "alonwork-way-d-rg"
}

variable "environment_name" {
  type    = string
  default = "Development"
}

variable "app_name" {
  type    = string
  default = "alon-docs"

}

