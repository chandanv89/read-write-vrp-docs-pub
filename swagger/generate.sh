#!/usr/bin/env bash

# first parameter is the full path for the source. For example: 
# ./stuff.yaml or /home/me/stuff.yaml or https://myschemas.com/some.yaml
# following parameters are the paths to the objects inside the yaml file

# full example: ./vrp-swagger.yaml components.schemas.OBCashAccountDebtorWithName
SOURCE=$1
for ((i = 2; i <= $#; i++ )); do
	IFS='.' read -ra ADDR <<< "${!i}"
	SCHEMAPATH=${!i}
	OBJECTNAME=${ADDR[-1]}

	obgenerate --src=$SOURCE --path=$SCHEMAPATH --out="$OBJECTNAME.svg"
done
