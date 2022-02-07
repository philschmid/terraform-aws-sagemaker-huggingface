
# Configure the AWS Provider
provider "aws" {
  region  = "us-east-1"
  profile = "hf-sm"

}

# ---------------------------------------------------------------------------------------------------------------------
# Example Deploy from HuggingFace Hub
# ---------------------------------------------------------------------------------------------------------------------

module "huggingface_sagemaker" {
  source = "../../"
  name_prefix              = "test"
  pytorch_version          = "1.9.1"
  transformers_version     = "4.12.3"
  instance_type            = "ml.g4dn.xlarge"
  instance_count           = 1 # default is 1
  sagemaker_execution_role = "sagemaker_execution_role"
  hf_model_id              = "distilbert-base-uncased-finetuned-sst-2-english"
  hf_task                  = "text-classification"
}

# ---------------------------------------------------------------------------------------------------------------------
# Example Deploy from Amazon S3
# ---------------------------------------------------------------------------------------------------------------------


# module "huggingface_sagemaker" {
#   source = "../"
#   name_prefix              = "test"
#   pytorch_version          = "1.9.1"
#   transformers_version     = "4.12.3"
#   instance_type            = "g4dn.xlarge"
#   sagemaker_execution_role = "sagemaker_execution_role"
#   model_data              = "xxx"
#   hf_task                  = "text-classification"
# }