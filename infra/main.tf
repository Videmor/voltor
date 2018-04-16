# create loadbalancer
resource "digitalocean_loadbalancer" "voltor" {
  name   = "loadbalancer-voltor"
  region = "nyc3"

  forwarding_rule {
    entry_port = 80
    entry_protocol = "http"

    target_port = 3000
    target_protocol = "http"
  }

  healthcheck {
    port     = 3000
    protocol = "http"
    path     = "/"
  }

  droplet_tag = "${digitalocean_tag.voltor.name}"
}

# Create a new tag
resource "digitalocean_tag" "voltor" {
  name = "voltors"
}

# create droplet
resource "digitalocean_droplet" "voltor" {
  count                   = 2
  image                   = "${var.image_id}"
  name                    = "voltor-02"
  region                  = "nyc3"
  size                    = "512mb"
  tags                    = ["${digitalocean_tag.voltor.id}"]
  ssh_keys                = [20009875]
  lifecycle {
    create_before_destroy = true
  }
  
  provisioner "local-exec" {
    command = "sleep 160 && curl ${self.ipv4_address}:3000"
  }

  user_data               = <<EOF
#cloud-config
coreos:
  units:
    - name: "voltor.service"
      command: "start"
      content: |
        [Unit]
        Description       = Voltor
        After             = docker.service

        [Service]
        ExecStart=/usr/bin/docker run -d -p 3000:3000 voltor
EOF
}
