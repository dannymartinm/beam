#!/bin/bash
set -o allexport; source var.env; set +o allexport

IMG=$( echo "$IMAGE" | base64 -d  ) 
REPO=$( echo "$GITHUB_REPO"| base64 -d )
TOKEN=$( echo "$GITHUB_TOKEN" | base64 -d )

echo $IMG , $REPO, $TOKEN

sed -e "s|_IMAGE|$IMG|g" -e "s|_GITHUB_REPO|$REPO|g" -e "s|_GITHUB_TOKEN|$TOKEN|g" github-actions-windows-deployment.yml > bash_deployment.yml



case $1 in 
    apply)
        echo "Creating and applying deployment with var.env values"
        kubectl apply -f bash_deployment.yml

    ;;

    remove)
        echo "Deleting deployment"
        kubectl remove -f bash_deployment.yml
    ;;
    *)
        echo "invalid option"
esac 

sudo rm -fr bash_deployment.yml