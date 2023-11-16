# internship-proxy-infra

This is a sample repo containing infrastructure configuration for Internship which aims to solve problem with access to local computer used as a deployment server.

Local computer should be used for application deployment, potentially as a host for CI/CD runners. It has a static Public IP assigned to it and is connected to local network. Due to local network configuration, this computer can't be reached via it's Public IP from within the LAN. This causes access issues for interns as well as mentors, coordinators and other participants in the internship process. To access application from the office WiFi, one would have to map the domain to computer's local IP. Remote users don't have this problem. Using this setup is confusing, time consuming and prone to errors. Following setup aims to solve this issue.

## Architectural overview

There are two main parts of infrastructure, local computer (upstream server) and EC2 instance.

- EC2 instance which serves only as reverse proxy tunneling the traffic to upstream server
- Local computer (upstream server) dedicated for application deployment, potentially as a host for CI/CD runners. It has a static Public IP assigned to it and is connected to local network.

### EC2 instance

EC2 instance is dedicated to serve only as reverse proxy. It has elastic IP attached to it and DNS configuration needs to be pointing the wildcard subdomain to it. Nginx is deployed in docker container which serves as L4 reverse proxy tunneling traffic to upstream server. This setup allows us to eliminate connectivity issues from within office.

All configuration files are present in `ec2` directory:

```bash
./ec2
├── docker
│   ├── docker-compose.yaml
│   ├── nginx.conf
│   └── templates
│       └── default.conf.template
└── terraform
    ├── ec2.tf
    ├── kms.tf
    ├── main.tf
    ├── network.tf
    ├── output.tf
    ├── scripts
    │   └── cloud_init.yaml
    ├── security.tf
    ├── terraform.tfvars.example
    └── variables.tf
```

Terraform module contains simple configuration to deploy EC2 instance (default `t3.micro`) along with necessary network and security configuration. Cloud init configuration will install docker and docker compose. Elastic IP is currently included in terraform state. Potentially, this could be a separate resource (manually or automatically provisioned). Terraform state is currently held locally. If needed, it could be moved to an S3 bucket.

Docker directory contains `docker-compose.yaml` which provisions Nginx configured as reverse proxy. The only variable user needs to provide is `TARGET_SERVER` IP address. This value is used in `default.conf.template` to define upstream server IP address. This Nginx service has two separate servers listening on ports 80 and 443 and proxies connection as is. The HTTP server DOES NOT redirect HTTP connections to HTTPS server. HTTPS upgrade is handled by the upstream server's Nginx server.

### Upstream server

Upstream server is dedicated for application deployment, potentially as a host for CI/CD runners. It needs to have Public IP assigned. There are two options for application deployment, docker compose and k3s. All configuration files and sample applications are present in `upstream` directory:

```bash
./upstream
├── docker-compose
│   ├── app1
│   │   └── docker-compose.yaml
│   ├── app2
│   │   └── docker-compose.yaml
│   └── nginx
│       ├── docker-compose.yaml
│       └── templates
│           └── default.conf.template
└── k3s
    ├── deployment
    │   ├── app-of-apps
    │   │   ├── Chart.yaml
    │   │   ├── README.md
    │   │   ├── templates
    │   │   │   ├── app-of-apps.yaml
    │   │   │   ├── cert-manager.yaml
    │   │   │   └── ingress-nginx.yaml
    │   │   └── values.yaml
    │   ├── argocd
    │   │   └── values.yaml
    │   └── cert-manager
    │       ├── cert-manager.yaml
    │       ├── cluster-issuer.yaml
    │       └── dev-cluster-issuer.yaml
    └── setup.sh
```

#### Docker compose

Applications can be deployed using separate docker compose definitions. Directory `./upstream/docker-compose` contains sample configuration which can be used for deployment. It contains Nginx configured as L7 reverse proxy and two sample apps, `app1` and `app2`. They are deployed using separate docker compose definitions. Routing is handled by Nginx which can be deployed using docker compose configuration in `nginx` directory. Each docker compose creates docker network with name based on directory it lives in and `_default` suffix (e.g. `app1_default`). These networks are attached to Nginx docker compose network. HTTP proxy configuration for each service should be placed in Nginx's template file `./templates/default.conf.template`. Example is provided in current file.

#### k3s

Another option is to deploy applications in `k3s` cluster. For this purpose, there is a `setup.sh` script present in `./upstream/k3s` directory. It will provision k3s cluster without `traefik`, deploy ArgoCD and `app-of-apps` application. App of apps pattern is common among ArgoCD users. It creates and Argo application which manages all other applications. In this case, it provisions only `ingress-nginx`, `cert-manager` and two `cluster-issuers`. `Letsencrypt` cluster issuer uses production Letsencrypt, while `letsencrypt-dev` cluster issuer uses Letsencrypt staging server to provision certificates. App of apps is using this public github repo as source of truth. By default, ArgoCD is exposed on localhost using `argocd.localhost` URL. If needed, it can be exposed using internship domain. ArgoCD is not meant to be used by interns, but merely as a tool for provisioning the basic infrastructure services.
