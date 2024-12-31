# fluent-sandbox

The chart adds a basic configuration of fluent to the cluster for functional verification.

## Install

``` shell
helm repo add fluent-sandbox https://berquerant.github.io/k8s-fluent-sandbox
helm repo update
helm install <RELEASE_NAME> fluent-sandbox/fluent-sandbox
```

## Usage

``` shell
❯ kubectl exec deploy/<RELEASE_NAME>-bastion -- send -h
/usr/local/bin/send -- send test data to fluentd

TARGET is fluentd.name or fluentBit.name.

/usr/local/bin/send TARGET PORT http PATH [CURL_OPT...]
  Send HTTP request to TARGET.
  https://docs.fluentd.org/input/http

/usr/local/bin/send TARGET PORT cat TAG [FLUENT_CAT_OPT...]
  Forward data from stdin to TARGET.
  https://docs.fluentd.org/deployment/command-line-option#fluent-cat

Environment variables:
  DEBUG
    Enable debug output if set.

Examples:
# Post {"msg":"test"} with tag: test.log to fluentd port 28080.
/usr/local/bin/send fluentd 28080 http /test.log -d 'json={"msg":"test"}'
# Forward {"msg":"test"} with tag: test.log to fluentd port 24224.
echo '{"msg":"test"}' | /usr/local/bin/send fluentd 24224 cat test.log
```

## Bastion

Deployment for sending sample data.

## Fluentd

List of StatefulSet and Service of fluentd.

## FluentBit

List of StatefulSet and Service of fluent-bit.
