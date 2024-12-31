#!/bin/bash

set -e -o pipefail

readonly d="$(cd "$(dirname "$0")" || exit 1; pwd)"
readonly release_name="tests"

generate() {
    local -r _chart="$1"
    local -r _dest="$2"
    local -r _value_file="$3"
    local -r _dest_file="${d}/${_chart}/${_dest}/$(basename "$_value_file")"
    echo "[generate] ${_value_file} -> ${_dest_file}" > /dev/stderr
    mkdir -p "$(dirname "$_dest_file")"
    helm template "$release_name" "charts/${_chart}" --values "$_value_file" > "$_dest_file"
}

list_values() {
    local -r _chart="$1"
    find "${d}/${_chart}/values" -type f
}

readonly cmd="$1"
shift
case "$cmd" in
    list | ls)
        list_values "$@"
        ;;
    *)
        readonly chart="$1"
        readonly dest="$2"
        list_values "$chart" | while read -r file ; do
            generate "$chart" "$dest" "$file"
        done
        ;;
esac
