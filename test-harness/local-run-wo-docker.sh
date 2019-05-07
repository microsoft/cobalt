#!/bin/bash
#---------- see https://github.com/joelong01/BashWizard ----------------
# bashWizard version 1.0.0
# this will make the error text stand out in red - if you are looking at these errors/warnings in the log file
# you can use cat <logFile> to see the text in color.

. ./test-harness/init.sh --source-only

# make sure this version of *nix supports the right getopt
! getopt --test 2>/dev/null
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echoError "'getopt --test' failed in this environment. please install getopt."
    read -r -p "install getopt using brew? [y,n]" response
    if [[ $response == 'y' ]] || [[ $response == 'Y' ]]; then
        ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null
        brew install gnu-getopt
        #shellcheck disable=SC2016
        echo 'export PATH="/usr/local/opt/gnu-getopt/bin:$PATH"' >> ~/.bash_profile
        echoWarning "you'll need to restart the shell instance to load the new path"
    fi
   exit 1
fi

function usage() {
    
    echo "Builds and runs the test harness container. This container runs all build target tasks on the host machine. These targets include mage clean, format, unit and integration tests. This base image also pre-installs the golang vendor. "
    echo ""
    echo "Usage: $0  -a|--tf_state_storage_acct -c|--tf_state_container -t|--template_name_override " 1>&2
    echo ""
    echo " -a | --tf_state_storage_acct       Optional     "
    echo " -c | --tf_state_container          Optional     "
    echo " -t | --template_name_override      Optional     "
    echo ""
    exit 1
}
function echoInput() {
    echo "local-run-wo-docker.sh:"
    echo -n "    tf_state_storage_acct...... "
    echoInfo "$tf_state_storage_acct"
    echo -n "    tf_state_container.... "
    echoInfo "$tf_state_container"
    echo -n "    template_name_override.... "
    echoInfo "$template_name_override"

}

function parseInput() {

    local OPTIONS=a:c:t:
    local LONGOPTS=tf_state_storage_acct:,tf_state_container:,template_name_override:

    # -use ! and PIPESTATUS to get exit code with errexit set
    # -temporarily store output to be able to check for errors
    # -activate quoting/enhanced mode (e.g. by writing out "--options")
    # -pass arguments only via -- "$@" to separate them correctly
    ! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
    if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
        # e.g. return value is 1
        # then getopt has complained about wrong arguments to stdout
        usage
        exit 2
    fi
    # read getopt's output this way to handle the quoting right:
    eval set -- "$PARSED"
    while true; do
        case "$1" in
        -a | --tf_state_storage_acct)
            tf_state_storage_acct=$2
            shift 2
            ;;
        -c | --tf_state_container)
            tf_state_container=$2
            shift 2
            ;;
        -t | --template_name_override)
            template_name_override=$2
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echoError "Invalid option $1 $2"
            exit 3
            ;;
        esac
    done
}

# Bind environment from .env
dotenv

# input variables
declare tf_state_storage_acct="cobaltfstate"
declare tf_state_container="cobaltfstate-remote-state-container"
declare template_name_override=""

# Parse user input arguments
parseInput "$@"

export TF_STATE_STORAGE_ACCT=$tf_state_storage_acct
export TF_STATE_CONTAINER=$tf_state_container

readonly BUILD_SOURCEBRANCHNAME=`git branch | sed -n '/\* /s///p'`
readonly BUILD_UPSTREAMBRANCH="master"
readonly GOLANG_DEP_MANIFEST_FILE="Gopkg.lock"

function move_target_template_to_build_dir() {
    add_template_if_not_exists $template_name_override
    echoInfo "INFO: moving terraform files for template $template_name_override to ${BUILD_TEMPLATE_DIRS}/"
    load_build_directory
}

function setup_manifest_dependencies_if_not_exists() {
    if [ ! -f $GOLANG_DEP_MANIFEST_FILE ]; then
        echoInfo "INFO: Setting up golang manifest and vendor packages" \
        && dep init -v 
    fi
}

function run_test_harness() {
    remove_build_directory
    echoInfo "INFO: loading environment"
    check_required_env_variables
    echoInput
    echoInfo "INFO: verified that environment is fully defined"
    setup_manifest_dependencies_if_not_exists
    echoInfo "INFO: Installing new vendor packages"
    dep ensure -vendor-only -v

    case "$template_name_override" in
        "")        template_build_targets $BUILD_UPSTREAMBRANCH $BUILD_SOURCEBRANCHNAME ;;
        *)         move_target_template_to_build_dir ;;
    esac
    echoInfo "INFO: Running automated test harness"
    cd $BUILD_TEMPLATE_DIRS && go run magefile.go && cd -
    remove_build_directory
}


run_test_harness