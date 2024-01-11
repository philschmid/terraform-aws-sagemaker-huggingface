# ------------------------------------------------------------------------------
# Local configurations
# ------------------------------------------------------------------------------

locals {
    role_arn = var.sagemaker_execution_role != null ? data.aws_iam_role.get_role[0].arn : aws_iam_role.new_role[0].arn
    framework_version = var.pytorch_version != null ? var.pytorch_version : var.tensorflow_version
    repository_name   = var.pytorch_version != null ? "huggingface-pytorch-inference" : "huggingface-tensorflow-inference"
    device            = length(regexall("^ml\\.[g|p{1,3}\\.$]", var.instance_type)) > 0 ? "gpu" : "cpu"
    image_key         = "${local.framework_version}-${local.device}"
    pytorch_image_tag = {
    "1.7.1-gpu" = "1.7.1-transformers${var.transformers_version}-gpu-py36-cu110-ubuntu18.04"
    "1.7.1-cpu" = "1.7.1-transformers${var.transformers_version}-cpu-py36-ubuntu18.04"
    "1.8.1-gpu" = "1.8.1-transformers${var.transformers_version}-gpu-py36-cu111-ubuntu18.04"
    "1.8.1-cpu" = "1.8.1-transformers${var.transformers_version}-cpu-py36-ubuntu18.04"
    "1.9.1-gpu" = "1.9.1-transformers${var.transformers_version}-gpu-py38-cu111-ubuntu20.04"
    "1.9.1-cpu" = "1.9.1-transformers${var.transformers_version}-cpu-py38-ubuntu20.04"
    }
    tensorflow_image_tag = {
    "2.4.1-gpu" = "2.4.1-transformers${var.transformers_version}-gpu-py37-cu110-ubuntu18.04"
    "2.4.1-cpu" = "2.4.1-transformers${var.transformers_version}-cpu-py37-ubuntu18.04"
    "2.5.1-gpu" = "2.5.1-transformers${var.transformers_version}-gpu-py36-cu111-ubuntu18.04"
    "2.5.1-cpu" = "2.5.1-transformers${var.transformers_version}-cpu-py36-ubuntu18.04"
    }
    sagemaker_endpoint_type = {
    real_time = (var.async_config.s3_output_path == null && var.serverless_config.max_concurrency == null) ? true : false
    asynchronous = (var.async_config.s3_output_path != null && var.serverless_config.max_concurrency == null) ? true : false
    serverless = (var.async_config.s3_output_path == null && var.serverless_config.max_concurrency != null) ? true : false
    }
}

# random lowercase string used for naming
resource "random_string" "ressource_id" {
    length  = 8
    lower   = true
    special = false
    upper   = false
    numeric  = false
}
