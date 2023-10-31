# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
variable "hcloud_token" {
  sensitive = true # Requires terraform >= 0.14
}

variable "server_defaults" {
  type = object({
    image = string
    server_type = string
  })
}

variable "server_name" {
  type = string
}

variable "ssh_keys" {
  type = list(string)  
}