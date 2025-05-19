# AWSプロバイダーの設定です。
provider "aws" {
  region = "us-west-2"
}

# VPCの作成
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# パブリックサブネットの作成
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# インターネットゲートウェイの作成
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# ルートテーブルの作成
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# サブネットとルートテーブルの関連付け
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# セキュリティグループの作成
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.main.id

  # 脆弱性のあるルール（全ポートを開放）
  ingress {
    description = "Allow all inbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

# EC2インスタンスの作成
resource "aws_instance" "web" {
  ami                    = "ami-0c55b159cbfafe1f0"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.web.id]

  # 脆弱性のある設定（パブリックIPを有効化）
  associate_public_ip_address = true

  # 脆弱性のある設定（ルートユーザーを使用）
  user_data = <<-EOF
              #!/bin/bash
              echo "root:Password123!" | chpasswd
              sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
              systemctl restart sshd
              EOF

  tags = {
    Name = "web-server"
  }
}

# S3バケットの作成（脆弱性のある設定）
resource "aws_s3_bucket" "data" {
  bucket = "my-sensitive-data-bucket"

  tags = {
    Name = "sensitive-data"
  }
}

# S3バケットの公開アクセス設定（脆弱性のある設定）
resource "aws_s3_bucket_public_access_block" "data" {
  bucket = aws_s3_bucket.data.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3バケットポリシー（脆弱性のある設定）
resource "aws_s3_bucket_policy" "data" {
  bucket = aws_s3_bucket.data.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Principal = "*"
        Action    = "s3:GetObject"
        Effect    = "Allow"
        Resource  = "${aws_s3_bucket.data.arn}/*"
      },
    ]
  })
}

# IAMユーザーの作成（脆弱性のある設定）
resource "aws_iam_user" "admin" {
  name = "admin-user"
}

# IAMポリシーの作成（脆弱性のある設定）
resource "aws_iam_user_policy" "admin" {
  name = "admin-policy"
  user = aws_iam_user.admin.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "*"
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# 出力値の定義
output "instance_public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.data.bucket
}
