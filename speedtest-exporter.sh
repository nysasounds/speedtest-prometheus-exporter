#!/usr/bin/env bash

speedtest --secure --json | jq -r '  . |
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
'
