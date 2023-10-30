resource "hcloud_server" "k3s" {
  name        = var.server.name
  image       = var.server.image
  server_type = var.server.server_type
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}
