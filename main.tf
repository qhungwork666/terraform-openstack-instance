terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.4"
    }
  }
}

provider "openstack" {
  auth_url                        = var.auth_url
  application_credential_id       = var.application_credential_id
  application_credential_secret   = var.application_credential_secret
  tenant_name                     = var.tenant_name
  domain_name                     = var.domain_name 
  region                          = var.region
}

resource "openstack_compute_instance_v2" "instance" {
  for_each = local.all_instances

  name              = coalesce(each.value.name, each.key)
  flavor_name       = each.value.flavor_name
  image_id          = length(each.value.volumes) == 0 ? each.value.image_id : null
  key_pair          = each.value.key_pair
  security_groups   = each.value.security_groups
  availability_zone = each.value.availability_zone
  user_data         = each.value.user_data
  metadata          = each.value.metadata

  dynamic "network" {
    for_each = each.value.networks
    content {
      name        = network.value.name
      fixed_ip_v4 = network.value.fixed_ip_v4
    }
  }

  dynamic "block_device" {
    for_each = each.value.volumes

    content {
      uuid                  = block_device.value.bootable ? each.value.image_id : null
      source_type           = block_device.value.bootable ? "image" : "blank"
      destination_type      = "volume"
      guest_format          = try(block_device.value.format, "ext4")
      volume_size           = block_device.value.size
      volume_type           = try(block_device.value.volume_type, null)
      boot_index            = block_device.key == 0 ? 0 : -1
      delete_on_termination = try(block_device.value.delete_on_termination, true)
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}