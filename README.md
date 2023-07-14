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
The script will look for three files in the same directory
```shell
./required_env_vars
./secret_list
./secret_env_map
```

### ./required_env_vars
This file will include a list of environment variables that should be set and if not it will warn you if they are not set and give you the command to set them. It will also warn you if this file is empty.

### ./secret_list
This file will include a list of the secrets that are stored in Hashicorp Vault Secrets Service. It will pull down the the secrets and place them in a secrets.env file. You can then use this file to load secrets into your program or docker container. If a secret is not found it will give you an error and have you fix the issue and try again.

### ./secret_env_map
This file is optional, but if you would like to map a secret key to another varriable, you can add this file and place on each line a key-pair seperated by : to denote mappings from secret to env varriable you would like instead in the secrets.env file. Usefull if your vault keys don't match the env variables required by your application. Say a docker image that is looking for a specific variable.

e.g.
```shell
MY_VAULT_SECRET:CUSTOM_ENV_VAR
```
Then instead of MY_VAULT_SECRET=SUPER_SECRET_VALUE in your secrets.env file you would get CUSTOM_ENV_VAR=SUPER_SECRET_VALUE

#### Additional mapping functionality
If you would like to inject the value comming from Hashicorp Secret Vault into a string, you can start off your mapped varrible with a ~ and then place %s where you would like the value to be inserted. For example, if I had a uri that didn't have the protocol defined in the Vault value I could then and the protocol to the  the mapping and inject the secret after the protocol.

e.g.
```shell
MY_VALUT_SECRET_URI=username:password@some.host.com
```
I would like it to be:
```shell
MY_CONNECTION_STRING='sftp://username:password@some.host.com'
```

My mapping would then look like
```shell
MY_VALUT_SECRET_URI:~MY_CONNECTION_STRING='sftp://%s'
```
