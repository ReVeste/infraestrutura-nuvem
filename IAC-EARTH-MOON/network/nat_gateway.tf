# resource "aws_eip" "nat_eip" {
#   vpc = true

#   tags = {
#     Name = "AUTOHUB-NAT-EIP"
#   }
# }

# resource "aws_nat_gateway" "nat_gw" {
#   allocation_id = aws_eip.nat_eip.id
#   subnet_id     = aws_subnet.subnet_publica.id

#   tags = {
#     Name = "AUTOHUB-NAT-GW"
#   }
# }
