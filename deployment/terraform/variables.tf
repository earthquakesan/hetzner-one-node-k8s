# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
variable "hcloud_token" {
  sensitive = true # Requires terraform >= 0.14
}

variable "server" {
  type = object({
    name = string
    image = string
    server_type = string
  })
}