variable "auth_url" {
  type        = string
  description = "Keystone auth URL"
}

variable "application_credential_id" {
  type        = string
  description = "OpenStack credential id"
}

variable "application_credential_secret" {
  type        = string
  sensitive   = true
  description = "OpenStack credential"
}

variable "tenant_name" {
  type        = string
  description = "Project/Tenant name"
}

variable "domain_name" {
  type        = string
  description = "Domain name"
}

variable "region" {
  type        = string
  description = "OpenStack region"
}

variable "instances" {
  description = "Instance detail"
  type = map(object({
    name              = optional(string)
    image_id          = string
    flavor_name       = string
    key_pair          = string
    networks = list(object({
      name        = string
      fixed_ip_v4 = optional(string)       
      ip_list     = optional(list(string)) 
      start_ip    = optional(string)
    }))
    volumes = list(object({
      size                  = number
      volume_type           = optional(string)  
      bootable              = bool
      format                = optional(string) 
      delete_on_termination = optional(bool, true)
    }))
    security_groups   = optional(list(string), ["default"])
    availability_zone = optional(string)
    user_data         = optional(string)
    metadata          = optional(map(string), {})
  }))
  default = {}
}

variable "instance_groups" {
  description = "Multiple instance groups"
  type = map(object({
    count         = number
    name_prefix   = string
    start_index   = optional(number, 1)

    image_id      = string
    flavor_name   = string
    key_pair      = string
    networks = list(object({
      name        = string
      fixed_ip_v4 = optional(string)       
      ip_list     = optional(list(string)) 
      start_ip    = optional(string)
    }))
    volumes = list(object({
      size                  = number
      bootable              = bool
      format                = optional(string) 
      volume_type           = optional(string)
      delete_on_termination = optional(bool, true)
    }))
    security_groups   = optional(list(string), ["default"])
    availability_zone = optional(string)
    user_data         = optional(string)
    metadata          = optional(map(string), {})
  }))
  default = {}
}
