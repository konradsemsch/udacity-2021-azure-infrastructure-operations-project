variable "prefix" {
  default = "project-web-server"
  type = string
  description = "The prefix which should be used for all resources in this project."
}

variable "location" {
  default = "West Europe"
  type = string
  description = "The Azure Region in which all resources in this project should be created."
}