#!/usr/bin/env bash
#
# The Startup script which care about:
#
# * Prepare log files
# * Start services
# * Run health-check scripts
# * Run provisioning scripts
#
#
# Thx for the inspiration:
#
# * https://superuser.com/questions/186272/check-if-any-of-the-parameters-to-a-bash-script-match-a-string
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

if [[ "${@#--createLogFiles}" = "$@" ]]
then
    echo "disabled"
else
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
fi

#
# Start services
#
echo
echo "Start Services"
echo "--------------"

if [[ "${@#--startServices}" = "$@" ]]
then
    echo "disabled"
else
    echo
    cat $STARTUP_OPTIONS_PATH | \
    jq -rc '.recipes[]' | while IFS='' read stack;do
        recipeName=$(echo "$stack" | jq -rc .name)
        recipeService=$(echo "$stack" | jq -rc '.service')

        if [ -n "$recipeService" ]; then
            echo " *" $recipeName":" $recipeService
            service $recipeService start;
        fi
    done
fi

#
# Run Provisioning Scripts
#
echo
echo "Run Provisioning Scripts"
echo "------------------------"

if [[ "${@#--provisioning}" = "$@" ]]
then
    echo "disabled"
else
    echo
    cat $STARTUP_OPTIONS_PATH | \
    jq -rc '.recipes[]' | while IFS='' read stack;do
        recipeName=$(echo "$stack" | jq -rc .name)
        provisioningScripts=$(echo "$stack" | jq -rc '.provisioningScripts[]')

        if [ ! -z "$provisioningScripts" ]; then
            echo " *" $recipeName":"
            for provisioningScript in $provisioningScripts
            do
                echo "  - run script:" $provisioningScript
                $provisioningScript
            done
        fi
    done
fi

#
# Use Multitail for display log files
#
echo
echo "Use Multitail for display log files"
echo "-----------------------------------"

if [[ "${@#--multitail}" = "$@" ]]
then
    echo "disabled"
else
    echo
    multiTailColors=("green" "yellow" "blue" "magenta" "cyan" "white" "red")
    multiTailArgs=

    # Every log file has own color
    for logFile in `cat $STARTUP_OPTIONS_PATH | jq -rc '.recipes[] | .logFiles[]'`
    do
        # Pick first color
        multiTailColor=${multiTailColors[0]}
        # Shift array
        multiTailColors=("${multiTailColors[@]:1}")
        # Add to end of the array
        multiTailColors=( "${multiTailColors[@]}" "${multiTailColor}" )

        multiTailArg=" -ci $multiTailColor -I $logFile"
        echo " *" $multiTailArg

        multiTailArgs+=$multiTailArg
    done

    echo
    multitail -M 0 --follow-all $multiTailArgs
fi

