#!/bin/bash

# pull in color echo commands
source <(curl -s https://raw.githubusercontent.com/u-clarkdeveloper/color_echo_sh/main/color_echo.sh)

# Setup trap of exit early
trap 'if [ "$?" -eq 1 ]; then error "Setup exited early"; fi' EXIT

#Setup file path variables
file_path="./secrets.env"
secret_list="./secret_list"
required_env_vars="./required_env_vars"
secret_env_map="./secret_env_map"

#Setup global variables
declare -A secretmappings

#check to make sure vlt is installed on the system
check_vlt () {
    if ! command -v vlt &> /dev/null
    then
        error "vlt could not be found. Please install it and try again."
        exit 1
    fi
}


#Declare Functions
setup_mappings () {
    header "Getting secret mappings from $secret_env_map"
    if [ -f "$secret_env_map" ]; then
        if [ ! -s "$secret_env_map" ]; then
            warning "Warning: File $secret_env_map is empty. No mappings will be used."
        else
            while IFS= read -r line || [[ -n "$line" ]]; do
                # Process each mapping in the list
                mapping=(${line/:/ })
                info "Mapping: ${mapping[0]} to ${mapping[1]}"
                secretmappings[${mapping[0]}]=${mapping[1]}

            done < "$secret_env_map"
        fi
        
    else
        warning "File: $secret_env_map not found. No mappings will be used."
    fi
}

setup_required_env_vars () {
    header "Getting required environment variables from $required_env_vars"
    # Check for required Vault Secrets environment variables
    if [ ! -v HCP_CLIENT_ID ] || [ ! -v HCP_CLIENT_SECRET ] || [ ! -v HCP_CLIENT_APP ]; then
        error "Error: HCP_CLIENT_ID, HCP_CLIENT_SECRET, or HCP_CLIENT_APP is not set. If you want to fetch secrets, set them and run the script again."
        exit 1
    fi
    # Check if the required environment variables file exists
    if [ -f "$required_env_vars" ]; then
        if [ ! -s "$required_env_vars" ]; then
            warning "Warning: File $required_env_vars is empty continuing to process secrets"
        else 
            while IFS= read -r line || [[ -n "$line" ]]; do
                # Process each item in the list
                
                if [[ -n ${!line} ]]; then
                    info "Checking Local Enironmental Variable: $line... $(checkmark)"

                else
                    info "Checking Local Enironmental Variable: $line... $(xmark)"
                    error "ERROR: Environment variable $line does not exist or is not set. Set it with the command"
                    highlight "export $line=<$line>"
                    exit 1
                fi
            done < "$required_env_vars"
        fi
    else
        error "File not found: $required_env_vars, Please create the file with the list of required environment variables."
        exit 1
    fi
}

fetch_valut_secrets () {
    header "Getting secrets from $secret_list"
    # Check if the file exists
    if [ ! -f "$secret_list" ]; then
        error "File not found: $secret_list, Please create the file with the list of secrets to fetch."
        exit 1
    else
        # Check for empty secret_list file
        if [ ! -s "$secret_list" ]; then
            warning "Warning: File $secret_list has no secrets to fetch. if you want to fetch secrets, add them to the file and run the script again."
            exit 1
        fi
        # remove existing secrets.env file if it exists
        if [ -f "$file_path" ]; then rm $file_path; fi
        
        # read the secret_list file line by line
        while IFS= read -r line || [[ -n "$line" ]]; do
            # Process each item in the list
            value=$(vlt secrets get -a $HCP_CLIENT_APP --plaintext $line)
            if [ "${value:0:7}" == "Error: " ]; then
                error "Secret $line not found. Please check the secret name and try again... $(xmark)"
                exit 1
            else
                info "Secret $line found... $(checkmark)"
                if [ ! -v ${secretmappings[${line}]} ]; then
                    good "Mapping Exists: $line is mapped to ${secretmappings[${line}]}"
                    if [ "${secretmappings[${line}]:0:1}" == "~" ]; then
                        echo $(printf $(printf '%s' "${secretmappings[${line}]:1}") "$value") >> $file_path
                    else
                        echo "${secretmappings[${line}]}=$value" >> $file_path
                    fi
                else
                    echo "$line=$value" >> $file_path
                fi
                
            fi
        done < "$secret_list"
    fi
}



# Run the script functions
title "Setting up environment with secrets from Hashicorp Vault Secrets."

check_vlt
setup_mappings
setup_required_env_vars
fetch_valut_secrets

footer "Done!!! $(checkmark)"
exit 0