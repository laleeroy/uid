#!/bin/bash
set -e

# Prompt for user details
read -p "Enter username (leave blank if none): " username
read -p "Enter UID (e.g. 5602546888073201): " uid

# Check UID input
if [[ -z "$uid" ]]; then
  echo "UID cannot be empty."
  exit 1
fi

# Ask for user type
echo "Select user type:"
select usertype in "public" "private"; do
  case $usertype in
    public)
      echo "Add $uid to public lists..."
      echo "$uid" >> temporary.uid
      echo "$uid" >> public.uid
      break
      ;;
    private)
      echo "Add $uid to private list..."
      echo "$uid" >> private.uid
      break
      ;;
    *)
      echo "Invalid choice. Please choose 1 or 2."
      ;;
  esac
done

# Build commit message
if [[ -z "$username" ]]; then
  commit_msg="Adding $uid to the $usertype list"
else
  commit_msg="Add user: $username ($uid) to $usertype list"
fi

# Commit and push changes
echo "Committing and pushing changes..."
git add temporary.uid public.uid private.uid 2>/dev/null || true
git commit -m "$commit_msg" || { echo "No changes to commit."; exit 0; }
git push

echo "Successfully added ${username:-$uid} to the $usertype list and pushed to repo."
