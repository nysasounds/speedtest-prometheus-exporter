# speedtest-cli and prometheus exporter

Measure internet bandwidth using speedtest.net, and expose stats for collecting via prometheus.

This is a docker container which creates a prometheus exporter from the output of speedtest.net CLI utility, speedtest-cli.

The exporter is implemented using https://github.com/ricoberger/script_exporter

## Stats

The metrics exported include:
- `sent_bytes`
- `received_bytes`
- `latency_seconds`
- `download_bps`
- `upload_bps`
- `server_info`
  - Includes a number of labels with info about the server
- `client_info`
  - Includes a number of labels with info about the client

The exported output looks like this:

```
    "# HELP speedtest_sent_bytes Sent Bytes",
    "# TYPE speedtest_sent_bytes gauge",
    "speedtest_sent_bytes \(.bytes_sent)",

    "# HELP speedtest_received_bytes Received Bytes",
    "# TYPE speedtest_received_bytes gauge",
    "speedtest_received_bytes \(.bytes_received)",

    "# HELP speedtest_latency_seconds ICMP Response Time",
    "# TYPE speedtest_latency_seconds gauge",
    "speedtest_latency_seconds \(.ping)",

    "# HELP speedtest_download Download Speed in Bits/Second",
    "# TYPE speedtest_download gauge",
    "speedtest_download_bps \(.download)",

    "# HELP speedtest_upload Upload Speed in Bits/Second",
    "# TYPE speedtest_upload gauge",
    "speedtest_upload_bps \(.upload)",

    "# HELP speedtest_server_info Server Info",
    "# TYPE speedtest_server_info gauge",
    "speedtest_server_info{id=\"\(.server.id)\",name=\"\(.server.name)\",country=\"\(.server.cc)\",latitude=\"\(.server.lat)\",longitude=\"\(.server.lon)\",distance=\"\(.server.d)\"} 1",

    "# HELP speedtest_client_info Client Info",
    "# TYPE speedtest_client_info gauge",
    "speedtest_client_info{address=\"\(.client.ip)\",country=\"\(.client.country)\"} 1"
```

## Testing

Run the container:
```
$ docker run -rm -p 9469:9469 nysasounds/speedtest-prometheus-exporter:0.0.1
```

Test the exporter.
It will take apprx 30 secs to return any output,and of course your output will vary.
```
$ curl "http://localhost:9469/probe?script=speedtest"

# HELP script_success Script exit status (0 = error, 1 = success).
# TYPE script_success gauge
script_success{script="speedtest"} 1
# HELP script_duration_seconds Script execution time, in seconds.
# TYPE script_duration_seconds gauge
script_duration_seconds{script="speedtest"} 21.605509
# HELP script_exit_code The exit code of the script.
# TYPE script_exit_code gauge
script_exit_code{script="speedtest"} 0
# HELP speedtest_sent_bytes Sent Bytes
# TYPE speedtest_sent_bytes gauge
speedtest_sent_bytes 32759808
# HELP speedtest_received_bytes Received Bytes
# TYPE speedtest_received_bytes gauge
speedtest_received_bytes 409373932
# HELP speedtest_latency_seconds ICMP Response Time
# TYPE speedtest_latency_seconds gauge
speedtest_latency_seconds 14.036
# HELP speedtest_download Download Speed in Bits/Second
# TYPE speedtest_download gauge
speedtest_download_bps 364154469.9981576
# HELP speedtest_upload Upload Speed in Bits/Second
# TYPE speedtest_upload gauge
speedtest_upload_bps 25706621.102737594
# HELP speedtest_server_info Server Info
# TYPE speedtest_server_info gauge
speedtest_server_info{id="12345",name="London",country="GB",latitude="12.3456",longitude="0.1234",distance="12.3456789"} 1
# HELP speedtest_client_info Client Info
# TYPE speedtest_client_info gauge
speedtest_client_info{address="123.456.123.456",country="GB"} 1
```

## Prometheus

Example prometheus config could like something like this:

```
global:
  scrape_interval: 1h

scrape_configs:
  - job_name: 'speedtest'
    static_configs:
      - targets:
        - "speedtest:9469"
    metrics_path: "/probe"
    params:
      script: ["speedtest"]
    scrape_timeout: "1m"
    relabel_configs:
      - target_label: script
        replacement: speedtest

remote_write:
- url: https://prometheus-server
  bearer_token: some-super-secret-token

```

## Docker Compose Stack

You might want to create a small stack with this container and a prometheus container, which sends metrics to a remote prometheus ingestion somewhere, perhaps New Relic or any other prometheus ingestion provider.

There is an example docker-compose stack here: https://github.com/nysasounds/speedtest-stack
