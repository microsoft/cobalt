locals {
  split_list   = split(",", var.comma_sep_ip_list)
  trimmed_list = [for ip in local.split_list : trimspace(ip)]
  ips_as_list  = compact(concat(local.trimmed_list, var.tail_list))
}