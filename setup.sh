# Authors:
# - David Rocker

function help() {
	echo
	echo "This script is designed to be the entrypoint for installing different tools,"
	echo "programming languages, or other media for programming projects on CentOS 7"
	echo
	echo "Usage: $0 --go --help"
	echo
	echo "--go   : Flag to specify installing the GO programming language"
	echo "--python38 : Flag to specify installing Python version 3.8"
	echo "--docker   : Flag to specify installing Docker"
	echo "--minikube : Flag to specify installing minikube. Note: Also installs Docker."
	echo "--help : Flag to call the help() function and exit the script"
	echo
}

function setup_ansible() {
	if rpm -q epel-release > /dev/null 2>&1; then
		echo "epel-release is already installed. Skipping."
	else
		yum -y install epel-release || { echo "Failure installing ansible"; return 1; }
	fi
	
	if rpm -q ansible > /dev/null 2>&1; then
		echo "ansible is already installed. Skipping."
	else
		yum -y install ansible || { echo "Failure installing ansible"; return 1; }
	fi
	
	
	inventory_file=$SCRIPT_DIR/inventory.ini
	if [ -f "$inventory_file" ]; then
		echo "Inventory file $inventory_file already exists. Checking that it has a definition for localhost"
		has_localhost=$(grep "\[local\]" $ANSIBLE_INVENTORY)
		if [ -z "$has_localhost" ]; then
			echo "Ansible inventory does not contain expected localhost defintion. Adding definition to inventory."
			cat $inventory_file >> $ANSIBLE_INVENTORY
		else
			echo "Ansible inventory contains expected localhost definition - nothing to do."
		fi
	else
		cp $inventory_file $ANSIBLE_INVENTORY \
			|| { echo "Failure creating ansible inventory file"; return 1; }
	fi
}

function refresh_bash_profile() {
	echo "It is recommended to source your users bash profile prior to executing more commands"
	echo -e "\nCommand to execute: \"source ~/.bash_profile\"\n"
}


function main() {
	echo "Starting setup process"
	setup_ansible || { echo "Failure setting up ansible"; exit 1; }
	
	if [ "$INSTALL_GOLANG" == "true" ]; then
		echo "Installing the GO programming language"
		ansible-playbook $PROGRAMMING_DIR/install_go.yml || { echo "Failure installing the GO programming language"; exit 1; }
		refresh_bash_profile
	fi
	if [ "$INSTALL_PYTHON_3_8" == "true" ]; then
		echo "Installing Python 3.8"
		ansible-playbook $PROGRAMMING_DIR/install_python_3_8.yml || { echo "Failure installing Python 3.8"; exit 1; }
		refresh_bash_profile
	fi
	if [ "$INSTALL_DOCKER" == "true" ]; then
		echo "Installing Docker"
		ansible-playbook $MINIKUBE_DIR/install_docker.yml || { echo "Failure installing Docker"; exit 1; }
		#sudo usermod -aG docker $USER && newgrp docker
	fi
	if [ "$INSTALL_MINIKUBE" == "true" ]; then
		echo "Installing minikube"
		ansible-playbook $MINIKUBE_DIR/install_minikube.yml || { echo "Failure installing minikube"; exit 1; }
		#sudo usermod -aG docker $USER && newgrp docker
	fi
	
	echo "Finished installing!"
}

# Define constants
SCRIPT_DIR=$(dirname "$0")
ANSIBLE_INVENTORY=/etc/ansible/hosts
PROGRAMMING_DIR=$SCRIPT_DIR/programming_languages	# Directory for programming language installation playbooks
MINIKUBE_DIR=$SCRIPT_DIR/minikube					# Directory for installation of docker/minikube
OTHER_DIR=$SCRIPT_DIR/other							# Directory for installation playbooks of random tools

# TODO - add a "all" option to install all tools
ARGUMENTS=`getopt -n $0 -o "" --long go,python38,docker,minikube,help -- "$@"`
if [ $# -eq 0 ]; then help; exit 0; fi
eval set -- "$ARGUMENTS"

INSTALL_GOLANG="false"		# Determines whether golang is installed
INSTALL_PYTHON_3_8="false"	# Determines whether python 3.8 is installed
INSTALL_DOCKER="false"		# Determines whether Docker is installed
INSTALL_MINIKUBE="false" 	# Determines whether minikube and docker are installed

# Initialize setup
while true; do
	case "$1" in
		--go )			INSTALL_GOLANG="true"; shift ;;
		--python38 )	INSTALL_PYTHON_3_8="true"; shift ;;
		--docker )		INSTALL_DOCKER="true"; shift ;;
		--minikube )	INSTALL_MINIKUBE="true"; shift ;;
		--help )	help; exit ;;
		-- )		shift; break ;;
		*) 			help; exit 1 ;;
	esac
done


main
