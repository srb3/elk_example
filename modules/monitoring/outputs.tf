locals {
  target_ip = length(var.target_ips) > 0 ? var.target_ips[0] : ""
}

output "url" {
  value = "http://${local.target_ip}:8086"
}
