output "images_bucket_name" {
  value = aws_s3_bucket.images.id
}

output "images_bucket_arn" {
  value = aws_s3_bucket.images.arn
}
