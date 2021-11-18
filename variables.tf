# -------------------------------------------------------------------
# REQUIRED VARIABLES
# -------------------------------------------------------------------

variable "project_id" {
  # Pass in the project ID that pre-exists
  description = "The Project ID"
  type        = string
}

variable "gcp_credentials" {
  type        = string
  sensitive   = true
  description = "Google Cloud service account credentials"
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "subnetwork_name" {
  description = "The name of the subnetwork."
  type        = string
}

# -------------------------------------------------------------------
# OPTIONAL VARIABLES
# These parameters have reasonable defaults.
# -------------------------------------------------------------------

variable "region" {
  # Create a VPC
  description = "VPC region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  # Create a subnet
  description = "VPC Zone"
  type        = string
  default     = "us-central1-b"
}

variable "tags_squid" {
  default = ["squid"]
}

variable "labels_squid" {
  default = {}
}

variable "vm_size_squid" {
  description = "Node instance type"
  type        = string
  default     = "g1-small"
}

variable "squid_install_script_path" {
  description = "The script path to install squid proxy."
  type        = string
  default     = "./installer/squid_install.sh"
}

# -------------------------
# FIREWALL VARIABLES
# -------------------------

variable "fw_squid_port_source_range" {
  description = "The subnet ranges."
  type        = list
  default     = ["10.0.0.0/24"]
}