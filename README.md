# EnvironmentSetup
Repository used to help with the process of setting up a development environment on CentOS 7

All programming languages or tools can be installed by using the provided `setup.sh` script. Simply run
```
./setup.sh --help
```
to review the options and usage. Once you are done reviewing the options execute the script with your
install options:
```
./setup.sh <install options>
```

The currently supported install options are:
- `--go`: Installs the GOLANG programming language version 1.15.6

**NOTE:** If you are installing as a non-root user who has sudo privileges, use the following command instead
```
sudo ./setup.sh <install options>
```

## Installing git command line
To install the `git` command line run the following commands in a terminal
```
yum -y install epel-release
yum -y install git
```