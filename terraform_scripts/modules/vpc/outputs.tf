output "vpc_id" {
  description = "VPC ID"
  value = aws_vpc.main_net.id
}

output "nat_gw_id" {
  description = "NAT-GW ID"
  value = aws_nat_gateway.nat_gw.id
}

output "public_ip" {
  description = "Elastic IP associated"
  value = aws_eip.main_eip.address
}

# output "created_routes" {
#   description = "Routes created in the route table"
#   value = aws_route_table.main_net_rt.route[*]
# }