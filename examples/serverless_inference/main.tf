# ---------------------------------------------------------------------------------------------------------------------
# Example Serverless Endpoint
# ---------------------------------------------------------------------------------------------------------------------

module "huggingface_sagemaker" {
  source               = "../.."
  name_prefix          = "sdxl-turbo"
  pytorch_version      = "1.9.1"
  transformers_version = "4.12.3"
  hf_model_id          = "stabilityai/sdxl-turbo"
  hf_task              = "text-to-image"
  instance_type        = "gpu"
  region               = "us-east-1"
  serverless_config = {
    max_concurrency   = 1
    memory_size_in_mb = 1024
  }
}
