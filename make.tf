# https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples/virtual-machines/linux/basic-password https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples/virtual-machines/linux/basic-password
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

resource "azurerm_subnet" "main" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-security-group"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "block-internet-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "allow-vnet-inbound"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "0-65535"
    destination_port_range     = "0-65535"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  tags = var.tags
}

resource "azurerm_public_ip" "main" {
  name                = "${var.prefix}-public-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  allocation_method   = "Static"
  tags                = var.tags
}

resource "azurerm_lb" "main" {
  name                = "${var.prefix}-load-balancer"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    subnet_id            = azurerm_subnet.main.id
    public_ip_address_id = azurerm_public_ip.main.id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "BackEndAddressPool"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-network-interface"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }

  tags = var.tags
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  network_interface_id    = azurerm_network_interface.main.id
  ip_configuration_name   = "${var.prefix}-ni-backend-address-pool-association"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

data "azurerm_image" "main" {
  name                = var.packer_image_name
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_availability_set" "main" {
  name                         = "${var.prefix}-availability-set"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.main.name
  platform_fault_domain_count  = 3
  platform_update_domain_count = var.n_update_domins
  tags                         = var.tags
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = "${var.prefix}-vm"
  resource_group_name             = azurerm_resource_group.main.name
  availability_set_id             = azurerm_availability_set.main.id
  location                        = var.location
  size                            = "Standard_DS1_v2"
  source_image_id                 = data.azurerm_image.main.id
  admin_username                  = "${var.admin_username}"
  admin_password                  = "${var.admin_password}"
  disable_password_authentication = false

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  tags = var.tags
}