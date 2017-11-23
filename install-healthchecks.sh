#!/usr/bin/env bash

set -o errexit
set -o pipefail
# set -o nounset
# set -o xtrace

installation_1 () {
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get install python-virtualenv
    sudo apt-get install python3-pip
    sudo apt-get install git

}

installation_2 () {
    sudo yum -y update
    sudo yum -y install yum-utils
    sudo yum -y groupinstall development
    sudo yum -y install python2-pip
    sudo pip install virtualenv
    sudo yum install git
}

installation_3 () {
    echo "Running on local MacOs shell"
}

operating_platform=$(python -mplatform)


valid_option=

if [[ $operating_platform =~ "debian" || $operating_platform =~ "Ubuntu" ]];then
    valid_option=1
fi

if [[ $operating_platform =~ "Darwin" ]];then
    valid_option=3
fi

if [[ $operating_platform =~ "centos-7" ]];then
    valid_option=2
fi

case $valid_option in
    1)
        installation_1
        ;;
    2)
        installation_2
        ;;
    3)
        installation_3
        ;;
    *)
        exit 1
esac

# On the root of your virtual machine, create a folder healthcheckapp
# The folder is only created if it does not exist
if [[ ! -d "healthcheckapp" ]];then
    mkdir -p ~/healthcheckapp
fi
# Change directory from the root and into the healthcheck app
cd ~/healthcheckapp

if [[ ! -f "hc-venv" && $valid_option = 2 ]];then
    virtualenv --python=python2 hc-venv
else
    virtualenv --python=python3 hc-venv
fi

VENV_ROOT=hc-venv/bin/activate
# Activate the virtual environment
source "${VENV_ROOT}"

if [[ ! -d "healthchecks" ]];then 
# Clone the repo into the virtual machine 
    git clone https://github.com/healthchecks/healthchecks.git
fi

# Install requirements for the machine
pip install -r healthchecks/requirements.txt

if [[ $valid_option = 2 ]];then
    pip install rcssmin --install-option="--without-c-extensions"
    pip install rjsmin --install-option="--without-c-extensions"
    pip install django-compressor --upgrade
fi

cd ~/healthcheckapp/healthchecks

# Copy files
cp hc/local_settings.py.example hc/local_settings.py

cd ~/healthcheckapp/healthchecks

# Run the migrate command
./manage.py migrate 

# Create a new superuser or not
echo -n "Do you wish to create a new superuser (Y/N) ?"

answer=

while [[ ! $answer ]];do
    read -r -n 1 answer_argument
    if [[ $answer_argument = [Yy] ]];then
        answer="yes"
    elif [[ $answer_argument = [Nn] ]];then
        answer="no"
        printf "\nYou can run the command \"./manage.py createsuperuser\" later to create a new super user"
    else
        printf "\nEnter \"y'\" for \"Yes\" and \"n\" for \"No\". Answer?"
    fi
done

if [[ $answer = "yes" ]];then
    printf "\n"
    ./manage.py createsuperuser  
fi

# run the django server
./manage.py runserver
