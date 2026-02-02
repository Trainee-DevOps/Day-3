# Web Server Log Analyzer (Day 3 Project)

## Overview

The **Web Server Log Analyzer** is a Bash-based tool designed to analyze web server access logs (Nginx or Apache).  
It helps identify traffic patterns, errors, suspicious activities, and potential DDoS attacks.

The script supports:
- Log analysis (static)
- Real-time log monitoring
- HTML and JSON report generation

This project demonstrates practical Linux, Bash scripting, and DevOps monitoring skills.

---

## Project Structure

```text
web_log_analyzer/
├── log_analyzer.sh
├── sample_logs/
│   └── access.log
└── output/
    ├── log_report.html
    └── log_data.json
```
# Script Explanation – log_analyzer.sh

This document explains the `log_analyzer.sh` script in simple and practical terms.
The goal is to help understand what each part of the script does and why it is used.

---

## 1. Shebang

```bash
#!/bin/bash
```
> ### 1. Variable Definitions
>>```bash
>>LOG_FILE="$2"
>>```
>>* Stores the log file path provided as the second command-line argument.

>>**Example:**
>>```bash
>>./log_analyzer.sh analyze sample_logs/access.log
>>```

>> In this case:
>> * `LOG_FILE = sample_logs/access.log`

>> ```bash
>> OUT_DIR="./output"
>> HTML_REPORT="$OUT_DIR/log_report.html"
>> JSON_REPORT="$OUT_DIR/log_data.json"
>>```
>>**Defines:**
>> * The directory where reports will be stored
>> * The HTML report file
>> * The JSON report file

>> ```bash
>> mkdir -p "$OUT_DIR"
>> ```
>> * Creates the output directory if it does not already exist.
>> * This prevents errors when writing report files.

> ### 2. Usage Function
>> ```bash
>> usage() {
>>    echo "Usage:"
>>    echo "  $0 analyze sample_logs/access.log"
>>    echo "  $0 monitor sample_logs/access.log"
>>    exit 1
>> }
>> ```
>> **This Funtion displays instructions on how to run the script correctly.**
>> * `$0` prints the script name automatically
>> * `exit 1` stops execution due to incorrect usage

>> ```bash
>> [[ $# -lt 2 ]] && usage
>> ```
>> * Checks if fewer than two arguments are provided.
>> * If true, the script shows the usage message and exits.

> ### 3. Analyze Mode Funtion
>> ```bash
>> analyze_logs() {
>> ```
>> * This function performs log analysis.
>> * It runs only when the script is executed in `analyze` mode.

>>> #### Total Requests
>>> ```bash
>>> TOTAL_REQ=$(wc -l < "$LOG_FILE")
>>> ```
>>> * Counts the total number of lines in the log file.
>>> * Each line represents one HTTP request.

>>> #### Count 404 Errors
>>> ```bash
>>> ERROR_404=$(awk '$9==404' "$LOG_FILE" | wc -l)
>>> ```
>>> * Counts how many requests returned an HTTP 404 status code.
>>> * The 9th field in the log represents the status code.

>>> #### Count 500 Errors
>>> ```bash
>>> ERROR_500=$(awk '$9>=500' "$LOG_FILE" | wc -l)
>>> ```
>>> * Counts server-side errors such as 500, 502, and 503.

>>> #### Bandwidth Usage
>>> ```bash
>>> BANDWIDTH=$(awk '{sum+=$10} END {print sum/1024 " KB"}' "$LOG_FILE")
>>> ```
>>> * Calculates total bandwidth usage.
>>> * The 10th field in the log represents the response size in bytes.

>>> #### Top 10 IP Addresses
>>> ```bash
>>> TOP_IPS=$(awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -10)
>>> ```
>>> * Finds the IP addresses that made the most requests.

>>> #### Top 10 Requested URLs
>>> ```bash
>>> TOP_URLS=$(awk '{print $7}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -10)
>>> ```
>>> * Identifies the most frequently accessed URLs.

>>> #### Possible DDoS Detection
>>> ```bash
>>> DDOS=$(awk '{print $1}' "$LOG_FILE" | sort | uniq -c | awk '$1>100')
>>> ```
>>> * Flags IP addresses that made more than 100 requests.
>>> * This may indicate abnormal or malicious traffic.

>>> #### Suspicious Requests
>>> ```bash
>>> SUSPICIOUS=$(grep -E "(\.env|wp-admin|/admin|/login)" "$LOG_FILE")
>>> ```
>>> **Detects common attack attempts such as:**
>>> * Accessing `.env` files
>>> * WordPress admin scans
>>> * Admin or login page probing

> ### 4. JSON Report Generation
>> ```bash
>> echo "{" > "$JSON_REPORT"
>> ```
>> * Creates a JSON file containing structured analysis data.
>> * This output is useful for automation, dashboards, or integrations.

> ### 5. HTML Report Generation
>> ```bash
>> cat <<EOF > "$HTML_REPORT"
>> ```
>> * Generates an HTML report using a here-document.
>> * The report is human-readable and displays analysis results in a web browser.

> ### 6. Monitor Mode Function
>> ```bash
>> monitor_logs() {
>> ```
>> * Monitors the log file in real time.

>> ```bash
>> tail -F "$LOG_FILE"
>> ```
>> * Continuously follows the log file and handles log rotation.

>> ```bash
>> if [[ "$STATUS" == "404" || "$STATUS" -ge 500 ]]; then
>> ```
>> * Checks for client and server errors.

>> ```bash
>> echo "[ALERT] $IP requested $URL (Status: $STATUS)"
>> ```
>> * Displays real-time alerts for error requests.

> ### 7. Main Control Logic
>> ```bash
>> case "$1" in
>> ```
>> * Determines which mode to execute based on the first argument.

>> ```bash
>> analyze) analyze_logs ;;
>> monitor) monitor_logs ;;
>> ```
>> * Calls the appropriate function depending on the selected mode.

>> ```bash
>> *) usage ;;
>> ```
>> * Displays the usage message if an invalid mode is provided.

## The `log_analyzer.sh` script:
* Analyzes web server access logs
* Detects errors and suspicious behavior
* Generates HTML and JSON reports
* Supports real-time monitoring

# Commands
**Analyze logs**
```bash
./log_analyzer.sh analyze sample_logs/access.log
```

**Monitor Logs**
```bash
./log_analyzer.sh monitor sample_logs/access.log
```


# Mode Wise Flow Explanation
## Analyze Mode Flow
```text
User → analyze mode
        ↓
Validate log file
        ↓
Extract IP addresses
        ↓
Extract requested URLs
        ↓
Extract HTTP status codes
        ↓
Find error responses (4xx / 5xx)
        ↓
Generate HTML report
        ↓
Generate JSON data
        ↓
Analysis complete
```

## Monitor Mode Flow
```text
User → monitor mode
        ↓
Check log file exists
        ↓
Start tail -f
        ↓
Display new log entries
        ↓
User stops with Ctrl + C
```