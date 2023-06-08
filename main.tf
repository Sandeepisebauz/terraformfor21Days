//VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main"
  }
}

//Public Subnet 1
resource "aws_subnet" "public0" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "public0"
  }
}

//Public Subnet 2
resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "public1"
  }

}

// Private Subnet 1
resource "aws_subnet" "private0" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private0"
  }
}
// Private Subnet 2
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private1"
  }
}

//AWS IGW
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main"
  }

}

//FOR NAT we need EIP, as we need two nat gateway, we need 2 EIP
resource "aws_eip" "eip0" {
  vpc = true

  tags = {
    Name = "eip0"
  }
}

resource "aws_eip" "eip1" {
  vpc = true
  tags = {
    Name = "eip1"
  }
}

//Now Create NAT Gateway in each public subnet
resource "aws_nat_gateway" "nat0" {
  allocation_id = aws_eip.eip0.id
  subnet_id     = aws_subnet.public0.id
  tags = {
    Name = "nat0"
  }

}

resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.public1.id
  tags = {
    Name = "nat1"
  }

}

//Route Table for Public Subnet, route the traffic to Internet GateWay
resource "aws_route_table" "public_rt0" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id

  }

  tags = {
    Name = "public_rt0"
  }

}

//Private Subnet routable routes traffic to NAT gatewauy
resource "aws_route_table" "private_rt0" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat0.id
  }
  tags = {
    Name = "private_rt0"
  }

}

resource "aws_route_table" "private_rt1" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat1.id
  }
  tags = {
    Name = "private_rt1"
  }

}

// Connect the Subnet to route table 
resource "aws_route_table_association" "rt_asso_public0" {
  subnet_id      = aws_subnet.public0.id
  route_table_id = aws_route_table.public_rt0.id

}

resource "aws_route_table_association" "rt_asso_public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public_rt0.id

}

resource "aws_route_table_association" "rt_asso_private0" {
  subnet_id      = aws_subnet.private0.id
  route_table_id = aws_route_table.private_rt1.id

}

resource "aws_route_table_association" "rt_asso_private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private_rt1.id

}

