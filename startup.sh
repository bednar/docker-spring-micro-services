#!/bin/bash
#
# The Startup script which care about:
#
# * Prepare log files
# * Start services
# * Run health-check scripts
# * Run provisioning scripts
#

echo "************************************************************"
echo "*               docker-spring-micro-services               *"
echo "************************************************************"
echo


#
# Print recipes
#
echo "Recipes used in the Container"
echo "-----------------------------"
echo

cat startup.options | \
    jq -rc '.recipes[]' | while IFS='' read stack;do
        recipeName=$(echo "$stack" | jq -r .name)
        recipeVersion=$(echo "$stack" | jq -r .version)
        echo " *" $recipeName "["$recipeVersion"]"
    done

#
# Create Log Files
#
echo
echo "Create Log Files"
echo "----------------"
echo

cat startup.options | \
    jq -rc '.recipes[]' | while IFS='' read stack;do
        recipeName=$(echo "$stack" | jq -rc .name)
        recipeLogs=$(echo "$stack" | jq -rc '.logFiles[]')

        if [ ! -z "$recipeLogs" ]; then
            echo " *" $recipeName":" $recipeLogs
        fi
    done