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
      
      # Check if UID exists in public.uid
      if grep -Fxq "$uid" public.uid; then
        echo "UID $uid already exists in public.uid. Adding to temporary.uid only..."
      else
        echo "Adding new UID $uid to public.uid..."
        echo "$uid" >> public.uid
      fi
      
      # Always add to temporary.uid
      echo "$uid" >> temporary.uid
      break
      ;;
      
    private)
      echo "Add $uid to private list..."
      
      # Check if UID exists in private.uid
      if grep -Fxq "$uid" private.uid; then
        echo "UID $uid already exists in private.uid. Skipping addition..."
        break
      else
        echo "Adding new UID $uid to private.uid..."
        echo "$uid" >> private.uid
        break
      fi
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
