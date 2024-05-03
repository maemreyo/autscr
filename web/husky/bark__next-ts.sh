#!/bin/bash

# Color codes for console logs
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

rm -rf .husky

mkdir -p ".husky"
touch ".husky/pre-commit"
touch ".husky/commit-msg"
touch ".husky/prepare-commit-msg"

echo -e "${GREEN}Creating prepare-commit-msg file...${NC}"
prepare_commit_msg='#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

exec </dev/tty && npx cz --hook || true
'
echo "$prepare_commit_msg" >.husky/prepare-commit-msg
chmod +x .husky/prepare-commit-msg
echo -e "${GREEN}prepare-commit-msg file created.${NC}"

echo -e "${GREEN}Creating pre-commit file...${NC}"
pre_commit='#!/usr/bin/env sh

# Run tests before commit
npm run test

# Run lint-staged before commit
npx lint-staged
'
echo "$pre_commit" >.husky/pre-commit
chmod +x .husky/pre-commit
echo -e "${GREEN}pre-commit file created.${NC}"

echo -e "${GREEN}Creating commit-msg file...${NC}"
commit_msg='#!/usr/bin/env sh

# Check commit message format
npx commitizen cz --hook=true'
echo "$commit_msg" >.husky/commit-msg
chmod +x .husky/commit-msg
echo -e "${GREEN}commit-msg file created.${NC}"

echo -e "${YELLOW}Adding devDependencies to package.json...${NC}"
# Add devDependencies to package.json
npm install --save-dev husky lint-staged commitizen cz-conventional-changelog @commitlint/cli @commitlint/config-conventional

echo -e "${YELLOW}Adding scripts to package.json...${NC}"
# Add scripts to package.json
npx json -I -f package.json -e 'this.scripts["prepare-commit-msg"] = "husky run prepare-commit-msg"'
npx json -I -f package.json -e 'this.scripts["commit-msg"] = "husky run commit-msg"'
npx json -I -f package.json -e 'this.scripts["pre-commit"] = "husky run pre-commit"'

echo -e "${YELLOW}Adding lint-staged configuration to package.json...${NC}"
# # Add lint-staged configuration to package.json
# npx json -I -f package.json -e 'this.lintStaged = {
#   "*.{css,less,scss,html,json,jsx,js}": [
#     "prettier --write."
#   ],
#   "*.{js,ts}": "eslint --fix"
# }'

echo -e "${YELLOW}Adding commitizen configuration to package.json...${NC}"
# Add commitizen configuration to package.json
npx json -I -f package.json -e 'this.config = {
  "commitizen": {
    "path": "./node_modules/cz-conventional-changelog"
  }
}'

echo -e "${YELLOW}Creating commitlint.config.js file...${NC}"
# Add commitlint configuration file
echo "module.exports = {
  extends: [\"@commitlint/config-conventional\"] 
};" >commitlint.config.js

# echo -e "${YELLOW}Creating .husky/pre-commit and .husky/commit-msg files...${NC}"
# # Create .husky/pre-commit file

# echo "$prepare_commit_msg" >.husky/prepare-commit-msg
# chmod +x .husky/prepare-commit-msg

# echo "$pre_commit" >.husky/pre-commit
# chmod +x .husky/pre-commit

# echo "$commit_msg" >.husky/commit-msg
# chmod +x .husky/commit-msg

echo -e "${YELLOW}Creating .lintstagedrc.json file...${NC}"
# Create .lintstagedrc.json file
echo "{
  \"*.{css,less,scss,html,json,jsx,js}\": [\"prettier --write\"],
  \"*.{js,ts,tsx}\": \"eslint --fix\"
}" >.lintstagedrc.json

echo -e "${GREEN}Installing Husky locally...${NC}"
# Install husky
npx husky install

echo -e "${GREEN}Adding prepare-commit-msg script to Husky...${NC}"
# Add prepare-commit-msg script to husky
npx husky add .husky/prepare-commit-msg

echo -e "${GREEN}Adding pre-commit script to Husky...${NC}"
# Add pre-commit script to husky
npx husky add .husky/pre-commit

echo -e "${GREEN}Adding commit-msg script to Husky...${NC}"
# Add commit-msg script to husky
npx husky add .husky/commit-msg

echo -e "${YELLOW}[FIXED] In the terminal, there are some warnings about the husky hooks not being executable.${NC}"
echo -e "${YELLOW}This command will make them executable.${NC}"
# [FIXED] In the terminal, there're some warnings about the husky hooks not being executable.
# This command will make them executable.
chmod ug+x .husky/*

echo '----------------------------------------------'
echo -e "${GREEN}All done!${NC}"
echo -e "${GREEN}Let's try to run 'git add .' and then 'git commit -m \"Commit for testing purpose. Revert it later!\""
echo '----------------------------------------------'
