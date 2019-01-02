#!/bin/sh

usage() {
    echo "Usage: $0 [-h] [-p <string>] -d <string> <string>...

    where:
    -h Show this help text
    -p Set path additional to default path
    -d Set directory the commands will be executed (mandatory)
    List of commands to be executed

    Example:
    To show home directory content, use
    $0 -d ~ \"ls -l\"
    "
    exit 1;
}

dflag=false # d argument is not set
colorReset="$(tput sgr0)" #reset
colorRed="$(tput setaf 1)" #red

while getopts ":p:d:h" opt; do
    case "$opt" in
        p) p=$OPTARG ;; # Optional path
        d) dflag=true; d=$OPTARG ;; # Project Directory. Mandatory
        h|*) usage ;;   # help
    esac
done
shift $(( OPTIND - 1 ))

# 1. Exit when mandatory directory argument is not present
if ! $dflag
then
    printf '%s%s%s\n' $colorRed 'Error:'$colorReset' -d argument missing'
    usage
fi

# 2. cd to directory
echo cd $d
cd $d

# 3. Set path if $p is set
if [ -n "$p" ]; then
    export PATH=$PATH:$p
fi
echo "PATH="$PATH

# 4. Execute the commands
for command in "$@"; do
    echo $command
    $command
done
