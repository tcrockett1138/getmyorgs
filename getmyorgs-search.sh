!/bin/bash

# Given a search string, find all the orgs for all users that match that string

# Get the username string we're interested in
if [[ -z $1 ]]; then
  echo "Please specify a serach string to search for users and get their orgs"
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
# Get the user urls for all matched users
user_page=1
i=0
echo "Found $user_pages pages full of happy little users"
echo "Searching all the happy little users can take some time, please be patient"
echo user_page $user_page
echo user_pages $user_pages
while (( $user_page <= $user_pages )); do
  for user_url in $(cf curl /v2/users?results-per-page=100\&page=$user_page | jq -r '.resources[].metadata.url'); do
    user_urls[i]=$user_url
    # echo i is $i
    # echo user_urls_i ${user_urls[i]}
    (( i++ ))
  done
  # echo user_page is $user_page  
  (( user_page++ ))
done

# Test if user_url is still not set after searching all the pages
# If user_url is empty, that means that the given username string was not found
##### need to fix this test #####
if [[ -z $user_url ]]; then
  printf "\nNo users matching the string '$user' can be found\n\n"
  exit 1
else
  echo "found $i matches to $user"
fi

# Get the orgs for the matched users
i=0
###  Itereate through all the user_urls and get the username and orgs for each user
while (( i < ${#user_urls[@]} )); do
  # user_orgs=$(cf curl ${user_urls[i]}? | jq -r '.resources | .[].entity.organizations_url')
  user_orgs=$(cf curl $(cf curl ${user_urls[i]} | jq -r '.entity.organizations_url') | jq -r '.resources[].entity.name')
  user_name=$(cf curl ${user_urls[i]}? | jq -r '.entity.username')
  printf "\nThe user '$user_name' is a member of the following orgs:\n"
  printf "$user_orgs\n"
  (( i++ ))
done

