# Copyright (c) 2023 Raul Diaz
# All rights reserved unless a LICENSE file exists in the repository
# in which case a license is granted as per the LICENSE file contents
#####################################################################

# Place this file in ${HOME}/.envs
# Execute these commands on the command line:
# $ chmod +x ${HOME}/.envs/penv.sh

#!/bin/bash

# Environment directory variable
ENV_DIR_NAME=".envs"

# File to hold aliases
ALIAS_FILE=".aliases.sh"
ALIAS_FILE_PATH="${HOME}/$ALIAS_FILE"

# Ensure the alias file exists
touch "$ALIAS_FILE_PATH"

# Determine the user's shell and edit the appropriate configuration file
if [[ "$SHELL" =~ .*zsh$ ]]; then
    CONFIG_FILE="${HOME}/.zshrc"
elif [[ "$SHELL" =~ .*bash$ ]]; then
    CONFIG_FILE="${HOME}/.bashrc"
else
    echo "Unsupported shell: $SHELL"
    sleep 2
    exit 1
fi

# Add source line to the shell configuration file if it doesn't exist
if ! grep -q "source $ALIAS_FILE_PATH" "$CONFIG_FILE"; then
    echo "source $ALIAS_FILE_PATH" >> "$CONFIG_FILE"
    echo "Added line $ALIAS_FILE_PATH to $CONFIG_FILE"
fi

# Function to add an alias
add_alias() {
    local env_name=$1
    local alias_name="env$env_name"
    local activate_command="source ${HOME}/${ENV_DIR_NAME}/$env_name/bin/activate"

    # Add environment activation alias
    echo "alias $alias_name=\"$activate_command\"" >> "$ALIAS_FILE_PATH"
}

# Function to add the penv alias
add_penv_alias() {
    local penv_command="${HOME}/${ENV_DIR_NAME}/penv.sh"

    # Check if penv alias already exists, if not, add it
    if ! grep -q "alias penv=" "$ALIAS_FILE_PATH"; then
        echo "alias penv=\"$penv_command\"" >> "$ALIAS_FILE_PATH"
    fi
}

# Function to self-install the script
self_install() {
    # Determine the full path of the script
    local script_path="$(realpath "$0")"
    local target_path="${HOME}/${ENV_DIR_NAME}/penv.sh"

    # Check if the script is not already in the target location
    if [ "$script_path" != "$target_path" ]; then
        # Copy the script to the .envs directory
        cp "$script_path" "$target_path"
        chmod +x "$target_path"
        echo "penv.sh has been copied to $target_path"
    fi
}

# Create the environment directory if it doesn't exist
mkdir -p "${HOME}/${ENV_DIR_NAME}"

# Self-install the script into the $ENV_DIR_NAME
self_install

# Add the penv alias
add_penv_alias

# Create the python environment
if [ "$#" -ne 1 ]; then
    echo "Usage: penv environment_name"
else
    ENV_NAME=$1
    ALIAS_NAME="env$ENV_NAME"
    ENVIRONMENT_DIR="${HOME}/${ENV_DIR_NAME}/${ENV_NAME}"

    # Create the virtual environment
    python3 -m venv "$ENVIRONMENT_DIR"

    # Add the environment activation alias
    add_alias "$ENV_NAME"

    echo "Python env $ENV_NAME created and alias $ALIAS_NAME added that activates this env"
fi
