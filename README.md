# terraform-aws-autoscaling

[![Terraform Version](https://img.shields.io/badge/Terraform%20Version->=0.12.0,<0.12.31-blue.svg)](https://releases.hashicorp.com/terraform/)
[![Release](https://img.shields.io/github/release/traveloka/terraform-aws-autoscaling.svg)](https://github.com/traveloka/terraform-aws-autoscaling/releases)
[![Last Commit](https://img.shields.io/github/last-commit/traveloka/terraform-aws-autoscaling.svg)](https://github.com/traveloka/terraform-aws-autoscaling/commits/master)
[![Issues](https://img.shields.io/github/issues/traveloka/terraform-aws-autoscaling.svg)](https://github.com/traveloka/terraform-aws-autoscaling/issues)
[![Pull Requests](https://img.shields.io/github/issues-pr/traveloka/terraform-aws-autoscaling.svg)](https://github.com/traveloka/terraform-aws-autoscaling/pulls)
[![License](https://img.shields.io/github/license/traveloka/terraform-aws-autoscaling.svg)](https://github.com/traveloka/terraform-aws-autoscaling/blob/master/LICENSE)
![Open Source Love](https://badges.frapsoft.com/os/v1/open-source.png?v=103)

## Description

A terraform module which provisions an auto scaling group along with its launch configuration. 


## Table of Content

* [terraform-aws-autoscaling](#terraform-aws-autoscaling)
   * [Description](#description)
   * [Dependencies](#dependencies)
   * [Getting Started](#getting-started)
      * [Conventions](#conventions)
      * [Behaviour](#behaviour)
      * [Migration from pre-launch-template versions](#migration-from-pre-launch-template-versions)
      * [Switching between plain launch template and mixed instance policy](#switching-between-plain-launch-template-and-mixed-instance-policy)
   * [Examples](#examples)
   * [Terraform Version](#terraform-version)
   * [Requirements](#requirements)
   * [Providers](#providers)
   * [Modules](#modules)
   * [Resources](#resources)
   * [Inputs](#inputs)
   * [Outputs](#outputs)
   * [Authors](#authors)
   * [Contributing](#contributing)
   * [License](#license)


## Dependencies

This Terraform module have no dependencies to another modules


## Getting Started

### Conventions
 - the auto scaling group will have `Service`, `Cluster`, `Environment`, and `ProductDomain` tags by default, which are propagated to all instances it spawns

### Behaviour
- To specify on-demand instance types, use the `launch_template_overrides` variable. Auto Scaling will launch instances based on the order of preference specified in that list. ["`c5.large`", "`c4.large`", "`m5.large`"] means the ASG will always try to launch `c5.large` if it's available, falling back to `c4.large` if it's not available, and falling back to `m5.large` if the previous two aren't available
- On the first deployment, this module will provision an ASG with a launch template that select the most recent AMI that passes through the given `image_filters`
- Each time there's a change in the values of the `module.asg_name`'s keepers (e.g. security group, AMI ID), a new ASG will be provisioned by terraform, and the old one will later be destroyed (doing the "simple swap" deployment strategy).
- When there's a change in launch template parameters' values, terraform will create a new launch template version unless the new configuration is already the same as the latest version of the launch template (e.g. when the launch template had been updated externally).

### Migration from pre-launch-template versions
```bash
terraform init
terraform state rm module.<this module name in your terraform code>.module.random_lc
terraform apply
```

### Switching between plain launch template and mixed instance policy
switching to plain launch template
```hcl
module "asg" {
  source = "github.com/traveloka/terraform-aws-autoscaling?ref=v0.3.1"
  # ...
  use_mixed_instance_policy = false
  launch_template_overrides = [
    {
      "instance_type" = "c4.large" # this (the first element) will be the launch template's instance type
    },
    {
      "instance_type" = "t3.medium"
    },
  ]
}

```

switching to mixed instance policy
```hcl
module "asg" {
  source = "github.com/traveloka/terraform-aws-autoscaling?ref=v0.3.1"
  # ...
  use_mixed_instance_policy = true
}

```

## Examples

* [Simple](https://github.com/traveloka/terraform-aws-autoscaling/tree/main/examples/simple)
* [Public](https://github.com/traveloka/terraform-aws-autoscaling/tree/main/examples/public)

## Terraform Version

This module was created on 15/8/2018.
The latest stable version of Terraform which this module tested working is Terraform 0.12.31 on 28/09/2021.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_asg_name"></a> [asg\_name](#module\_asg\_name) | github.com/traveloka/terraform-aws-resource-naming.git | v0.19.1 |
| <a name="module_launch_template_name"></a> [launch\_template\_name](#module\_launch\_template\_name) | github.com/traveloka/terraform-aws-resource-naming.git | v0.19.1 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_launch_template.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_ami.latest_service_image](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application"></a> [application](#input\_application) | Application type that the ASG's instances will serve | `string` | n/a | yes |
| <a name="input_asg_clb_names"></a> [asg\_clb\_names](#input\_asg\_clb\_names) | A list of classic load balancer names to add to the autoscaling group | `list(string)` | `[]` | no |
| <a name="input_asg_default_cooldown"></a> [asg\_default\_cooldown](#input\_asg\_default\_cooldown) | Time, in seconds, the minimum interval of two scaling activities | `string` | `"300"` | no |
| <a name="input_asg_enabled_metrics"></a> [asg\_enabled\_metrics](#input\_asg\_enabled\_metrics) | The list of ASG metrics to collect | `list(string)` | <pre>[<br>  "GroupMinSize",<br>  "GroupMaxSize",<br>  "GroupDesiredCapacity",<br>  "GroupInServiceInstances",<br>  "GroupPendingInstances",<br>  "GroupStandbyInstances",<br>  "GroupTerminatingInstances",<br>  "GroupTotalInstances"<br>]</pre> | no |
| <a name="input_asg_health_check_grace_period"></a> [asg\_health\_check\_grace\_period](#input\_asg\_health\_check\_grace\_period) | Time, in seconds, to wait for new instances before checking their health | `string` | `"300"` | no |
| <a name="input_asg_health_check_type"></a> [asg\_health\_check\_type](#input\_asg\_health\_check\_type) | Controls how ASG health checking is done | `string` | `"ELB"` | no |
| <a name="input_asg_lb_target_group_arns"></a> [asg\_lb\_target\_group\_arns](#input\_asg\_lb\_target\_group\_arns) | The created ASG will be attached to this target group | `list(string)` | `[]` | no |
| <a name="input_asg_max_capacity"></a> [asg\_max\_capacity](#input\_asg\_max\_capacity) | The created ASG will have this number of instances at maximum | `string` | `"0"` | no |
| <a name="input_asg_metrics_granularity"></a> [asg\_metrics\_granularity](#input\_asg\_metrics\_granularity) | The granularity to associate with the metrics to collect | `string` | `"1Minute"` | no |
| <a name="input_asg_min_capacity"></a> [asg\_min\_capacity](#input\_asg\_min\_capacity) | The created ASG will have this number of instances at minimum | `string` | `"0"` | no |
| <a name="input_asg_placement_group"></a> [asg\_placement\_group](#input\_asg\_placement\_group) | The placement group for the spawned instances | `string` | `""` | no |
| <a name="input_asg_service_linked_role_arn"></a> [asg\_service\_linked\_role\_arn](#input\_asg\_service\_linked\_role\_arn) | The ARN of the service-linked role that the ASG will use to call other AWS services | `string` | `""` | no |
| <a name="input_asg_tags"></a> [asg\_tags](#input\_asg\_tags) | The created ASG will have these tags applied over the default ones (see main.tf) | `list(map(string))` | `[]` | no |
| <a name="input_asg_termination_policies"></a> [asg\_termination\_policies](#input\_asg\_termination\_policies) | Specify policies that the auto scaling group should use to terminate its instances | `list(string)` | <pre>[<br>  "Default"<br>]</pre> | no |
| <a name="input_asg_vpc_zone_identifier"></a> [asg\_vpc\_zone\_identifier](#input\_asg\_vpc\_zone\_identifier) | The created ASG will spawn instances to these subnet IDs | `list(string)` | n/a | yes |
| <a name="input_asg_wait_for_capacity_timeout"></a> [asg\_wait\_for\_capacity\_timeout](#input\_asg\_wait\_for\_capacity\_timeout) | A maximum duration that Terraform should wait for ASG instances to be healthy before timing out | `string` | n/a | yes |
| <a name="input_asg_wait_for_elb_capacity"></a> [asg\_wait\_for\_elb\_capacity](#input\_asg\_wait\_for\_elb\_capacity) | Terraform will wait for exactly this number of healthy instances in all attached load balancers on both create and update operations. If left to default, the value is set to asg\_min\_capacity | `string` | `""` | no |
| <a name="input_associate_public_ip"></a> [associate\_public\_ip](#input\_associate\_public\_ip) | Whether to associate public IP to the instance | `string` | `"false"` | no |
| <a name="input_cluster_role"></a> [cluster\_role](#input\_cluster\_role) | Primary role/function of the cluster | `string` | `"app"` | no |
| <a name="input_cpu_credits"></a> [cpu\_credits](#input\_cpu\_credits) | The credit option for CPU usage, can be either 'standard' or 'unlimited' | `string` | `"unlimited"` | no |
| <a name="input_delete_network_interface_on_termination"></a> [delete\_network\_interface\_on\_termination](#input\_delete\_network\_interface\_on\_termination) | Whether the network interface will be deleted on termination | `string` | `"true"` | no |
| <a name="input_delete_on_termination"></a> [delete\_on\_termination](#input\_delete\_on\_termination) | Whether the volume should be destroyed on instance termination | `string` | `"true"` | no |
| <a name="input_description"></a> [description](#input\_description) | Free form description of this ASG and its instances | `string` | n/a | yes |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | whether to protect your instance from accidently being terminated from console or api | `bool` | `false` | no |
| <a name="input_ebs_encryption"></a> [ebs\_encryption](#input\_ebs\_encryption) | Whether the volume will be encrypted or not | `string` | `"false"` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | The spawned instances will have EBS optimization if enabled | `string` | `"false"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The created resources will belong to this infrastructure environment | `string` | n/a | yes |
| <a name="input_image_filters"></a> [image\_filters](#input\_image\_filters) | The AMI search filters. The most recent AMI that pass this filter will be deployed to the ASG. See https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-images.html | <pre>list(object({<br>    name   = string,<br>    values = list(string)<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_image_owners"></a> [image\_owners](#input\_image\_owners) | List of AMI owners to limit search. This becomes required starting terraform-provider-aws v2 (https://www.terraform.io/docs/providers/aws/guides/version-2-upgrade.html#owners-argument-now-required) | `list(string)` | n/a | yes |
| <a name="input_instance_profile_name"></a> [instance\_profile\_name](#input\_instance\_profile\_name) | The spawned instances will have this IAM profile | `string` | n/a | yes |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | The spawned instances will have this SSH key name | `string` | `""` | no |
| <a name="input_launch_template_overrides"></a> [launch\_template\_overrides](#input\_launch\_template\_overrides) | List of nested arguments provides the ability to specify multiple instance types. See https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html#override<br>  When using plain launch template, the first element's instance\_type will be used as the launch template instance type. | `list(map(string))` | <pre>[<br>  {<br>    "instance_type": "c4.large"<br>  },<br>  {<br>    "instance_type": "t3.medium"<br>  }<br>]</pre> | no |
| <a name="input_mixed_instances_distribution"></a> [mixed\_instances\_distribution](#input\_mixed\_instances\_distribution) | Specify the distribution of on-demand instances and spot instances. See https://docs.aws.amazon.com/autoscaling/ec2/APIReference/API_InstancesDistribution.html | `map(string)` | <pre>{<br>  "on_demand_allocation_strategy": "prioritized",<br>  "on_demand_base_capacity": "0",<br>  "on_demand_percentage_above_base_capacity": "100",<br>  "spot_allocation_strategy": "lowest-price",<br>  "spot_instance_pools": "2",<br>  "spot_max_price": ""<br>}</pre> | no |
| <a name="input_monitoring"></a> [monitoring](#input\_monitoring) | The spawned instances will have enhanced monitoring if enabled | `string` | `"true"` | no |
| <a name="input_product_domain"></a> [product\_domain](#input\_product\_domain) | Abbreviation of the product domain this ASG and its instances belongs to | `string` | n/a | yes |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | The spawned instances will have these security groups | `list(string)` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | The name of the service | `string` | n/a | yes |
| <a name="input_use_mixed_instances_policy"></a> [use\_mixed\_instances\_policy](#input\_use\_mixed\_instances\_policy) | Whether to use ASG mixed instances policy or the plain launch template | `bool` | `true` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | The spawned instances will have this user data. Use the rendered value of a terraform's `template_cloudinit_config` data | `string` | `" "` | no |
| <a name="input_volume_size"></a> [volume\_size](#input\_volume\_size) | The size of the volume in gigabytes | `string` | `"8"` | no |
| <a name="input_volume_type"></a> [volume\_type](#input\_volume\_type) | The type of volume. Can be standard, gp2, or io1 | `string` | `"gp2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_asg_desired_capacity"></a> [asg\_desired\_capacity](#output\_asg\_desired\_capacity) | The desired capacity of the auto scaling group; it may be useful when doing blue/green asg deployment (create a new asg while copying the old's capacity) |
| <a name="output_asg_name"></a> [asg\_name](#output\_asg\_name) | The name of the auto scaling group |
| <a name="output_launch_template_name"></a> [launch\_template\_name](#output\_launch\_template\_name) | The name of the launch template used by the auto scaling group |
| <a name="output_resource_naming_launch_template"></a> [resource\_naming\_launch\_template](#output\_resource\_naming\_launch\_template) | The name of the launch template generated by resource-naming module. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors
* [Salvian Reynaldi](https://github.com/salvianreynaldi)

## Contributing

This module accepting or open for any contributions from anyone, please see the [CONTRIBUTING.md](https://github.com/traveloka/terraform-aws-autoscaling/blob/master/CONTRIBUTING.md) for more detail about how to contribute to this module.

## License

This module is under Apache License 2.0 - see the [LICENSE](https://github.com/traveloka/terraform-aws-autoscaling/blob/master/LICENSE) file for details.
