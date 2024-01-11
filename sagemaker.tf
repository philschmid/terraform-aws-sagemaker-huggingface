
# ------------------------------------------------------------------------------
# Container Image
# ------------------------------------------------------------------------------


data "aws_sagemaker_prebuilt_ecr_image" "deploy_image" {
  repository_name = local.repository_name
  image_tag       = var.pytorch_version != null ? local.pytorch_image_tag[local.image_key] : local.tensorflow_image_tag[local.image_key]
}

# ------------------------------------------------------------------------------
# SageMaker Model
# ------------------------------------------------------------------------------

resource "aws_sagemaker_model" "model_with_model_artifact" {
  count              = var.model_data != null && var.hf_model_id == null ? 1 : 0
  name               = "${var.name_prefix}-model-${random_string.ressource_id.result}"
  execution_role_arn = local.role_arn
  tags               = var.tags

  primary_container {
    # CPU Image
    image          = data.aws_sagemaker_prebuilt_ecr_image.deploy_image.registry_path
    model_data_url = var.model_data
    environment = {
      HF_TASK = var.hf_task
    }
  }
}


resource "aws_sagemaker_model" "model_with_hub_model" {
  count              = var.model_data == null && var.hf_model_id != null ? 1 : 0
  name               = "${var.name_prefix}-model-${random_string.ressource_id.result}"
  execution_role_arn = local.role_arn
  tags               = var.tags

  primary_container {
    image = data.aws_sagemaker_prebuilt_ecr_image.deploy_image.registry_path
    environment = {
      HF_TASK           = var.hf_task
      HF_MODEL_ID       = var.hf_model_id
      HF_API_TOKEN      = var.hf_api_token
      HF_MODEL_REVISION = var.hf_model_revision
    }
  }
}

locals {
  sagemaker_model = var.model_data != null && var.hf_model_id == null ? aws_sagemaker_model.model_with_model_artifact[0] : aws_sagemaker_model.model_with_hub_model[0]
}

# ------------------------------------------------------------------------------
# SageMaker Endpoint configuration
# ------------------------------------------------------------------------------

resource "aws_sagemaker_endpoint_configuration" "huggingface" {
  count = local.sagemaker_endpoint_type.real_time ? 1 : 0
  name  = "${var.name_prefix}-ep-config-${random_string.ressource_id.result}"
  tags  = var.tags


  production_variants {
    variant_name           = "AllTraffic"
    model_name             = local.sagemaker_model.name
    initial_instance_count = var.instance_count
    instance_type          = var.instance_type
  }
}


resource "aws_sagemaker_endpoint_configuration" "huggingface_async" {
  count = local.sagemaker_endpoint_type.asynchronous ? 1 : 0
  name  = "${var.name_prefix}-ep-config-${random_string.ressource_id.result}"
  tags  = var.tags


  production_variants {
    variant_name           = "AllTraffic"
    model_name             = local.sagemaker_model.name
    initial_instance_count = var.instance_count
    instance_type          = var.instance_type
  }
  async_inference_config {
    output_config {
      s3_output_path = var.async_config.s3_output_path
      kms_key_id     = var.async_config.kms_key_id
      # notification_config {
      #   error_topic   = var.async_config.sns_error_topic
      #   success_topic = var.async_config.sns_success_topic
      # }
    }
  }
}


resource "aws_sagemaker_endpoint_configuration" "huggingface_serverless" {
  count = local.sagemaker_endpoint_type.serverless ? 1 : 0
  name  = "${var.name_prefix}-ep-config-${random_string.ressource_id.result}"
  tags  = var.tags


  production_variants {
    variant_name           = "AllTraffic"
    model_name             = local.sagemaker_model.name

    serverless_config {
      max_concurrency   = var.serverless_config.max_concurrency
      memory_size_in_mb = var.serverless_config.memory_size_in_mb
    }
  }
}


locals {
  sagemaker_endpoint_config = (
    local.sagemaker_endpoint_type.real_time ?
      aws_sagemaker_endpoint_configuration.huggingface[0] : (
        local.sagemaker_endpoint_type.asynchronous ?
          aws_sagemaker_endpoint_configuration.huggingface_async[0] : (
            local.sagemaker_endpoint_type.serverless ?
              aws_sagemaker_endpoint_configuration.huggingface_serverless[0] : null
          )
      )
  )
}

# ------------------------------------------------------------------------------
# SageMaker Endpoint
# ------------------------------------------------------------------------------


resource "aws_sagemaker_endpoint" "huggingface" {
  name = "${var.name_prefix}-ep-${random_string.ressource_id.result}"
  tags = var.tags

  endpoint_config_name = local.sagemaker_endpoint_config.name
}
