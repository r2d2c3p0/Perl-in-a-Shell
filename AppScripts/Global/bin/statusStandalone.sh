#!/usr/bin/env bash

######################################################################################################################
#
# name: statusStandalone.sh
# author: Shane Reddy
# version: 1.0.0v
# dob: 01/28/2020
# explanation: Status script for EAP 7.2 Standalone servers.
# dependencies: bash & EAP 7.2 installation.
# modifications: (01/28/2020 1.0.0v) initial version.
#
# contact: shane.reddy@ttiinc.com
#
######################################################################################################################

######################################################################################################################
# environment variables.
######################################################################################################################
export jboss_home=/apps/jboss-eap-7.2
export log_directory=/apps/logs/standalone
export script_directory=/tti

# Development, QA & Production environment variables.
export ppqastandalone_address=10.1.63.90 # QA IP address
export jvm_port=8080 # JVM HTTP port
export management_port=9990

# default variables (time is in seconds)
host_name=$(hostname)
fid_name="jboss"

# Tool switches.
got_logger=1
got_verbose=1
got_debug=0

# This switch is important to make the current server as primary for PaymentProcessing QA environment.
is_primary=1

######################################################################################################################
# functions.
######################################################################################################################
function clear_screen {
    { clear; echo; echo;      } 2>/dev/null  ||
    { tput clear; echo; echo; } 2>/dev/null  ||
    for empty_space in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 ; do
        echo
    done
}

function Echo {
    debug_messages=${1}
    show_me=${2}
    log_me=${3}
    log_level=${4}
    Message=${5}
    date_recorded=$(date +[%m/%d/%Y\ %H:%M:%S\ %Z])
    host_name=$(hostname -f)
    if [[ ${show_me} -eq 1 ]]; then
       if [[ ${log_level} -eq 0 ]]; then
          if [[ ${debug_messages} -eq 1 ]]; then
             echo "    (debug) ${Message}"
          fi
       elif [[ ${log_level} -eq 1 ]]; then
          echo "    (INFO) ${Message}"
       elif [[ ${log_level} -eq 2 ]]; then
          echo "    (WARN) ${Message}"
       elif [[ ${log_level} -eq 3 ]]; then
          echo "    (ERROR) ${Message}"
       elif [[ ${log_level} -eq 4 ]]; then
          echo "    (FATAL) ${Message}"
       else
          echo "    (??) ${Message}"
       fi
    fi
    if [[ ${log_me} -eq 1 ]]; then
       if [[ ${log_level} -eq 0 ]]; then
          if [[ ${debug_messages} -eq 1 ]]; then
             echo "${date_recorded}|${host_name}|debug| ${Message}" >> ${log_directory}/statusStandalone.log
          fi
       elif [[ ${log_level} -eq 1 ]]; then
          echo "${date_recorded}|${host_name}|INFO| ${Message}" >> ${log_directory}/statusStandalone.log
       elif [[ ${log_level} -eq 2 ]]; then
          echo "${date_recorded}|${host_name}|WARN| ${Message}" >> ${log_directory}/statusStandalone.log
       elif [[ ${log_level} -eq 3 ]]; then
          echo "${date_recorded}|${host_name}|ERROR| ${Message}" >> ${log_directory}/statusStandalone.log
       elif [[ ${log_level} -eq 4 ]]; then
          echo "${date_recorded}|${host_name}|FATAL| ${Message}" >> ${log_directory}/statusStandalone.log
       else
          echo "${date_recorded}|${host_name}|??| ${Message}" >> ${log_directory}/statusStandalone.log
       fi
    fi
}

function check_if_app_is_ready {
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "inside 'check_if_app_is_ready'."
    ppqa_return=$(python ${script_directory}/py/app_ready.py "PaymentProcessing QA" "http://${ppqastandalone_address}:${jvm_port}" "201")
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "http://${ppqastandalone_address}:${jvm_port} 201."
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "ppqa_return=${ppqa_return}."
    if [[ ${ppqa_return} -eq 0 ]]; then
        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Application (PaymentProcessing QA) is UP."
    else
        Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Application (PaymentProcessing QA) is DOWN."
    fi
}

function start_server {
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "inside 'start_server'."
    timeout 1 bash -c "</dev/tcp/${ppqastandalone_address}/${management_port}" >/dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        Echo ${got_debug} ${got_verbose} ${got_logger} 2 "Server (Standalone) @ ${host_name}:${management_port} is UP."
        check_if_app_is_ready
    else
        Echo ${got_debug} ${got_verbose} ${got_logger} 2 "Server (Standalone) @ ${host_name}:${management_port} is DOWN."
    fi
}

function print_help {
    echo ""
    echo "      ./statusStandalone.sh.sh --server or --version or --help or --info"
    echo "          shortcut convention: ./statusStandalone.sh.sh [-s/ -v/ -h/ -i]"
    echo ""
    echo "      --server|-s --> performs status operation on Standalone server/ JVM."
    echo ""
    echo "      Below switches are used for logging purposes"
    echo "      '--noverbose|-nv' will disable STDOUT and only a warning message will be printed alerting the user."
    echo "      '--nolog|-nl' will disable logging and a warning message will be printed alerting the user."
    echo "      '--debug|-d' enables debug mode for logging."
    echo ""
    echo "      Below operations will force the program to exit immediately, do not use with any other operations!"
    echo "          --help|-h prints this information."
    echo "          --info|-i prints meta information of the tool."
    echo "          --version|-v prints tool version."
    echo ""
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "program exit with '0'"
    exit 0
}

######################################################################################################################
# main.
######################################################################################################################
clear_screen
echo "" >> ${log_directory}/statusStandalone.log; echo "---" >> ${log_directory}/statusStandalone.log
if [[ ${is_primary} -eq 1 ]]; then
    echo;echo
    Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Server ${host_name} is selected as primary for PaymentProcessing QA environment."
    Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Engage Middleware team if this is incorrect."
    echo;echo
else
    echo;echo
    Echo ${got_debug} ${got_verbose} ${got_logger} 2 "Server ${host_name} is NOT primary for PaymentProcessing QA environment."
    Echo ${got_debug} ${got_verbose} ${got_logger} 1 "Please engage Middleware team for support."
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "program exit with '1'"
    echo;echo
    exit 1
fi
if [[ $# -eq 0 ]]; then
    Echo ${got_debug} ${got_verbose} ${got_logger} 3 "Usage error, refer below help information."
    print_help
else
    input_arguments="${@}"
    for i_a in $(echo ${input_arguments}); do
        case ${i_a} in
            --info|-i)
                    sed -n '4,14'p $0 | sed 's/#/        /'
                    shift;
                    exit 0
                    ;;
            --version|-v)
                    sed -n '7'p $0 | awk '{print $3}'
                    shift;
                    exit 0
                    ;;
            --nolog|-nl)
                    got_logger=0
                    echo " (WARNING) logging disabled by user."
                    ;;
            --debug|-d)
                    got_debug=1
                    echo " (INFO) 'debug' enabled by user."
                    ;;
            --noverbose|-nv)
                    got_verbose=0
                    echo " (WARNING) verbose output disabled by user."
                    ;;
            --help|-h)
                    print_help
                    shift;
                    ;;
            *)
                    dipper="doppleganger";
                    ;;
        esac
    done
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "tool starting with below values,"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "jboss_home=${jboss_home}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "log_directory=${log_directory}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "script_directory=${script_directory}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "jvm_port=${jvm_port}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "management_port=${management_port}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "ppqastandalone_address=${ppqastandalone_address}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "host_name=${host_name}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "fid_name=${fid_name}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "application_start_time=${application_start_time}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "got_logger=${got_logger}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "got_verbose=${got_verbose}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "got_debug=${got_debug}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "${@}"
    Echo ${got_debug} ${got_verbose} ${got_logger} 1 "'status' operation begin on '${host_name}'."
    while [[ $# -ne 0 ]]; do
        case ${1} in
                    --server|-s)
                            start_server
                            shift;
                            ;;
                    --nolog|-nl)
                            shift;
                            ;;
                    --debug|-d)
                            shift;
                            ;;
                    --noverbose|-nv)
                            shift;
                            ;;
                    *)
                            Echo ${got_debug} ${got_verbose} ${got_logger} 3 "Invalid input argument ${1}!"
                            print_help;
                            ;;
        esac
    done
    Echo ${got_debug} ${got_verbose} ${got_logger} 1 "'status' operation completed on '${host_name}'."
    Echo ${got_debug} ${got_verbose} ${got_logger} 0 "program exit with '0'"
    chown -R jboss:jboss ${jboss_home} ${log_directory} ${script_directory}
    echo;exit 0
fi

#end_statusStandalone.sh