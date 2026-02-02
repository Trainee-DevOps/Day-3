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
### 1. Variable Definitions
```bash
LOG_FILE="$2"
```
* Stores the log file path provided as the second command-line argument.

**Example:**
```bash
./log_analyzer.sh analyze sample_logs/access.log
```

>> In this case:
`>>> **LOG_FILE = sample_logs/access.log**`
