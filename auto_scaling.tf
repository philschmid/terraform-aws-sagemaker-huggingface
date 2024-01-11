# ------------------------------------------------------------------------------
# AutoScaling configuration
# ------------------------------------------------------------------------------


locals {
  use_autoscaling = var.autoscaling.max_capacity != null && var.autoscaling.scaling_target_invocations != null && !local.sagemaker_endpoint_type.serverless ? 1 : 0
}

resource "aws_appautoscaling_target" "sagemaker_target" {
  count              = local.use_autoscaling
  min_capacity       = var.autoscaling.min_capacity
  max_capacity       = var.autoscaling.max_capacity
  resource_id        = "endpoint/${aws_sagemaker_endpoint.huggingface.name}/variant/AllTraffic"
  scalable_dimension = "sagemaker:variant:DesiredInstanceCount"
  service_namespace  = "sagemaker"
}

resource "aws_appautoscaling_policy" "sagemaker_policy" {
  count              = local.use_autoscaling
  name               = "${var.name_prefix}-scaling-target-${random_string.ressource_id.result}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.sagemaker_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.sagemaker_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.sagemaker_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "SageMakerVariantInvocationsPerInstance"
    }
    target_value       = var.autoscaling.scaling_target_invocations
    scale_in_cooldown  = var.autoscaling.scale_in_cooldown
    scale_out_cooldown = var.autoscaling.scale_out_cooldown
  }
}
