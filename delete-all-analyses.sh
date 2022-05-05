#!/bin/sh

# This script will delete all Code Scanning analysis results and alerts on all branches

# Instructions:
#  1. Install the GitHub CLI: https://github.com/cli/cli#installation
#  2. Obtain a personal access token with the "security_events" scope
#     to use this script with a private repo, or the "public_repo"
#     scope on a public repo. See
#     https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token
#     to find out how to obtain such a token

export GITHUB_TOKEN="ADD_YOUR_TOKEN_HERE"
REPOSITORY="ADD_YOUR_REPOSITORY_NAME_HERE"    # example: zbazztian/sql-project-cicd4
HOSTNAME='INSERT_THE_HOSTNAME_OF_YOUR_GITHUB_SERVER_INSTANCE_HERE'  # example: github.com

while true; do
  analyses="$(gh \
    api \
    --hostname "$HOSTNAME" \
    -H "Accept: application/vnd.github.v3+json" \
    --paginate \
    --jq '.[] | select(.deletable == true) | .id' \
    "/repos/${REPOSITORY}/code-scanning/analyses")"

  if [ ! "$?" -eq 0 ]; then
    exit 0
  fi

  echo -n "$analyses" \
    | \
    xargs \
      -I {} \
      gh api \
      --hostname "$HOSTNAME" \
      --method DELETE \
      -H "Accept: application/vnd.github.v3+json" \
      "/repos/${REPOSITORY}/code-scanning/analyses/{}?confirm_delete"
done
