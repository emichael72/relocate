#!/bin/bash
# shellcheck disable=SC2059

# Global Constants
GIT_REPO_URL="https://github.com/intel-innersource/firmware.ethernet.mountevans.imc.imc-userspace.git"
SOURCE_TREE_DIR="userspace"
PYTHON_VENV_DIR=".venv"
PYTHON_VERSION="python3.9"

#
# @brief Initializes or creates the Python virtual environment.
# @return Returns 0 on success, 1 on failure.
#

init_python_venv() {
    if [ -d "$PYTHON_VENV_DIR" ]; then
        source $PYTHON_VENV_DIR/bin/activate
        return 0
    else
        # Check for Python availability
        if ! command -v $PYTHON_VERSION &>/dev/null; then
            echo "Error: $PYTHON_VERSION is not installed. Please install it and try again."
            return 1
        fi
        # Create a new virtual environment
        $PYTHON_VERSION -m venv $PYTHON_VENV_DIR
        source $PYTHON_VENV_DIR/bin/activate
		
		# Upgrade pip and add required packages
        	python3.9 -m pip install --upgrade pip >/dev/null 2>&1
        	pip install colorama >/dev/null 2>&1
        
		return 0
    fi
}

#
# @brief Checks for the existence of the source tree directory or clones it if missing.
# @return Returns 0 on success, 1 if the clone operation fails.
#

clone_source_tree() {
    if [ ! -d "$SOURCE_TREE_DIR" ]; then
        if ! git clone $GIT_REPO_URL $SOURCE_TREE_DIR; then
            echo "Error: Failed to clone '$SOURCE_TREE_DIR' repository."
            return 1
        fi
    fi
    return 0
}

#
# @brief Main function to orchestrate script operations.
# @return Returns 0 on overall success, 1 on failure.
#

main() {

    printf "\nInitializing '${SOURCE_TREE_DIR}' relocation environment..\n"
    if ! init_python_venv; then
        echo "Failed to initialize or activate the Python virtual environment."
        return 1
    fi

    if ! clone_source_tree; then
        echo "Could not obtain the source tree. Please check the repository URL and network settings."
        return 1
    fi

    # Create a handy shortcut
    alias restruct='cd "$PWD"; python3.9 "$PWD/support/relocate.py" -j="$PWD/support/relocate.jsonc"; cd -'
    printf "\nInitialized, edit 'support/relocate.jsonc' and use 'restruct' to execute.\n\n"
    return 0
}

#
# @brief Invoke the main function with command-line arguments.
# @return The exit status of the main function.
#

main "$@"
exit $?
