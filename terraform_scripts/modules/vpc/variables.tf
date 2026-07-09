variable "region" {
    description = "Cloud Region"
    type = string
    default = "ap-south-1"
}
variable "vpc_cidr" {
    description = "CIDR Block for your VPC"
    type = string
    default = "10.0.0.0/16"
}
variable "priv_sub_cidr" {
    description = "CIDR Block for your Private Subnet"
    type = list
    default = ["10.0.1.0/24"]
}
variable "pub_sub_cidr" {
    description = "CIDR Block for your Public Subnet"
    type = list
    default = ["10.0.2.0/24"]
}
variable "nat_gw_route_cidr" {
    description = "Provide a CIDR block for NAT GW"
    type = list
    default = ["0.0.0.0/24"]
}
variable "igw_route_cidr" {
    description = "Provide a CIDR block for IGW"
    type = list
    default = ["0.0.0.0/0"]
}