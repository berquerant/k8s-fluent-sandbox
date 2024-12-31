{{- $fullname := (include "fluent-sandbox.fullname" .) -}}
#!/bin/bash

usage() {
    cat <<EOS
$0 -- send test data to fluentd

TARGET is fluentd.name or fluentBit.name.

$0 TARGET PORT http PATH [CURL_OPT...]
  Send HTTP request to TARGET.
  https://docs.fluentd.org/input/http

$0 TARGET PORT cat TAG [FLUENT_CAT_OPT...]
  Forward data from stdin to TARGET.
  https://docs.fluentd.org/deployment/command-line-option#fluent-cat

Environment variables:
  DEBUG
    Enable debug output if set.

Examples:
# Post {"msg":"test"} with tag: test.log to fluentd port 28080.
$0 fluentd 28080 http /test.log -d 'json={"msg":"test"}'
# Forward {"msg":"test"} with tag: test.log to fluentd port 24224.
echo '{"msg":"test"}' | $0 fluentd 24224 cat test.log
EOS
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ] ; then
    usage
    exit
fi

__log() {
    echo "$*" > /dev/stderr
}

__err() {
    __log "$@"
    exit 1
}

target="$1"
port="$2"
shift 2

if [ -z "$target" ] ; then
    __err "TARGET is required"
fi
if [ -z "$port" ] ; then
    __err "PORT is required"
fi

host="{{ $fullname }}-${target}"

__http() {
    _path="$1"
    if [ -z "$_path" ] ; then
       __log "PATH is required"
       return 1
    fi
    shift
    curl "http://${host}:${port}${_path}" "$@"
}

__cat() {
    _tag="$1"
    if [ -z "$_tag" ] ; then
        __log "TAG is required"
        return 1
    fi
    shift
    fluent-cat "$_tag" --host "$host" --port "$port" "$@"
}

cmd="$1"
shift

set -e
if [ -n "$DEBUG" ] ; then
    set -x
fi
case "$cmd" in
    http) __http "$@" ;;
    cat) __cat "$@" ;;
    *)
        usage
        exit 1
esac
