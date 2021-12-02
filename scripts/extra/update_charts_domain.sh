#!/bin/bash
#
# Update charts reference in all branches
#


if [ -z "$1" ]
then
	echo "Usage: ./scripts/extra/update_charts_domain.sh <domain>"
	echo "Example:"
	echo "  ./scripts/extra/update_charts_domain.sh apps.acidonpe.sandbox507.opentlc.com"
	exit 0
fi 

BRANCHES="feature/jump-app-cicd feature/jump-app-pre feature/jump-app-pro feature/jump-app-dev"
APPS_DOMAIN=$1

for i in $BRANCHES
do
  echo "Adding ${APPS_DOMAIN} domain in $i..."
  sleep 2
  git checkout $i
  sed -i "s/appsDomain: .*$/appsDomain: ${APPS_DOMAIN}/" values.yaml
  git add values.yaml
  git commit -m "Added ${APPS_DOMAIN} domain in appsDomain parameter"
  git push origin $i
  echo ""
done

git checkout master