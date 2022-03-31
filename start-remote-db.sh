#!/bin/bash -eu

function input_variable()
{
    var=$1
    description=$2
    default=$3

    if ! printenv $var
    then
        if [ -z "$default" ]
        then
            prompt="$description? "
        else
            prompt="$description [$default]? "
        fi        
        read -p"$prompt" value
        value=${value:-$default}
        eval ${var}=$(printf "%q" $value)
        echo "$var='${!var}'"
    fi
}

#export TODO_SECRET=$(LC_CTYPE=C < /dev/urandom tr -dc ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 | head -c32)
export TODO_SECRET="secretSECRETsecretSECRETsecretSECRET"
echo TODO_SECRET=$TODO_SECRET

if ! printenv PGRST_DB_URI
then
    input_variable PGRST_DB_SERVER   "PostgreSQL server"              ""
    input_variable PGRST_DB_PORT     "PostgreSQL port"                5432
    input_variable PGRST_DB_NAME     "PostgreSQL database name"       postgres
    input_variable PGRST_DB_USER     "PostgreSQL connection username" authenticator
    input_variable PGRST_DB_PASSWORD "PostgreSQL connection password" mysecretpassword
    encoded_password=$(perl -MURI::Escape -e 'print uri_escape($ARGV[0])' "${PGRST_DB_PASSWORD}") 
    input_variable PGRST_DB_SSL      "PostgreSQL SSL true or false"   false
    input_variable PGRST_DB_URI      "PostgREST database URI"         "postgresql://${PGRST_DB_SERVER}:${PGRST_DB_PORT}/${PGRST_DB_NAME}?user=${PGRST_DB_USER}&password=${encoded_password}&ssl=${PGRST_DB_SSL}"
fi

input_variable PGRST_DB_SCHEMA    "PostgreSQL schema to connect to" api
input_variable PGRST_DB_ANON_ROLE "PostgreSQL anonymous role"       web_anon

# These environment variables are used in docker-compose-remote-db.yml
export PGRST_DB_URI PGRST_DB_SCHEMA PGRST_DB_ANON_ROLE

exec docker-compose --file docker-compose-remote-db.yml up --build --force-recreate
