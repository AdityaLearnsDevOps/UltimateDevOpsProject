locals {
  local_priv_subnet_list = var.priv_sub_cidr
  local_nat_gw_obj_list = tolist(values(aws_nat_gateway.nat_gw)) # List of NAT GW Objects
}

# Main VPC resource block:
resource "aws_vpc" "main_net" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "UdemyProjectVPC"
  }
}

# Private subnet resource block:
resource "aws_subnet" "priv_subnet" {
  vpc_id     = aws_vpc.main_net.id
  for_each   = toset(var.priv_sub_cidr)
  cidr_block = each.value

  tags = {
    Name = "UdemyProjectPrivSubnet"
  }
}

# Public subnet resource block:
resource "aws_subnet" "pub_subnet" {
  vpc_id     = aws_vpc.main_net.id
  for_each   = toset(var.pub_sub_cidr)
  cidr_block = each.value

  map_public_ip_on_launch = true  ## Create a Public IP when launching subnet 
   
  tags = {
    Name = "UdemyProjectPubSubnet"
  }
}


# NAT Gateway resource block:
## AWS Elastic IP (EIP) resource block for association with NAT-GW

resource "aws_eip" "main_eip" {
  domain   = "vpc"
  region = "ap-south-1"
  ### AWS EIP requires IGW to be present
  depends_on = [ aws_internet_gateway.main_igw ]
}

resource "aws_nat_gateway" "nat_gw" {
  for_each = toset(var.pub_sub_cidr)
  subnet_id = aws_subnet.pub_subnet[each.value].id
  allocation_id = aws_eip.main_eip.id
  availability_mode = "zonal"
  connectivity_type = "public" ## Private IP translates to 'Public' IP which will have access to internet.

  tags = {
    Name = "UdemyProjPrivSubnet-NAT_GW"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main_igw]
}

# Internet Gateway resource block :
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_net.id

  tags = {
    Name = "UdemyProjPubSubnet-IGW"
  }
}

# Route table for Subnets

resource "aws_route_table" "main_net_priv_rt" {
  vpc_id = aws_vpc.main_net.id
  for_each = toset(var.priv_sub_cidr)
    ## Route to the NAT Gateway for resources in Private Subnet
  route {
    cidr_block = var.nat_gw_route_cidr
    gateway_id = local.local_nat_gw_obj_list[ index(local.local_priv_subnet_list,each.key) % length(local.local_nat_gw_obj_list) ].id # Loop over natgw list and pick index
  }

  tags = {
    Name = "UdemyProjRT"
  }
} 

resource "aws_route_table" "main_net_pub_rt" {
  vpc_id = aws_vpc.main_net.id
  
  route {
    cidr_block = var.igw_route_cidr
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "UdemyProjRT"
  }
} 


# Private Subnet <-> RT association
resource "aws_route_table_association" "priv_subnet_rt_association" {
  for_each = toset(var.priv_sub_cidr)
  subnet_id      = aws_subnet.priv_subnet[each.value].id
  route_table_id = aws_route_table.main_net_priv_rt[each.value].id
}   

# Public subnet <-> RT association
resource "aws_route_table_association" "pub_subnet_rt_association" {
  for_each = toset(var.pub_sub_cidr)
  subnet_id      = aws_subnet.pub_subnet[each.value].id
  route_table_id = aws_route_table.main_net_pub_rt.id
}   
