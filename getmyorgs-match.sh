#!/bin/bash

# Given a username, find all the orgs & spaces for that user

# Get the username we're interested in
if [[ -z $1 ]]; then
  echo "Please specify a username to search for orgs"
  exit 1
fi
user=$1

# Check to see if we're logged in and targeted
if cf api | grep "Not Logged in"  2>&1; then
  echo Not logged in. Use 'cf login' to log in.
  exit 1
fi

# Get # pages of users
user_pages=$(cf curl /v2/users?results-per-page=100 | jq -r '.total_pages')

# Find the number of 'pages' of users, 100 users per page
# Get the orgs url for the given user
user_page=1
i=0
echo "Found $user_pages pages full of happy little users"
echo "Searching all the happy little users can take some time, please be patient"
while (( $user_page <= $user_pages )); do
  # orgs_url=$(cf curl /v2/users?results-per-page=100\&page=$user_page | jq -r --arg user "$user" '.resources[].entity | select(.username == $user) | .organizations_url')
  for orgs_url in $(cf curl /v2/users?results-per-page=100\&page=$user_page | jq -r --arg user "$user" '.resources[].entity | select(.username | contains($user)) | .organizations_url'); do
    matched_users[i]=$orgs_url
    echo $i
    (( i++ ))
  done
#  if [[ $orgs_url ]]; then
    # orgs url is set, found a user, lets break
#    break
#  else
    # no org url set, lets increase the page count and check the next page
  (( user_page++ ))
#    continue
#  fi
done

# Test if orgs_url is still not set after searching all the pages
# If orgs_url is empty, that means that the given username was not found
if [[ -z $matched_users ]]; then
  printf "\nNo users matching the string '$user' can be found\n\n"
  exit 1
else
  # Subtract 1 from i to offset the final i++ in the loop
  echo "found $(( i-1 )) matches to $user"
fi

# Get the orgs for the matched users
i=0
###  Itereate through the len of the array to do all this stuff
echo ${#matched_users[@]}
while (( i <= ${#matched_users[@]} )); do
echo ${matched_users[i]}
#  user_orgs=$(cf curl ${matched_users[i]}? | jq -r '.resources | .[].entity.name')
  (( i++ ))
done

printf "\nThe user '$user' is a member of the following orgs:\n"
printf "$user_orgs\n"

