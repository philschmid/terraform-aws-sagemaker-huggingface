# ---------------------------------------------------------------------------------------------------------------------
# Example Asynchronous Endpoint
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region  = "us-east-1"
  profile = "hf-sm"
}

# create bucket for async inference for inputs & outputs
resource "aws_s3_bucket" "async_inference_bucket" {
  bucket = "async-inference-bucket"
}


module "huggingface_sagemaker" {
  source               = "../../"
  name_prefix          = "deploy-hub"
  pytorch_version      = "1.9.1"
  transformers_version = "4.12.3"
  instance_type        = "ml.g4dn.xlarge"
  hf_model_id          = "distilbert-base-uncased-finetuned-sst-2-english"
  hf_task              = "text-classification"
  async_config = {
    # needs to be a s3 uri
    s3_output_path = "s3://async-inference-bucket/async-distilbert"
    # (Optional) specify Amazon SNS topics and custom KMS Key
    # kms_key_id        = "string"
    # sns_error_topic   = "arn:aws:sns:aws-region:account-id:topic-name"
    # sns_success_topic = "arn:aws:sns:aws-region:account-id:topic-name"
  }
  autoscaling = {
    min_capacity           = 0
    max_capacity           = 1
    target_value           = 0.5
    predefined_metric_type = "HasBacklogWithoutCapacity"
  }
}
