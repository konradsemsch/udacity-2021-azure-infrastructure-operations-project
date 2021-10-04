variable "prefix" {
  description = "The prefix which should be used for all resources in this project"
  default = "project-web-server"
  type = string
}

variable "location" {
  description = "The Azure Region in which all resources in this project should be created"
  default = "West Europe"
  type = string
}

variable "packer_image_name" {
  description = "Name of the Packer image"
  default = "project-web-server-packer-image"
}

variable "n_update_domins" {
  description = "The number of update domains of the VM in the availability set"
  default     = 5
  type        = number
}

variable "admin_user" {
   description = "User name to use as the admin account on the VMs that will be part of the VM scale set"
   default     = "konradino"
}

variable "admin_password" {
   description = "Default password for admin account"
}

variable "tags" {
   description = "Map of the tags to use for the resources that are deployed"
   type        = map(string)
   default = {
      project = "udacity-ws"
   }
}