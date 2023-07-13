#!/bin/bash
# pull in color echo commands
source <(curl -s https://raw.githubusercontent.com/u-clarkdeveloper/color_echo_sh/main/color_echo.sh)

#Setup variables
file_path="./secrets.env"
secret_list="./secret_list"
required_env_vars="./required_env_vars"
continue_flag=1

# Set the title of the script
title "Setting up environment with secrets from Hashicorp Vault Secrets."

# Check if the required environment variables file exists
if [ -f "$required_env_vars" ]; then
    header "Getting required environment variables from $required_env_vars"

    if [ ! -s "$required_env_vars" ]; then
        warning "Warning: File $required_env_vars is empty continuing to process secrets"
    fi
    if [ ! -v HCP_CLIENT_ID ] || [ ! -v HCP_CLIENT_SECRET ] || [ ! -v HCP_CLIENT_APP ]; then
        error "Error: HCP_CLIENT_ID and/or HCP_CLIENT_SECRET is not set. If you want to fetch secrets, set them and run the script again."
        continue_flag=0
    fi
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Process each item in the list
        info "Fetching Local Enironmental Variable: $line"
        if [[ -n ${!line} ]]; then
        :
        else
            error "ERROR: Environment variable $line does not exist or is not set. Set it with the command"
            highlight "export $line=<$line>"
            continue_flag=0
        fi
    done < "$required_env_vars"
else
    continue_flag=0
    error "File not found: $required_env_vars, Please create the file with the list of required environment variables."
fi

# Check if the secret list file exists
if [[ continue_flag -eq 0 ]]; then
    error "Exiting script. Please set the environment variables and run the script again."
    exit 1
else
    # Check if the file exists
    if [ -f "$secret_list" ]; then
        # Read the file line by line and loop over the list
        header "Getting secrets from $secret_list"
        if [ ! -s "$secret_list" ]; then
            warning "Warning: File $secret_list has no secrets to fetch. if you want to fetch secrets, add them to the file and run the script again."
            
            exit 1
        fi
        if [ -f "$file_path" ]; then rm $file_path; fi
        
        while IFS= read -r line || [[ -n "$line" ]]; do
            # Process each item in the list
            info "Fetching Secret: $line"
            value=$(vlt secrets get -a $HCP_CLIENT_APP --plaintext $line)
            if [ "${value:0:7}" == "Error: " ]; then
                error "Secret $line not found. Please check the secret name and try again."
            else
                echo "$line=$value" >> $file_path
            fi
        done < "$secret_list"
    else
        error "File not found: $secret_list, Please create the file with the list of secrets to fetch."
    fi
    footer "Done"
fi

