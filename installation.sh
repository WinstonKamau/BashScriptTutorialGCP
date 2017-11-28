#!/usr/bin/env bash

set -o errexit
set -o pipefail
# set -u
# set -o xtrace

dependencies_installation () {
    sudo apt-get install python-virtualenv
    sudo apt-get install python3-pip
    sudo apt-get install git
}

repository_installation () {
    if [[ ! -d "a_socials" ]];then
        git clone https://github.com/BolajiOlajide/a_socials.git
    else
        echo "Folder for project already exists and was not cloned"
    fi
    
    if [[ -d "a_socials" ]];then
        cd a_socials
    else
        echo "The folder a_socials cannot be found.check that the repository was cloned"
        exit 2
    fi

    if [[ ! -d "venv" ]];then
        virtualenv -p python3 venv
    fi

    source venv/bin/activate
    if [[ ! -f ".env" ]];then
        touch .env
    fi

    if [[ ! -s ".env" ]];then
        cp .env.sample .env
    fi
}

set_env_database () {
    echo -n "Do you wish to set your database environment variables (Y/N) ?"

    answer=

    while [[ ! $answer ]];do
        read -r -n 1 answer_argument
        if [[ $answer_argument = [Yy] ]];then
            answer="yes"
        elif [[ $answer_argument = [Nn] ]];then
            answer="no"
            printf "\nYou can change the database environment variables by changing the values set on the .env file "
        else
            printf "\nEnter \"y'\" for \"Yes\" and \"n\" for \"No\". Answer?"
        fi
    done

if [[ $answer = "yes" ]];then
    printf "\n"
    read -p "Insert the name of your database: " db_name
    read -p "Insert the username to your database " db_user
    read -s -p "Insert the password to your database: " db_password
    sed -i -e '2s/.*/'DB_NAME=${db_name}'/g' .env
    sed -i -e '4s/.*/'DB_USER=${db_user}'/g' .env
    sed -i -e '5s/.*/'DB_PASSWORD=${db_password}'/g' .env 
fi

}

platform_check () {
    operating_platform=$(python -m platform) 

    if [[ ! $operating_platform =~ "Ubuntu" ]];then
        echo "Unfortunately this script is meant to install on an Ubuntu machine."
        printf "Check the platform that you are using.\n"
        exit 1
    fi
}

main () {
    # platform_check
    # dependencies_installation
    repository_installation
    set_env_database
}

main "$@"