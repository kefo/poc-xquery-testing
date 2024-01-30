#!/bin/bash

# SETTINGS FOR THIS FILE ARE IN `config`
# CHANGE THIS FILE ONLY IF YOU ARE CHANGING THE LOGIC

##################################################################
# This protects against not being able to locate the `config` file.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

BASE_URL=$1
BASEX_EXEC=$DIR/basex


echo
echo "Testing suggest-service2.xqy"
$BASEX_EXEC -bBASE_URL=$BASE_URL $DIR/../tests/suggest-service2.xqy

echo
echo
echo "Testing jsonld.xqy"
$BASEX_EXEC -bBASE_URL=$BASE_URL $DIR/../tests/jsonld.xqy