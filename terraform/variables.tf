variable "project_name" {
  description = "The name of the project used for resource naming"
  type        = string
  default     = "dataopsmini"
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "West Europe"
}