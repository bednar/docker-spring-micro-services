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

STARTUP_OPTIONS_PATH=$(cd `dirname $0` && pwd)/startup.options

#
# Config
#
echo "Configuration"
echo "-------------"
echo
echo " * startup.options path: " $STARTUP_OPTIONS_PATH
echo


#
# Print recipes
#
echo "Recipes used in the Container"
echo "-----------------------------"
echo

cat $STARTUP_OPTIONS_PATH | \
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

cat $STARTUP_OPTIONS_PATH | \
    jq -rc '.recipes[]' | while IFS='' read stack;do
        recipeName=$(echo "$stack" | jq -rc .name)
        recipeLogs=$(echo "$stack" | jq -rc '.logFiles[]')

        if [ ! -z "$recipeLogs" ]; then
            echo " *" $recipeName":" $recipeLogs
            for recipeLog in $recipeLogs
            do
                mkdir -p `dirname $recipeLog`;
                touch $recipeLog;
                chmod a+w $recipeLog;
            done
        fi
    done