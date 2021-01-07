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


function main() {
	echo "Starting setup process"
	setup_ansible || { echo "Failure setting up ansible"; exit 1; }
	
	if [ "$INSTALL_GOLANG" == "true" ]; then
		echo "Installing the GO programming language"
		ansible-playbook $PROGRAMMING_DIR/install_go.yml || { echo "Failure installing the GO programming language"; exit 1; }
	fi
	
	echo "Finished installing! It is recommended to source your users bash profile prior to executing more commands"
	echo "in order to pick up any path changes."
	echo -e "\nCommand to execute: \"source ~/.bash_profile\"\n"
}

# Define constants
SCRIPT_DIR=$(dirname "$0")
ANSIBLE_INVENTORY=/etc/ansible/hosts
PROGRAMMING_DIR=$SCRIPT_DIR/programming_languages	# Directory for programming language installation playbooks
OTHER_DIR=$SCRIPT_DIR/other							# Directory for installation playbooks of random tools

# TODO - add a "all" option to install all tools
ARGUMENTS=`getopt -n $0 -o "" --long go,help -- "$@"`
if [ $# -eq 0 ]; then help; exit 0; fi
eval set -- "$ARGUMENTS"

INSTALL_GOLANG="false"	# Determines whether golang is installed

# Initialize setup
while true; do
	case "$1" in
		--go )		INSTALL_GOLANG="true"; shift ;;
		--help )	help; exit ;;
		-- )		shift; break ;;
		*) 			help; exit 1 ;;
	esac
done


main
