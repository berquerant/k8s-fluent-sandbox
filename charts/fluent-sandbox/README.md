# fluent-sandbox

The chart adds a basic configuration of fluent to the cluster for functional verification.

## Install

``` shell
helm repo add fluent-sandbox https://berquerant.github.io/k8s-fluent-sandbox
helm repo update
helm install <RELEASE_NAME> fluent-sandbox/fluent-sandbox
```

or

``` shell
helm install <RELEASE_NAME> oci://ghcr.io/berquerant/k8s-fluent-sandbox/charts/fluent-sandbox
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

## `bastion`

Deployment for sending sample data.

## `fluentd`

List of StatefulSet and Service of fluentd.

The elements will inherit the elements of `defaultFluentd`.
Any elements that are not specified will have the same value as the corresponding elements in `defaultFluentd`.

## `fluentBit`

List of StatefulSet and Service of fluent-bit.

The elements will inherit the elements of `defaultFluentBit`.
Any elements that are not specified will have the same value as the corresponding elements in `defaultFluentBit`.

## Example of forwarding events to `fluentd`

Forward `f1` to `f2`.

``` yaml
fluentd:
  - name: f1
    conf: |
      config:
        - source:
            $type: http
            bind: 0.0.0.0
            port: 28080
        - match:
            $type: forward
            $tag: '**'
            flush_interval: 1s
            server:
              - name: f2
                host: "<RELEASE_NAME>-fluent-sandbox-f2"
                port: 24224
  - name: f2
    conf: |
      config:
        - source:
            $type: forward
            bind: 0.0.0.0
            port: 24224
        - match:
            $type: stdout
            $tag: '**'
```

Send a log:

``` shell
# at bastion
send f1 28080 http /test.log -d 'json={"msg":"test"}'
```
