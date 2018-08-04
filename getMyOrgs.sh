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


# Get the orgs and spaces for the given user
user_orgs=$(cf curl $orgs_url | jq -r '.resources | .[].entity.name')

printf "\nThe user '$user' is a member of the following orgs:\n"
printf "$user_orgs\n"

# Is the user a member of any spaces?
spaces_url=$(cf curl /v2/users?results-per-page=100\&page=$user_page | jq -r --arg user "$user" '.resources[].entity | select(.username == $user) | .spaces_url')
if [[ -z $spaces_url ]]; then
  echo checking for empty spaces url
  printf "\nThe user '$user' is not a member of any spaces\n"
elif (( $(cf curl $spaces_url | jq -r .total_results) == 0 )); then
  printf "\nThe user '$user' is not a member of any spaces\n\n"
else
  space_pages=$(cf curl $spaces_url | jq -r .total_pages)
  space_page=1
  echo "Found $space_pages pages of spaces for '$user'"
  while (( $space_page <= $space_pages )); do
    user_spaces+=$(cf curl $spaces_url?result-per-page=100\&page=$space_page | jq -r '.resources | .[].entity.name')
    (( space_page++ ))
  done
  printf "\nThe user '$user' is a member of the following spaces:\n"
  printf "$user_spaces\n\n"
fi
