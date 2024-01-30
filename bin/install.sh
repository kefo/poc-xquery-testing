#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR/../lib/
curl -OL https://files.basex.org/releases/10.7/BaseX107.jar
cd $DIR