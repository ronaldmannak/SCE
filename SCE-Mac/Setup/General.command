#!/bin/sh

#echo '$ '${1}

# Second argument found, set $HOME path
# required by brew
if [ "$#" -eq  "2" ]
then
  HOME=${2}
  export HOME
fi

${1}

