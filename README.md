# Terraform OpenStack Instance 
This Terraform project is designed to automate the deployment of OpenStack instances with advanced configurations, including multi-disk (Cinder volumes), multi-network interfaces, and flexible IP assignment methods.
## Case 1: Standalone Instances
Used for unique, one-off servers with specific configurations.
- **DHCP**: Simply define the network name. OpenStack will assign the next available IP.
- **Static IP**: Use the `fixed_ip_v4` field to force a specific address.

```hcl
instances = {

  # Case 1: DHCP - No specific IP provided
  app-dhcp-01 = {
    image_id          = "0de35560-e5a4-4828-afca-2c474ccb0564"
    flavor_name       = "4C-8G"
    key_pair          = "my-keypair"
    security_groups   = ["my-sg"]
    availability_zone = "az1"
    networks = [
      {
        name = "vnet-app"
      }
    ]
    volumes = [
      {
        size        = 50
        bootable    = true
        volume_type = "Storage-01"
      }
    ]
  }

  # Case 2: Static IP
  app-fixed-01 = {
    image_id          = "0de35560-e5a4-4828-afca-2c474ccb0564"
    flavor_name       = "4C-8G"
    key_pair          = "my-keypair"
    security_groups   = ["my-sg"]
    availability_zone = "az1"
    networks = [
      {
        name        = "vnet-app"
        fixed_ip_v4 = "172.16.150.10"
      }
    ]
    volumes = [
      {
        size        = 50
        bootable    = true
        volume_type = "Storage-01"
      }
    ]
  }
}
```

---
## Case 2: Instance Groups
Used to deploy multiple similar instances (e.g., a Kubernetes cluster) using a single block of code.
- **DHCP**: Simply define the network name. OpenStack will assign the next available IP.
- **Static IP**: Use the `fixed_ip_v4` field to force a specific address.

```hcl
instance_groups = {

  # ---------------------------------------------------------------
  # Case 1: DHCP - No IPs provided
  # Creates: master-01, master-02, master-03 → All assigned via DHCP
  # ---------------------------------------------------------------
  master = {
    count       = 3
    name_prefix = "genestack-master"

    image_id          = "0de35560-e5a4-4828-afca-2c474ccb0564"
    flavor_name       = "4C-8G"
    key_pair          = "my-keypair"
    security_groups   = ["my-sg"]
    availability_zone = "az1"
    networks = [
      {
        name = "vnet-rke"
        # No IP provided → DHCP
      }
    ]
    volumes = [
      {
        size        = 50
        bootable    = true
        volume_type = "Storage-01"
      }
    ]
  }

  # ---------------------------------------------------------------
  # Case 2: Fixed IP (count=1)
  # Creates: worker-01 → 172.16.160.101 / 172.16.150.11
  # ---------------------------------------------------------------
  worker = {
    count       = 1
    name_prefix = "genestack-worker"

    image_id          = "0de35560-e5a4-4828-afca-2c474ccb0564"
    flavor_name       = "4C-8G"
    key_pair          = "my-keypair"
    security_groups   = ["my-sg"]
    availability_zone = "az1"
    networks = [
      {
        name        = "vnet-rke"
        fixed_ip_v4 = "172.16.160.101"
      },
      {
        name        = "vnet-app"
        fixed_ip_v4 = "172.16.150.11"
      }
    ]
    volumes = [
      {
        size        = 50
        bootable    = true
        volume_type = "Storage-01"
      }
    ]
  }

  # ---------------------------------------------------------------
  # Case 3a: Sequential IP Range - Uses start_ip (Auto-generated)
  # Creates: worker-range-01 → .110
  #          worker-range-02 → .111
  #          ...
  #          worker-range-10 → .119 (count=10 → .110 to .119)
  # ---------------------------------------------------------------
  worker-range = {
    count       = 10
    name_prefix = "genestack-worker-range"

    image_id          = "0de35560-e5a4-4828-afca-2c474ccb0564"
    flavor_name       = "4C-8G"
    key_pair          = "my-keypair"
    security_groups   = ["my-sg"]
    availability_zone = "az1"
    networks = [
      {
        name     = "vnet-rke"
        start_ip = "172.16.160.110"  # → .110, .111, .112 ... .119
      },
      {
        name     = "vnet-app"
        start_ip = "172.16.150.110"  # → .110, .111, .112 ... .119
      }
    ]
    volumes = [
      {
        size        = 50
        bootable    = true
        volume_type = "Storage-01"
      }
    ]
  }

  # ---------------------------------------------------------------
  # Case 3b: Explicit IP List - Non-sequential IPs
  # Creates: worker-custom-01 → .110
  #          worker-custom-02 → .115 (Gap in range)
  #          worker-custom-03 → .120
  # ---------------------------------------------------------------
  worker-custom = {
    count       = 3
    name_prefix = "genestack-worker-custom"

    image_id          = "0de35560-e5a4-4828-afca-2c474ccb0564"
    flavor_name       = "4C-8G"
    key_pair          = "my-keypair"
    security_groups   = ["my-sg"]
    availability_zone = "az1"
    networks = [
      {
        name    = "vnet-rke"
        ip_list = [
          "172.16.160.110",
          "172.16.160.115",
          "172.16.160.120",
        ]
      },
      {
        name    = "vnet-app"
        ip_list = [
          "172.16.150.110",
          "172.16.150.115",
          "172.16.150.120",
        ]
      }
    ]
    volumes = [
      {
        size        = 50
        bootable    = true
        volume_type = "Storage-01"
      }
    ]
  }
}
```
