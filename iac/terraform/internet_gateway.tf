
# CONFIGURACION Internet_Gateway 
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "main-igw"

    # CONFIGURACION \nAttached 
    Connection  = "Conectado a la VPC"

    # CONFIGURACION \nEntry 
    Function    = "Punto de entrada"

    # CONFIGURACION \npublic 
    TrafficType = "public traffic"
  }
}




# CONFIGURACION ROUTE TABLE
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  # CONFIGURACION \nRoute 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-route-table"
  }
}



#DIVISIO SUBNETS PUBLICAS AZ-A/AZ-B
resource "aws_route_table_association" "public_az_a" {
  subnet_id      = aws_subnet.public_az_a.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_az_b" {
  subnet_id      = aws_subnet.public_az_b.id
  route_table_id = aws_route_table.public_rt.id
}



# CONFIGURACION NAT Gateway A 
resource "aws_eip" "nat_a" {
  domain = "vpc"
  tags   = { Name = "eip-nat-a" }
}

resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_az_a.id 

  tags = {
    Name = "nat-gateway-a"
    # CONFIGURACION \nRoutes y \nfor 
    Description = "Rutas de trafico salientes por subnet AZ-a"
  }
  depends_on = [aws_internet_gateway.main]
}



# CONFIGURACION NAT Gateway B 
resource "aws_eip" "nat_b" {
  domain = "vpc"
  tags   = { Name = "eip-nat-b" }
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.public_az_b.id 

  tags = {
    Name = "nat-gateway-b"
    # CONFIGURACION \nRoutes y \nfor para subnet AZ-b
    Description = "Rutas de trafico salientes por subnet AZ-b"

    # CONFIGURACION \nHigh-availability fallback
    Role = "High-availability fallback"
  }

  depends_on = [aws_internet_gateway.main]
}
