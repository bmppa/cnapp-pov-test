output "public_ips" {
  value = {
    for name, instance in aws_instance.server :
    name => instance.public_ip
  }
}
output "ecr_repo" {
  value = aws_ecr_repository.repo.repository_url
}
output "private_key" {
  value     = tls_private_key.private-key.private_key_pem
  sensitive = true
}
output "eks_cluster" {
  value = aws_eks_cluster.my_eks_cluster.name
}
output "mongodb_s3_bucket" {
  value = aws_s3_bucket.db-bkp.bucket
}
output "sensitive_s3_bucket" {
  value = aws_s3_bucket.s3_bucket.bucket
}
output "aws_account" {
  value = data.aws_caller_identity.current.id
}