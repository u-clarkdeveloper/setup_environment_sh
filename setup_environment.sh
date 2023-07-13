#!/bin/bash

file_path="./.env"
secret_list="./secret_list"
required_env_vars="./required_env_vars"

echo "Setting up environment with secrets from Hashicorp Vault Secrets."
echo "--------------------------------------------------------------"
echo ""

continue_flag=1

# Check if the required environment variables file exists
if [ -f "$required_env_vars" ]; then
    echo "Getting required environment variables from $required_env_vars"
    echo "--------------------------------------------------------------"
    if [ ! -s "$required_env_vars" ]; then
        echo "Warning: File $required_env_vars is empty continuing to process secrets"
    fi
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Process each item in the list
        echo "Fetching Local Enironmental Variable: $line"
        if [[ -n ${!line} ]]; then
        :
        else
            echo "ERROR: Environment variable $line does not exist or is not set. Set it with the command"
            echo "export $line=<$line>"
            continue_flag=0
        fi
        echo ""
    done < "$required_env_vars"
else
    continue_flag=0
    echo "File not found: $required_env_vars, Please create the file with the list of required environment variables."
    echo ""
fi

# Check if the secret list file exists
if [[ continue_flag -eq 0 ]]; then
    echo "Exiting script. Please set the environment variables and run the script again."
    exit 1
else
    # Check if the file exists
    if [ -f "$secret_list" ]; then
        # Read the file line by line and loop over the list
        echo "Getting secrets from $secret_list"
        echo "--------------------------------------------------------------"
        if [ ! -s "$secret_list" ]; then
            echo "Warning: File $secret_list has no secrets to fetch. if you want to fetch secrets, add them to the file and run the script again."
            exit 1
        fi
        if [ -f "$file_path" ]; then rm $file_path; fi
        
        while IFS= read -r line || [[ -n "$line" ]]; do
            # Process each item in the list
            echo "Fetching Secret: $line"
            value=$(vlt secrets get -plaintext $line)
            if [ "${value:0:7}" == "Error: " ]; then
                echo "Secret $line not found. Please check the secret name and try again."
                echo ""
            else
                echo "$line=$value" >> $file_path
                echo ""
            fi
        done < "$secret_list"
    else
        echo "File not found: $secret_list, Please create the file with the list of secrets to fetch."
        echo ""
    fi
    echo "Done"
    echo ""
fi

