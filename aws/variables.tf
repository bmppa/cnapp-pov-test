variable "aws_region" {
  type = string
}
variable "vpc_cidr" {
  type = string
}
variable "pub_net_1_cidr" {
  type = string
}
variable "pub_net_2_cidr" {
  type = string
}
variable "priv_net_1_cidr" {
  type = string
}
variable "priv_net_2_cidr" {
  type = string
}
variable "public_instances" {
  type = map(list(string))
}
variable "script" {
  type    = string
  default = "none"
}
variable "my_ip" {
  type    = string
  default = "0.0.0.0/0"
}
variable "eks_instance_type" {
  type = list(string)
}
variable "eks_desired_size" {
  type = number
}
variable "eks_max_size" {
  type = number
}
variable "eks_min_size" {
  type = number
}
variable "eks_max_unavailable" {
  type = number
}