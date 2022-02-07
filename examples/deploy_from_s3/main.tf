
# Configure the AWS Provider
provider "aws" {
  region  = "us-east-1"
  profile = "hf-sm"

}

# ---------------------------------------------------------------------------------------------------------------------
# Example Deploy from HuggingFace Hub
# ---------------------------------------------------------------------------------------------------------------------

module "huggingface_sagemaker" {
  source               = "../../"
  name_prefix          = "deploy-s3"
  pytorch_version      = "1.9.1"
  transformers_version = "4.12.3"
  instance_type        = "ml.g4dn.xlarge"
  instance_count       = 1 # default is 1
  model_data           = "s3://hf-sagemaker-inference/example_custom_inference/model.tar.gz"
  hf_task              = "text-classification"
}
