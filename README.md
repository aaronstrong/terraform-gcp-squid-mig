# terraform-gcp-squid-mig



<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google-beta_google_compute_autoscaler.default](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_autoscaler) | resource |
| [google-beta_google_compute_forwarding_rule.google_compute_forwarding_rule](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_forwarding_rule) | resource |
| [google-beta_google_compute_region_backend_service.mig](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_region_backend_service) | resource |
| [google_compute_firewall.allow-squid-port](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow-web-egress](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.default-hc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_health_check.autohealing](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |
| [google_compute_instance_group_manager.appserver](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group_manager) | resource |
| [google_compute_instance_template.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) | resource |
| [google_compute_network.network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |
| [google_compute_subnetwork.subnetwork](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_fw_squid_port_source_range"></a> [fw\_squid\_port\_source\_range](#input\_fw\_squid\_port\_source\_range) | The subnet ranges. | `list` | <pre>[<br>  "10.0.0.0/24"<br>]</pre> | no |
| <a name="input_gcp_credentials"></a> [gcp\_credentials](#input\_gcp\_credentials) | Google Cloud service account credentials | `string` | n/a | yes |
| <a name="input_labels_squid"></a> [labels\_squid](#input\_labels\_squid) | n/a | `map` | `{}` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The Project ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | VPC region | `string` | `"us-central1"` | no |
| <a name="input_squid_install_script_path"></a> [squid\_install\_script\_path](#input\_squid\_install\_script\_path) | The script path to install squid proxy. | `string` | `"./installer/squid_install.sh"` | no |
| <a name="input_subnetwork_name"></a> [subnetwork\_name](#input\_subnetwork\_name) | The name of the subnetwork. | `string` | n/a | yes |
| <a name="input_tags_squid"></a> [tags\_squid](#input\_tags\_squid) | n/a | `list` | <pre>[<br>  "squid"<br>]</pre> | no |
| <a name="input_vm_size_squid"></a> [vm\_size\_squid](#input\_vm\_size\_squid) | Node instance type | `string` | `"g1-small"` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | The name of the VPC | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | VPC Zone | `string` | `"us-central1-b"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ilb_address"></a> [ilb\_address](#output\_ilb\_address) | TCP Internal load balancer address. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->