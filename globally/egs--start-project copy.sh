#!/bin/bash

# Constants
REPO_URL="https://github.com/maemreyo/start-templates.git"
PROJECT_DIR=~/Documents/workspace/dev/projects/

# Functions
print_header() {
    echo -e "\033[1;32m$1\033[0m"
}

print_error() {
    echo -e "\033[1;31m$1\033[0m"
}

print_divider() {
    echo " "
    echo "---------------------------------"
    echo " "
}

# Main script
print_divider
print_header "Select a template in this list:"
print_divider
templates=$(git ls-remote --heads $REPO_URL | grep refs/heads/templates/ | cut -d/ -f3- | cut -d/ -f2-)
echo -e "\033[1;34m$templates\033[0m"
print_divider
echo " "

while true; do
    read -p "Enter the template name: " BRANCH

    if echo "$templates" | grep -qw "$BRANCH"; then
        break
    else
        print_error "Error: Template '$BRANCH' does not exist. Please try again."
    fi
done

print_divider
print_header "Enter a project name:"
read -p "Project name: " PROJECT_NAME

# Create a new directory for the user
mkdir -p "$PROJECT_DIR$PROJECT_NAME"

# Clone the repository and checkout the selected branch
print_header "Cloning into '$PROJECT_DIR$PROJECT_NAME'..."
git clone --branch "templates/$BRANCH" $REPO_URL "$PROJECT_DIR$PROJECT_NAME"

# Change into the new directory
cd "$PROJECT_DIR$PROJECT_NAME" || exit

# Pull the latest changes
print_header "Pulling latest changes..."
git pull origin "templates/$BRANCH"

# Remove the .git folder
print_header "Removing .git folder..."
rm -rf .git

# Update package.json with the PROJECT_NAME
if [ -f "package.json" ]; then
    sed -i "" "s/\"name\": \"$BRANCH-template\"/\"name\": \"$PROJECT_NAME\"/g" package.json
    print_header "Updated package.json with the project name: $PROJECT_NAME"
else
    print_error "package.json not found"
fi
