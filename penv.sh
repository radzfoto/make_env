# Copyright (c) 2023 Raul Diaz
# All rights reserved unless a LICENSE file exists in the repository
# in which case a license is granted as per the LICENSE file contents


# Place this file in ${HOME}/.envs
# Execute these commands on the command line:
# $ chmod +x ${HOME}/.envs/penv.sh

#!/bin/bash

# File to hold aliases
ALIAS_FILE="${HOME}/.aliases.sh"

# Ensure the alias file exists
touch "$ALIAS_FILE"

# Function to add an alias
add_alias() {
    local env_name=$1
    local alias_name="env$env_name"
    local activate_command="source ${HOME}/.envs/$env_name/bin/activate"

    # Add environment activation alias
    echo "alias $alias_name=\"$activate_command\"" >> "$ALIAS_FILE"
}

# Function to add the penv alias
add_penv_alias() {
    local penv_command="source ${HOME}/.envs/penv.sh"

    # Check if penv alias already exists, if not, add it
    if ! grep -q "alias penv=" "$ALIAS_FILE"; then
        echo "alias penv=\"$penv_command\"" >> "$ALIAS_FILE"
    fi
}

# Add the penv alias
add_penv_alias

# Main script
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 environment_name"
    exit 1
fi

ENV_NAME=$1
ALIAS_NAME="env$ENV_NAME"
ENV_DIR="${HOME}/.envs/${ENV_NAME}"

# Create the environment directory if it doesn't exist
mkdir -p "${HOME}/.envs"

# Create the virtual environment
python3 -m venv "$ENV_DIR"

# Add the environment activation alias
add_alias "$ENV_NAME"

echo "Python env $ENV_NAME created and alias $ALIAS_NAME added that activates this env"
