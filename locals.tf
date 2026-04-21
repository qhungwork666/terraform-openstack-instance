locals {
  generated_instances = merge([
    for group_name, group in var.instance_groups : {
      for idx, i in range(
        lookup(group, "start_index", 1),
        lookup(group, "start_index", 1) + group.count
      ) :

      format("%s-%02d", group.name_prefix, i) => {
        name              = format("%s-%02d", group.name_prefix, i)
        image_id          = group.image_id
        flavor_name       = group.flavor_name
        key_pair          = group.key_pair
        volumes           = group.volumes
        security_groups   = group.security_groups
        availability_zone = group.availability_zone
        user_data         = group.user_data

        networks = [
          for net in group.networks : {
            name        = net.name
            fixed_ip_v4 = (
              net.fixed_ip_v4 != null ? net.fixed_ip_v4 :
              (net.ip_list != null && length(net.ip_list) > idx) ? net.ip_list[idx] :
              net.start_ip != null ? cidrhost(
                format("%s/24", net.start_ip),
                parseint(regex("\\d+$", net.start_ip), 10) + idx
              ) :
              null
            )
          }
        ]
        metadata = merge(
          group.metadata,
          {
            group = group_name
            index = tostring(i)
          }
        )
      }
    }
  ]...)

  all_instances = merge(
    var.instances,
    local.generated_instances
  )
}