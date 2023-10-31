resource "hcloud_server" "k3s" {
  name        = var.server_name
  image       = var.server_defaults.image
  server_type = var.server_defaults.server_type
  ssh_keys    = var.ssh_keys
  user_data = templatefile("${path.module}/scripts/base_configuration.sh", {
    FOO = "bar"
  })
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}
