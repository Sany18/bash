#!/bin/bash

# Ensure the script is run inside a Git repository
if [ ! -d ".git" ]; then
  echo "Error: No Git repository found in the current directory!"
  exit 1
fi

# Ask for confirmation before proceeding
read -p "This will REMOVE all Git history and reset the repo. Continue? (y/n) " CONFIRM
if [[ "$CONFIRM" != "y" ]]; then
  echo "Aborted."
  exit 0
fi

# Get current remote URL
REMOTE_URL=$(git remote get-url origin)

if [[ -z "$REMOTE_URL" ]]; then
  echo "Error: No remote repository found. Please add a remote manually after reset."
  exit 1
fi

# Remove the .git directory
echo "Removing Git history..."
rm -rf .git

# Reinitialize the repository
git init
git add .
git commit -m "Initial commit (history cleared)"

# Re-add remote and push forcefully
git remote add origin "$REMOTE_URL"
git branch -M main  # Rename to main (modify if needed)
git push --force origin main

echo "Git history has been removed and repository reset!"
