#!/bin/bash


./tests/generate.sh ls "$CHART_NAME" |\
    sed "s|^${PWD}/tests/${CHART_NAME}/values/||" |\
    jq -R -s -c 'split("\n")|map(select(length > 0))'
