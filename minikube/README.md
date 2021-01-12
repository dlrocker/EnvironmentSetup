# Minikube

The following information is intended to help with the understanding of the deployment and management of the
minikube cluster that is installed.

# Helpful information
1. To start minikube do
	```
	minikube start
	```
2. To get to the minikube administrative UI/dashboard, enter the following command in a terminal while `minikube` is running:
	```
	minikube dashboard
	```

# Directory layout
## Installation files
The following lists the provided installation files
### Ansible
- `install_docker.yml` - installs the Docker service
- `install_minikube.yml` - installs minikube (and Docker if it is not installed)

### Directories

- `services` - Directory containing all deployment files for services that can be deployed into the minikube cluster using
	provided automation scripts. Currently contains deployment configurations for:
	- Kafka
	- Zookeeper
	