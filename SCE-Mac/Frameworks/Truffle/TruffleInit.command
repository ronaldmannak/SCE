#!/bin/sh

# ${1} is work directory
# ${2} is project name
# ${3} (optional) template name

echo '$ cd '${1}
cd ${1}

HOME=${2}
export HOME

if [ "$#" -eq  "2" ]
then

# If there's no template name passed,
# create an empty project
  echo '$ truffle init'
  truffle init

else

  # unbox template
  echo '$ truffle unbox '${3}
  truffle unbox ${3}

  echo '$ npm install openzeppelin-solidity'
  npm install openzeppelin-solidity

  echo '$ solium --init'
  solium --init
fi

echo 'Done.'
