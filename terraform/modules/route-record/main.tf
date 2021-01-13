locals {
  # convert from list to map with unique keys
  recordsets = { for rs in var.records : "${rs.name} ${rs.type}" => rs }
}

resource "aws_route53_record" "this" {
  for_each = local.recordsets

  zone_id         = var.zone_id
  allow_overwrite = var.allow_overwrite

  name    = each.value.name != "" ? "${each.value.name}.${var.zone_name}" : var.zone_name
  type    = each.value.type
  ttl     = lookup(each.value, "ttl", null)
  records = lookup(each.value, "records", null)

  dynamic "alias" {
    for_each = length(keys(lookup(each.value, "alias", {}))) == 0 ? [] : [true]

    content {
      name                   = each.value.alias.name
      zone_id                = each.value.alias.zone_id
      evaluate_target_health = lookup(each.value.alias, "evaluate_target_health", false)
    }
  }
}
