#!/bin/bash
# =====================================================
# Web Server Log Analyzer
# Author: Haseef
# Day 3 Project - DevOps/Linux
# =====================================================

LOG_FILE="$2"
OUT_DIR="./output"
HTML_REPORT="$OUT_DIR/log_report.html"
JSON_REPORT="$OUT_DIR/log_data.json"

mkdir -p "$OUT_DIR"

usage() {
    echo "Usage:"
    echo "  $0 analyze sample_logs/access.log"
    echo "  $0 monitor sample_logs/access.log"
    exit 1
}

[[ $# -lt 2 ]] && usage

# ------------------------------
# Analyze Mode
# ------------------------------
analyze_logs() {
    echo "[+] Analyzing log file: $LOG_FILE"

    TOTAL_REQ=$(wc -l < "$LOG_FILE")
    ERROR_404=$(awk '$9==404' "$LOG_FILE" | wc -l)
    ERROR_500=$(awk '$9>=500' "$LOG_FILE" | wc -l)
    BANDWIDTH=$(awk '{sum+=$10} END {print sum/1024 " KB"}' "$LOG_FILE")

    TOP_IPS=$(awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -10)
    TOP_URLS=$(awk '{print $7}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -10)

    DDOS=$(awk '{print $1}' "$LOG_FILE" | sort | uniq -c | awk '$1>100')
    SUSPICIOUS=$(grep -E "(\.env|wp-admin|/admin|/login)" "$LOG_FILE")

    # JSON Export
    echo "{" > "$JSON_REPORT"
    echo "  \"total_requests\": $TOTAL_REQ," >> "$JSON_REPORT"
    echo "  \"errors\": {\"404\": $ERROR_404, \"500\": $ERROR_500}," >> "$JSON_REPORT"
    echo "  \"bandwidth\": \"$BANDWIDTH\"," >> "$JSON_REPORT"

    echo "  \"top_ips\": [" >> "$JSON_REPORT"
    echo "$TOP_IPS" | awk '{printf "    {\"ip\":\"%s\",\"count\":%s},\n",$2,$1}' >> "$JSON_REPORT"
    echo "  ]," >> "$JSON_REPORT"

    echo "  \"top_urls\": [" >> "$JSON_REPORT"
    echo "$TOP_URLS" | awk '{printf "    {\"url\":\"%s\",\"count\":%s},\n",$2,$1}' >> "$JSON_REPORT"
    echo "  ]" >> "$JSON_REPORT"
    echo "}" >> "$JSON_REPORT"

    # HTML Report
    cat <<EOF > "$HTML_REPORT"
<html>
<head>
<title>Web Log Report</title>
<style>
body { font-family: Arial; }
table { border-collapse: collapse; }
td, th { border: 1px solid #333; padding: 6px; }
</style>
</head>
<body>

<h1>Web Server Log Analysis</h1>

<p><b>Total Requests:</b> $TOTAL_REQ</p>
<p><b>404 Errors:</b> $ERROR_404</p>
<p><b>500 Errors:</b> $ERROR_500</p>
<p><b>Total Bandwidth:</b> $BANDWIDTH</p>

<h2>Top 10 IPs</h2>
<pre>$TOP_IPS</pre>

<h2>Top 10 URLs</h2>
<pre>$TOP_URLS</pre>

<h2>Possible DDoS Sources</h2>
<pre>$DDOS</pre>

<h2>Suspicious Requests</h2>
<pre>$SUSPICIOUS</pre>

</body>
</html>
EOF

    echo "[✓] Analysis complete"
    echo "[✓] HTML Report: $HTML_REPORT"
    echo "[✓] JSON Data: $JSON_REPORT"
}

# ------------------------------
# Monitor Mode
# ------------------------------
monitor_logs() {
    echo "[+] Monitoring logs in real-time..."
    tail -F "$LOG_FILE" | while read line; do
        STATUS=$(echo "$line" | awk '{print $9}')
        IP=$(echo "$line" | awk '{print $1}')
        URL=$(echo "$line" | awk '{print $7}')

        if [[ "$STATUS" == "404" || "$STATUS" -ge 500 ]]; then
            echo "[ALERT] $IP requested $URL (Status: $STATUS)"
        fi
    done
}

# ------------------------------
# Main
# ------------------------------
case "$1" in
    analyze) analyze_logs ;;
    monitor) monitor_logs ;;
    *) usage ;;
esac
