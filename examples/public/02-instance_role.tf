module "instance_profile" {
  source = "github.com/traveloka/terraform-aws-iam-role.git//modules/instance?ref=v3.0.0"

  service_name   = "paybe"
  cluster_role   = "app"
  product_domain = "pay"
  environment    = "staging"
}
