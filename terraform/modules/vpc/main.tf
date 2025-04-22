resource "aws_vpc" "main" {
     cidr_block = "10.0.0.0/16"
   }

   resource "aws_subnet" "public" {
     count             = 2
     vpc_id            = aws_vpc.main.id
     cidr_block        = "10.0.${count.index}.0/24"
     availability_zone = data.aws_availability_zones.available.names[count.index]
   }

   resource "aws_subnet" "private" {
     count             = 2
     vpc_id            = aws_vpc.main.id
     cidr_block        = "10.0.${count.index + 2}.0/24"
     availability_zone = data.aws_availability_zones.available.names[count.index]
   }

   resource "aws_internet_gateway" "main" {
     vpc_id = aws_vpc.main.id
   }

   resource "aws_route_table" "public" {
     vpc_id = aws_vpc.main.id
     route {
       cidr_block = "0.0.0.0/0"
       gateway_id = aws_internet_gateway.main.id
     }
   }

   resource "aws_route_table_association" "public" {
     count          = 2
     subnet_id      = aws_subnet.public[count.index].id
     route_table_id = aws_route_table.public.id
   }

   data "aws_availability_zones" "available" {}
