# ------------------------------------------------------------------------------
# Output
# ------------------------------------------------------------------------------
output "used_container" {
  description = "Used container for creating the endpoint"
  value       = data.aws_sagemaker_prebuilt_ecr_image.deploy_image.registry_path
}

output "iam_role" {
  description = "IAM role used in the endpoint"
  value       = local.role_arn
}

output "sagemaker_model" {
  description = "SageMaker Model used"
  value       = local.sagemaker_model
}

output "sagemaker_endpoint_configuration" {
  description = "SageMaker endpoint configuration"
  value       = aws_sagemaker_endpoint_configuration.huggingface
}

output "sagemaker_endpoint" {
  description = "SageMaker endpoint"
  value       = aws_sagemaker_endpoint.huggingface
}


output "tags" {
  value = var.tags
}
