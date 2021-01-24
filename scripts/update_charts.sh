#!/bin/bash
#
# Update charts reference in all branches
#

BRANCHES="feature/jump-app-cicd feature/jump-app-pre feature/jump-app-pro feature/jump-app-dev master"

for i in $BRANCHES
do
  echo "Updating charts in $i..."
  sleep 2
  git checkout $i
  git submodule update --remote
  git add ./charts
  git commit -m "Added new charts reference"
  git push origin $i
  echo ""
done