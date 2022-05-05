#!/bin/sh
set -eu


# This script will dismiss all open code scanning alerts for the default branch (usually main or master).

# Instructions:
#  1. Install the GitHub CLI: https://github.com/cli/cli#installation
#  2. Obtain a personal access token with the "security_events" scope
#     to use this script with a private repo, or the "public_repo"
#     scope on a public repo. See 
#     https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
#     to find out how to obtain such a token

export GITHUB_TOKEN="INSERT_YOUR_TOKEN_HERE"
repo='INSERT_REPOSITORY_SCOPE_AND_NAME_HERE'  # example: yongmams/sql-project-cicd
hostname='INSERT_HOSTNAME_OF_YOUR_GITHUB_SERVER_INSTANCE_HERE'  # example: github.com

gh api \
  --hostname "$hostname" \
  -H "Accept: application/vnd.github.v3+json" \
  --paginate \
  --jq '.[].number' \
  /repos/${repo}/code-scanning/alerts \
| \
while read alert_num; do
  echo 'Dismissing alert ${alert_num}...'
  gh api \
    --hostname "$hostname" \
    --method PATCH \
    -H "Accept: application/vnd.github.v3+json" \
    "/repos/${repo}/code-scanning/alerts/${alert_num}" \
    -f state='dismissed' \
    -f dismissed_reason='false positive' \
    -f dismissed_note='Dismissed via a custom script'
done
