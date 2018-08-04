#!/bin/bash

# Given a username, find all the orgs & spaces for that user

# Get the username we're interested in
if [[ -z $1 ]]; then
  echo "Please specify a username to search for orgs"
  exit 1
fi
user=$1

# Check to see if we're logged in and targeted
if ! cf target 2&>1; then
  echo Please log in first...
fi

# Get # pages of users
user_pages=$(cf curl /v2/users?results-per-page=100 | jq -r '.total_pages')

# Get the orgs url and spaces url for the given user
# page=1; while page <= $user_pages; do orgs_url; if found url, break/continue, else user not found after all pages searched
user_page=1
echo "Found $user_pages pages of users"
while (( $user_page <= $user_pages )); do
  echo working on page $user_page
  orgs_url=$(cf curl /v2/users?results-per-page=100\&page=$user_page | jq -r --arg user "$user" '.resources[].entity | select(.username == $user) | .organizations_url')
  if [[ $orgs_url ]]; then
    echo orgs url is set, found a user lets break
    break
  else
    echo no org url set, lets increase the page count
    (( user_page++ ))
    continue
  fi
done
echo just exited the loop
echo we are about to test if orgs_url is not set

# If orgs_url is empty, that means that the given username was not found
if [[ -z $orgs_url ]]; then
  echo checking for empty orgs url
  printf "\nThe user '$user' cannot be found\n"
  exit 1
fi


# Get the orgs for the given user
user_orgs=$(cf curl $orgs_url | jq -r '.resources | .[].entity.name')

printf "\nThe user '$user' is a member of the following orgs:\n"
printf "$user_orgs\n"

