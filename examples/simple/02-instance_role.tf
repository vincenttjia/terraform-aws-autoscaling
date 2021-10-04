module "instance_profile" {
  source = "github.com/traveloka/terraform-aws-iam-role.git//modules/instance?ref=v3.0.0"

  service_name   = "fprbe"
  cluster_role   = "app"
  product_domain = "fpr"
  environment    = "staging"
}
