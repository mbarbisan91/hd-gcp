Estructura del Repositorio

./
├─ app
│  └─ Deployments de la aplicacion para ArgoCD
	└─ Deployment sin canary, exponiendo el servicio por loadbalancer al 8080 con HPA 
	└─ Deployment con canary, exponiendo el servicio en el 443 y con certificado auto firmado.
├─ grafana
│  └─ Dashboard de ejemplo para importar como json. En la instalacion estan los predefinidos
	  User: admin, pass: grafito 
└─ k8s-manifests
   └─ configuracion del repo ArgoCD y configuraciones adicionales para el cluster

	Administration-apps.tf
		Instalacion de herramientas de administracion del cluster (Prometheus, Grafana, Vault, Kyverno, Istio).
	Artifactory.tf 
		Creacion de artifactory para alojar imagenes docker.
	Custom-metric.tf
		Metrica custom para el HPA del pod de ejemplo.
	Docker.tf 
		Creacion de la imagen Docker local y push al Artifactory.
	Dockerfile
		Configuracion para el build de la imagen de la aplicacion. 
	Main.tf 
		COnfiguracion general de los clusters GKE.
	Networking.tf
		Creacion de VPC y de subnets para los clusters.
	Outputs.tf
		Output de los objetos creados (endpoint de los clusters, CA, url Artifactory)
	pipelines-examples-(jenkins/github).txt
		Prototipo de pipelines
	Providers.tf
		Versiones y requerimientos necesarios.
	Terraform.tfvars 
		Variables y habilitar instalacion de objetos.
	Variables.tf 
		Variables de la configuracion. 

Instalacion: 
	Clonar el repo
		$ git clone https://github.com/mbarbisan91/hd-gcp.git
		$ cd hd-gcp

	Inicializar terraform
		$ terraform init

	Modificar las variables con las propias en variables.tf
		$ terraform apply

	Obtener credenciales del cluster localmente para poder ejecutar kubectl localmente
		$ gcloud container clusters get-credentials demo-europe --region europe-west2-a

	Aplicar crds necesarios para ArgoCD, dentro de la consola GCP o de forma local: 
		$ kubectl apply -k github.com/argoproj/argo-rollouts/manifests/crds
	
	Copiar el tf del respositorio 
		$ cp k8s-manifests/gitrepo.tf . 

	Ejecutar nuevamente el terraform para que cree el ArgoCD repo 
		$ terraform apply

	Version sin canary y con HPA, funcionando en el puerto 8080
		Version con canary no funciona(necesita creacion de ingress, cert e ingress)

	Obtener password de ArgoCD:
	kubectl -n argocd get secret argocd-initial-admin-secret \
          -o jsonpath="{.data.password}" | base64 -d; echo

Usuarios/Password fueron creados solo con el fin de la prueba y la facilidad de uso. 

Repositorio de aplicacion:
	https://github.com/mbarbisan91/hd-gcp/app

Respuesta por puntos: 

![Texto alternativo](./arquitectura.png)

	1 - Se crea una VPC compartida entre dos subsnets (una subnet por cluster)
		Se crean dos clusters en regiones diferentes y zonas diferentes para cumplir HA
	
		Se realiza el deploy de ArgoCD (este instalaria todos los servicios necesarios desde los repositorios involucrado, 
		como prometheus, grafana, prometheus adapter, istio, etc)

		RTO y RPO se calculara en cuanto tarda Terraform en recrear los objetos

	  RTO (Recovery Time Objective): 1 hour (time to restore the application after a failure).
	  RPO (Recovery Point Objective): 5 minutes (maximum acceptable data loss).

Creacion del repositorio de docker (artifactory)
Creacion de la imagen inicial de base de la app 

Se sincronizara el repositorio de los manifiestos respectivos a la app y aplicaciones atraves de ArgoCD 

RTO/RPO: 
  El deployment del cluster con la aplicacion funcionando son unos 20 minutos, de comienzo a fin. Podriamos usarlo de referencia. 


	2 - ![Texto alternativo](./pipeline.png)

		Dejo algunos ejemplos prototipo de codigo: 
			pipeline-example-github-actions 
			pipeline-example-jenkins-groovy

		Podriamos usar ArgoCD para la implementacion de CI/CD o la herramienta de google 
		Canary deployment con un yaml de kubernetes 
		Rollback en el caso de que la applicacion en el canary no cumpla un X de request y tiempo de respuesta 

		Se creara un self-certificate para exponer la aplicacion 

		Herramientas para CI/CD: Jenkins, GitLab CI, codebuild, github actions: 

		Push del codigo --> webhook hacia la app de CI/CD -> pipeline: 

		pull del codigo nuevo 
		copilacion de la app 
		creacion de la app
		push a la registry/artifact
		deployment con canary con la nueva version en cluster GKE
			Si tenemos istio se podria usar el balanceo de carga por porcentaje de request accepted (VirtualService/DestinationRule) 

		Servicio de app por puerto 443 se puede realizar con un loadbalancer service escuchando el puerto 443 redirigiendolo al 8080 de la app sin certicado. (certificado autofirmado del cluster)

		Formato seguro con service mesh + mtls. (istio), con un ingress exponiendo el servicio con certificado y mirando el backend del service

	3 
		Zero Trust Arquitecture: 
			Se podria usar Istio (controlar ingress y egress de las apps por separado) o cualquier service mesh para Mtls asegurando la comunicacion entre los pods/servicios asegurando el uso de cifrado. 
			Cosign para la firma de autenticidad de las imagenes dockers y de la cadena de creacion 
			Para el adminition controller se puede usar Kyverno para validar y auditar configuraciones 
			Kyverno tambien cumpliria con las reglas de Pod Security Standards (PSS):  

		Para la seguridad de los secrets se podria usar: 
			GCP Secret Manager, Vault

		Comunicacion entre nodos securizada en los parametros de creacion del cluster, nodos confidenciales, redes privadas, etc. 

		RBAC: que aplicacion tenga un rol IAM asociado con permisos especificos 

		Webhook: para la autorizacion de automatizacion y aplicaciones de automatizacion, robots, etc. 

		Istio Authorization Policies - Podria usarse como una especie de firewall
		
		Para la implementacion de PSP se uso Kyverno 

		Obtener politicas de Kyverno:
		$kubectl get cpol

		Politicas aplicadas por defecto: 

		NAME                             ADMISSION   BACKGROUND   READY   AGE     MESSAGE
		disallow-capabilities            true        true         True    5m17s   Ready
		disallow-host-namespaces         true        true         True    5m17s   Ready
		disallow-host-path               true        true         True    5m17s   Ready
		disallow-host-ports              true        true         True    5m17s   Ready
		disallow-host-process            true        true         True    5m17s   Ready
		disallow-privileged-containers   true        true         True    5m17s   Ready
		disallow-proc-mount              true        true         True    5m17s   Ready
		disallow-selinux                 true        true         True    5m17s   Ready
		restrict-apparmor-profiles       true        true         True    5m17s   Ready
		restrict-seccomp                 true        true         True    5m17s   Ready
		restrict-sysctls                 true        true         True    5m17s   Ready


Mejoras a la resolucion: 

	Cantidad de nodos impares para la redundancia 3 o 5 (se uso el tier free para las pruebas)

	Federar los clusters con Kubernetes Federation o usar Fleet o un Global load balancer, con un loadbalancer general por cada cluster con redireccion interna. 

	Restaria crear un dns para la aplicacion y exponer el servicio por el 443
	Crear un ingress con el certificado refiriendose al service de la app

	Usar IAM por cada aplicativo/deployment para la segregacion de permisos y seguridad

	Creacion de perfil IAM con permisos para usar KMS en gcp para que vault funcione
		Aprovicionarle storage para raft
	
	Habilitar Istio con Mtls 

	Habilar Fleet o Anthos para la sincronizacion/federacion de los clusters 

	Aplicacion de reglas Waf al LoadBalancer general o a las instancias expuestas en el

