
# Estructura del Repositorio

Este repositorio contiene la configuración y despliegue de una aplicación en Google Cloud Platform (GCP) usando Kubernetes, Terraform, ArgoCD, y herramientas como Istio, Prometheus y Grafana.

## Estructura de Directorios

```
./
├── app
│   └── Deployments de la aplicación para ArgoCD
│       ├── Deployment sin canary, exponiendo el servicio por LoadBalancer al puerto 8080 con HPA
│       └── Deployment con canary, exponiendo el servicio en el puerto 443 con certificado autofirmado
├── grafana
│   └── Dashboard de ejemplo para importar como JSON. En la instalación están los predefinidos.
│       - Usuario: admin, Contraseña: grafito
└── k8s-manifests
    └── Configuración del repositorio ArgoCD y configuraciones adicionales para el cluster
    ├── Administration-apps.tf
    │   └── Instalación de herramientas de administración del cluster (Prometheus, Grafana, Vault, Kyverno, Istio).
    ├── Artifactory.tf
    │   └── Creación de Artifactory para alojar imágenes Docker.
    ├── Custom-metric.tf
    │   └── Métrica custom para el HPA del pod de ejemplo.
    ├── Docker.tf
    │   └── Creación de la imagen Docker local y push al Artifactory.
    ├── Dockerfile
    │   └── Configuración para el build de la imagen de la aplicación.
    ├── Main.tf
    │   └── Configuración general de los clusters GKE.
    ├── Networking.tf
    │   └── Creación de VPC y subnets para los clusters.
    ├── Outputs.tf
    │   └── Outputs de los objetos creados (endpoint de los clusters, CA, URL Artifactory).
    ├── pipelines-examples-(jenkins/github).txt
    │   └── Prototipo de pipelines.
    ├── Providers.tf
    │   └── Versiones y requerimientos necesarios.
    ├── Terraform.tfvars
    │   └── Variables y habilitación de la instalación de objetos.
    ├── Variables.tf
    │   └── Variables de la configuración.
```

## Instalación

Para poner en marcha este repositorio, sigue los pasos a continuación:

### 1. Clonar el Repositorio

Clona el repositorio en tu máquina local:

```bash
$ git clone https://github.com/mbarbisan91/hd-gcp.git
$ cd hd-gcp
```

### 2. Inicializar Terraform

Inicializa Terraform para descargar los proveedores necesarios:

```bash
$ terraform init
```

### 3. Modificar Variables

Abre el archivo `variables.tf` y modifica las variables con las configuraciones específicas de tu entorno. Luego aplica la configuración:

```bash
$ terraform apply
```

### 4. Obtener Credenciales del Cluster

Obtén las credenciales de tu cluster para poder ejecutar `kubectl` localmente:

```bash
$ gcloud container clusters get-credentials demo-europe --region europe-west2-a
```

### 5. Aplicar CRDs para ArgoCD

Aplica los CRDs necesarios para ArgoCD desde la consola GCP o de forma local:

```bash
$ kubectl apply -k github.com/argoproj/argo-rollouts/manifests/crds
```

### 6. Copiar el Archivo de GitRepo

Copia el archivo `gitrepo.tf` desde el repositorio:

```bash
$ cp k8s-manifests/gitrepo.tf .
```

### 7. Ejecutar Terraform para Crear ArgoCD

Ejecuta nuevamente Terraform para crear el repositorio de ArgoCD:

```bash
$ terraform apply
```

### 8. Configuración de ArgoCD

Para obtener la contraseña de acceso a ArgoCD:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

**Nota**: Los usuarios y contraseñas fueron creados solo para facilitar la prueba.

Repositorio de la aplicación: [hd-gcp/app](https://github.com/mbarbisan91/hd-gcp/app)

---

## Arquitectura

### Descripción

La arquitectura propuesta se basa en la creación de una VPC compartida con subnets separadas por cluster para asegurar alta disponibilidad (HA). Los despliegues se realizan mediante **ArgoCD**, que instalará todos los servicios necesarios desde los repositorios correspondientes como **Prometheus**, **Grafana**, **Prometheus Adapter**, **Istio**, entre otros.

#### Recovery Time Objective (RTO) y Recovery Point Objective (RPO)

- **RTO (Recovery Time Objective)**: 1 hora (Tiempo para restaurar la aplicación después de una falla).
- **RPO (Recovery Point Objective)**: 5 minutos (Pérdida máxima de datos aceptable).

#### Pasos

1. Se crea una **VPC** compartida entre dos subnets, una por cada cluster.
2. Se despliegan dos clusters en **regiones y zonas diferentes** para cumplir con HA.
3. **ArgoCD** instala todos los servicios necesarios, como **Prometheus**, **Grafana**, **Vault**, **Istio**, etc.
4. El tiempo estimado de despliegue es de aproximadamente 20 minutos.

---

## Pipeline de CI/CD

### Descripción

Se incluyen ejemplos de código de pipelines para **Jenkins** y **GitHub Actions**. Estos pipelines permiten automatizar el proceso de construcción, prueba y despliegue de la aplicación.

- **Deployment Canary**: Implementación gradual de nuevas versiones de la aplicación.
- **Rollback**: Si la versión canary no cumple con las expectativas de tráfico o tiempos de respuesta, se realiza un rollback automáticamente.

### Ejemplos de Pipelines

- `pipeline-example-github-actions`
- `pipeline-example-jenkins-groovy`

El uso de **Istio** permite gestionar el tráfico y balanceo de carga mediante un **VirtualService** y **DestinationRule**, lo cual es útil para control de tráfico y despliegue en canary.

---

## Zero Trust Architecture

La **Zero Trust Architecture** se basa en asegurar que no se confíe en ninguna entidad, ya sea interna o externa, sin verificar su identidad.

### Seguridad

- **mTLS**: Usando **Istio** o cualquier otro service mesh para asegurar la comunicación entre los pods mediante cifrado.
- **Cosign**: Firma de autenticidad de las imágenes Docker.
- **Kyverno**: Auditoría y validación de configuraciones de seguridad y cumplimiento de las reglas de **Pod Security Standards (PSS)**.
- **RBAC**: Uso de roles IAM para la segregación de permisos entre aplicaciones y deployments.

### Gestión de Secrets

- **GCP Secret Manager** o **Vault** para gestionar secrets y otros valores sensibles.
- **Kubernetes RBAC** para controlar el acceso a los secretos según los roles.

---

## Mejoras a la Resolución

### Propuestas

1. **Redundancia**: Usar un número impar de nodos (3 o 5 nodos) para mayor disponibilidad.
2. **Federación de Clusters**: Usar **Kubernetes Federation**, **Fleet**, o un **Global Load Balancer**.
3. **DNS**: Crear un **DNS** para la aplicación y exponer el servicio en el puerto 443 con certificado válido.
4. **IAM**: Implementar un control de acceso más fino usando **IAM** por cada aplicación o deployment.
5. **Vault**: Crear un perfil IAM con permisos para usar **KMS** y gestionar secretos de manera segura.
6. **Istio**: Habilitar **Istio** con **mTLS** para asegurar la comunicación entre servicios.

---

¡Gracias por usar este repositorio! Si tienes alguna pregunta o sugerencia, no dudes en abrir un *issue* o contactar con el autor.
