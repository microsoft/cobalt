variable "comma_sep_ip_list" {
  description = "A comma-separated list of IPs and/or CIDR/IP ranges that will be converted to a TF list/array, e.g. \"1.1.1.1/32, 8.8.8.8/24\"."
  type = string
}

variable "tail_list" {
  description = <<HERE
    A TF list that will be combined with the `comma_sep_ip_list`, if provided. Items
    from the `comma_sep_ip_list` will appear to the left of items from this `tail_list` value."
HERE
  type = list(string)
  default = []
}