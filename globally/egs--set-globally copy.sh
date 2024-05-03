#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

PREFIX_SCRIPT_FILE=egs--
SCRIPT_DIR=~/.glbscr

# Path to SCRIPT_DIR
path_to_add="export PATH=\$PATH:~/.glbscr"

# Path to CONFIGURATION FILES
bash_profile=~/.bash_profile
bashrc=~/.bashrc
zshrc=~/.zshrc
fish_config=~/.config/fish/config.fish

# Step 1: Create a directory to store scripts

if [ -d "$SCRIPT_DIR" ]; then
    echo -e "${YELLOW}Folder '$SCRIPT_DIR' already exists. Skipping creation.${NC}"
else
    mkdir -p "$SCRIPT_DIR"
    echo -e "${GREEN}Folder '$SCRIPT_DIR' created successfully.${NC}"
fi

# Step 2: Copy scripts from user-specified directory to script directory
read -e -p "Enter the directory containing your scripts: " SCRIPT_SOURCE_DIR

for file in "$SCRIPT_SOURCE_DIR"/*.sh; do
    filename=$(basename "$file")
    new_filename="${PREFIX_SCRIPT_FILE}${filename}"
    new_file="${SCRIPT_DIR}/${new_filename}"
    touch "$new_file" && chmod +x "$new_file"
    cat "$file" >>"$new_file"
done

echo -e "${CYAN}Copying scripts from '$SCRIPT_SOURCE_DIR' to '$SCRIPT_DIR'...${NC}"

for file in "$SCRIPT_SOURCE_DIR"/*.sh; do
    if [[ "$file" == *"$PREFIX_SCRIPT_FILE"* ]]; then
        filename=$(basename "$file")
        new_filename="${filename#$PREFIX_SCRIPT_FILE}"
        if [ -f "$SCRIPT_DIR/$new_filename" ]; then
            read -p "File '$new_filename' already exists in script directory. Overwrite? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                cp -f "$file" "$SCRIPT_DIR"/
            else
                echo -e "${YELLOW}Skipping file '$new_filename'.${NC}"
            fi
        else
            cp "$file" "$SCRIPT_DIR"/
        fi
    fi
done

# Step 3: Add script directory to PATH environment variable

# Function to check and add path to file
check_and_add_path() {
    local file="$1"
    local path_to_add="$2"
    if ! grep -qF "$path_to_add" "$file"; then
        echo "$path_to_add" >>"$file"
        reload_shell "$file"
    fi
}

# Function to reload shells
reload_shell() {
    local file="$1"
    case "$SHELL" in
    */bash)
        source "$file"
        ;;
    */zsh)
        source "$file"
        ;;
    */fish)
        source "$file"
        ;;
    *)
        echo "Unsupported shell type: $SHELL"
        exit 1
        ;;
    esac
}

# Execute the function to add path to file
if [ -f "$bash_profile" ]; then
    check_and_add_path "$bash_profile" "$path_to_add"
elif [ -f "$bashrc" ]; then
    check_and_add_path "$bashrc" "$path_to_add"
elif [ -f "$zshrc" ]; then
    check_and_add_path "$zshrc" "$path_to_add"
elif [ -f "$fish_config" ]; then
    check_and_add_path "$fish_config" "$path_to_add"
else
    echo "Unsupported shell type: $SHELL_TYPE"
    exit 1
fi

# Step 4: Verify script directory is in PATH
if echo "$PATH" | grep -q "$SCRIPT_DIR"; then
    echo -e "${GREEN}Script directory added to PATH successfully.${NC}"
else
    echo -e "${YELLOW}Error: Script directory not added to PATH.${NC}"
    exit 1
fi

# Prompt user to grant execution permissions
echo -e "${CYAN}Please run the following command to grant execution permissions to the scripts:${NC}"
echo -e "${CYAN}chmod +x ~/.glbscr/*${NC}"
