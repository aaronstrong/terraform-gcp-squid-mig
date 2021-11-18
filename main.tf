# -------------------------------------------------------------------
# RETRIEVE PROJECT INFORMATION
# -------------------------------------------------------------------

# Get the VPC name
data "google_compute_network" "network" {
  name    = var.vpc_name
  project = var.project_id
}

data "google_compute_subnetwork" "subnetwork" {
  name    = var.subnetwork_name
  network = local.vpc_network
  region  = var.region
}

# -------------------------------------------------------------------
# SET LOCALS
# -------------------------------------------------------------------

locals {
  vpc_network = data.google_compute_network.network.name
  vpc_id      = data.google_compute_network.network.id
  subnet_name = data.google_compute_subnetwork.subnetwork.name
  subnet_id   = data.google_compute_subnetwork.subnetwork.id
}

# -------------------------------------------------------------------
# CREATE A SWARM like GROUP of SQUID PROXIES using a MANAGED INSTANCE GROUP.
# This will create three firewall rules. One rule to allow for inbound client requests to hit the squid cluser, a 
# second firewall rule to allow outbound access for squid, and a third to allow for the GCP health check probes. 
# -------------------------------------------------------------------

resource "google_compute_firewall" "allow-squid-port" {
  # A firewall rule to allow ingress access to squid inbound for client requests. Tag the
  # squid instances to apply the rule.
  name          = "allow-squid-port"
  network       = local.vpc_network
  direction     = "INGRESS"
  source_ranges = var.fw_squid_port_source_range

  allow {
    protocol = "tcp"
    ports    = ["3128"]
  }
  target_tags = var.tags_squid
}

resource "google_compute_firewall" "allow-web-egress" {
  # Allow Egress HTTP(S) ports based on tags
  name      = "allow-web-egress"
  network   = local.vpc_network
  direction = "EGRESS"
  priority  = "800"
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  target_tags = var.tags_squid
}

resource "google_compute_firewall" "default-hc" {
  // Firewall rule for the GCP Health-check probes
  project = var.project_id
  name    = "firewall-hc"
  network = local.vpc_network
  allow {
    protocol = "tcp"
    ports    = ["443", "80", "3128"]
  }
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
}

# -------------------------------------------------------------------
# CREATE THE SQUID SWARM and all the resources required to build it.
# Create the instance templates, a health check, deploy the instance group, an auto-scaler based on CPU%, 
# a front-end load balancer, and a backend service to direct the load-balancer to.
# -------------------------------------------------------------------

resource "google_compute_instance_template" "default" {
  # Craete the instance template that instances are based off of.
  name                    = "squidserver-template"
  description             = "This template is used to create server instances."
  project                 = var.project_id
  tags                    = var.tags_squid
  labels                  = var.labels_squid
  metadata_startup_script = file(var.squid_install_script_path)
  instance_description    = "Managed by Terraform"
  machine_type            = var.vm_size_squid
  can_ip_forward          = true

  // Create a new boot disk from an image
  disk {
    source_image = "ubuntu-os-cloud/ubuntu-1804-lts"
    auto_delete  = true
    boot         = true
  }

  scheduling {
    automatic_restart   = false
    on_host_maintenance = "TERMINATE"
    preemptible         = true
  }

  network_interface {
    network    = local.vpc_network
    subnetwork = local.subnet_id
    access_config {}
  }
}

# ---------------------------------
# HEALTH CHECK
# --------------------------------

resource "google_compute_health_check" "autohealing" {
  # Create a TCP health check, making sure an instance is healthy
  name                = "autohealing-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2 # 10 seconds

  tcp_health_check {
    port = "3128"
  }
}

# ---------------------------------
# INSANCE GROUP
# ---------------------------------

resource "google_compute_instance_group_manager" "appserver" {
  name               = "igm"
  base_instance_name = "proxy"
  project            = var.project_id
  zone               = var.zone
  target_size        = 2

  version {
    instance_template = google_compute_instance_template.default.id
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.id
    initial_delay_sec = 300
  }
}

# ---------------------------------
# AUTOSCALER
# ---------------------------------

resource "google_compute_autoscaler" "default" {
  # Create an autoscaler based off the CPU% Utilization
  provider = google-beta
  name     = "proxy-autoscaler"
  zone     = var.zone
  target   = google_compute_instance_group_manager.appserver.id
  autoscaling_policy {
    max_replicas    = 4
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}

# ---------------------------------
# Internal Load Balancer
# ---------------------------------

resource "google_compute_forwarding_rule" "google_compute_forwarding_rule" {
  # Deploy an internal TCP forwarding rule
  project               = var.project_id
  name                  = "l4-ilb-forwarding-rule"
  description           = "managed by terraform"
  region                = var.region
  network               = local.vpc_network
  subnetwork            = local.subnet_id
  allow_global_access   = false
  backend_service       = google_compute_region_backend_service.mig.self_link
  provider              = google-beta
  ip_protocol           = "TCP"
  load_balancing_scheme = "INTERNAL"
  all_ports             = true
}

# ---------------------------------
# CREATE THE BACKEND SERVICE
# ---------------------------------

resource "google_compute_region_backend_service" "mig" {
  # Point the internal TCP load balancer to a backend service which is the instance group
  name                            = "squid-proxy-tcp-hc"
  project                         = var.project_id
  provider                        = google-beta
  region                          = var.region
  protocol                        = "TCP"
  load_balancing_scheme           = "INTERNAL"
  network                         = local.vpc_id
  health_checks                   = [google_compute_health_check.autohealing.id]
  connection_draining_timeout_sec = 300
  backend {
    group = google_compute_instance_group_manager.appserver.instance_group
  }
}