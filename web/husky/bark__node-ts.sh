#!/bin/bash

# Add devDependencies to package.json
npm install --save-dev husky lint-staged

# Add scripts to package.json
npx json -I -f package.json -e 'this.scripts["prepare-commit-msg"] = "husky run prepare-commit-msg"'
npx json -I -f package.json -e 'this.scripts["commit-msg"] = "husky run commit-msg"'
npx json -I -f package.json -e 'this.scripts["pre-commit"] = "husky run pre-commit"'

# Add lint-staged configuration to package.json
npx json -I -f package.json -e 'this.lintStaged = {
  "*.{css,less,scss,html,json,jsx,js}": [
    "prettier --write."
  ],
  "*.{js,ts}": "eslint --fix"
}'

# Create .husky/pre-commit file
mkdir -p ".husky"
touch ".husky/pre-commit"
touch ".husky/commit-msg"
touch ".husky/prepare-commit-msg"

echo "#!/usr/bin/env sh

# Lint code before commit
npm run lint

# Run tests before commit
npm run test

# Run lint-staged before commit
npx lint-staged" >.husky/pre-commit
chmod +x.husky/pre-commit

# Create .husky/commit-msg file
echo "#!/usr/bin/env sh

# Check commit message format
npx commitizen cz --hook=true" >.husky/commit-msg
chmod +x.husky/commit-msg

# Create .lintstagedrc.json file
echo "{
  \"src/**/*.ts\": [\"npm run lint\", \"git add\"]
}" >.lintstagedrc.json

# Install husky
npx husky install

# Add pre-commit script to husky
npx husky add.husky/pre-commit

# Add commit-msg script to husky
npx husky add.husky/commit-msg

# [FIXED] In the terminal, there're some warnings about the husky hooks not being executable.
# This command will make them executable.
chmod ug+x .husky/*

# Reminder to run npm install
echo "Please run 'npm install'."
