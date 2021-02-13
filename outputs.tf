output "vpc_id" {
  description = "VPC id"
  value       = aws_vpc.this.id
}

output "public_subnets_ids" {
  description = "Public subnets ids"
  value       = aws_subnet.public.*.id
}

output "private_subnets_ids" {
  description = "Private subnets ids"
  value       = aws_subnet.private.*.id
}
