# Terraform Enterprise FDO - Podman

These are the manual steps for installing TFE FDO on podman

## Prerequisites

- Have an instance
- Have your certificates

# Installation

## Install the Podman software

- Install the Podman software
```
dnf module install -y container-tools
dnf install -y podman-docker
```
- Enable the podman socket
```
systemctl enable --now podman.socket
```
## install and configure TFE

- Login to download the image
```
echo "<HASHICORP_LICENSE>" |  podman login --username terraform images.releases.hashicorp.com --password-stdin
```
- Pull the image
```
podman pull images.releases.hashicorp.com/hashicorp/terraform-enterprise:v202312-1
```
- Have a `/opt/tfe/tfe.yaml` file like the following
```
---
apiVersion: "v1"
kind: "Pod"
metadata:
  labels:
    app: "terraform-enterprise"
  name: "terraform-enterprise"
spec:
  restartPolicy: "Never"
  containers:
  - env:
    - name: "TFE_OPERATIONAL_MODE"
      value: "disk"
    - name: "TFE_LICENSE"
      value: "<Hashicorp license>"
    - name: "TFE_HTTP_PORT"
      value: "8080"
    - name: "TFE_HTTPS_PORT"
      value: "8443"
    - name: "TFE_HOSTNAME"
      value: "tfe32.aws.munnep.com"
    - name: "TFE_TLS_CERT_FILE"
      value: "/etc/ssl/private/terraform-enterprise/cert.pem"
    - name: "TFE_TLS_KEY_FILE"
      value: "/etc/ssl/private/terraform-enterprise/key.pem"
    - name: "TFE_TLS_CA_BUNDLE_FILE"
      value: "/etc/ssl/private/terraform-enterprise/bundle.pem"
    - name: "TFE_DISK_CACHE_VOLUME_NAME"
      value: "terraform-enterprise_terraform-enterprise-cache"
    - name: "TFE_LICENSE_REPORTING_OPT_OUT"
      value: "true"
    - name: "TFE_ENCRYPTION_PASSWORD"
      value: "Password#1"
    image: "images.releases.hashicorp.com/hashicorp/terraform-enterprise:v202312-1"
    name: "terraform-enterprise"
    ports:
    - containerPort: 8080
      hostPort: 80
    - containerPort: 8443
      hostPort: 443
    - containerPort: 9090
      hostPort: 9090
    securityContext:
      capabilities:
        add:
        - "CAP_IPC_LOCK"
      readOnlyRootFilesystem: true
      seLinuxOptions:
        type: "spc_t"
    volumeMounts:
    - mountPath: "/etc/ssl/private/terraform-enterprise"
      name: "certs"
    - mountPath: "/var/log/terraform-enterprise"
      name: "log"
    - mountPath: "/run"
      name: "run"
    - mountPath: "/tmp"
      name: "tmp"
    - mountPath: "/var/lib/terraform-enterprise"
      name: "data"
    - mountPath: "/run/docker.sock"
      name: "docker-sock"
    - mountPath: "/var/cache/tfe-task-worker/terraform"
      name: "terraform-enterprise_terraform-enterprise-cache-pvc"
  volumes:
  - hostPath:
      path: "/opt/tfe/certs"
      type: "Directory"
    name: "certs"
  - emptyDir:
      medium: "Memory"
    name: "log"
  - emptyDir:
      medium: "Memory"
    name: "run"
  - emptyDir:
      medium: "Memory"
    name: "tmp"
  - hostPath:
      path: "/opt/tfe/data"
      type: "Directory"
    name: "data"
  - hostPath:
      path: "/var/run/docker.sock"
      type: "File"
    name: "docker-sock"
  - name: "terraform-enterprise_terraform-enterprise-cache-pvc"
    persistentVolumeClaim:
      claimName: "terraform-enterprise_terraform-enterprise-cache"
```
- start the container
```
podman play kube /opt/fdo/kube.yaml
```
- Get the authentication token
```
podman exec -it terraform-enterprise-terraform-enterprise tfectl admin token
```
- Create your account with above output url
https://tfe32.aws.munnep.com/admin/account/new?token=${IACT_TOKEN}




