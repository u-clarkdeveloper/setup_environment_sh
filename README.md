# setup_environment_sh

## Description
This script is used to check to make sure env variables exist and are set. 

## Usage

Create a shell script and place the content below in the file or run the command to setup the environment

```shell
#!/bin/bash

source <(curl -s https://raw.githubusercontent.com/u-clarkdeveloper/setup_environment_sh/main/setup_environment.sh)
```

if you create a shell script remember to make it executable

```shell
chmod +x setup_environment.sh
```

## How it works
The script will look for two files in the same directory
```shell
./required_env_vars
./secret_list
```

### ./required_env_vars
This file will include a list of environment variables that should be set and if not it will warn you if they are not set and give you the command to set them. It will also warn you if this file is empty.

### ./secret_list
This file will include a list of the secrets that are stored in Hashicorp Vault Secrets Service. It will pull down the the secrets and place them in a secrets.env file. You can then use this file to load secrets into your program or docker container. If a secret is not found it will give you an error and have you fix the issue and try again.