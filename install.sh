#!/bin/bash

# create setup_environment.sh in repo
cat <<EOT >> ../setup_environment.sh
#!/bin/bash

source <(curl -s https://raw.githubusercontent.com/u-clarkdeveloper/setup_environment_sh/main/setup_environment.sh)
EOT

mv ./secret_env_map ./secret_list ./required_env_vars ../
cd ..
rm -rf ./setup_environment_sh