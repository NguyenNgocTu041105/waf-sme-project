# CMU-CS 376: Open-Source WAF Deployment for SMEs
**Course:** CMU-CS 376 CIS: Elements of Network Security  
**Institution:** Duy Tan University (DTU)  
**Student:** Nguyễn Ngọc Tú (ID: 30219251322)  
**Instructor:** Thầy Lê Văn Tịnh  

---

## 📌 Project Overview
This repository contains the full deployment artifacts, configuration files, and benchmark scripts for deploying an open-source Web Application Firewall (WAF) using **ModSecurity v3** and **OWASP Core Rule Set (CRS) v3.3** on **Nginx Reverse Proxy** to protect Small and Medium Enterprises (SMEs) in Vietnam.

The target vulnerable web application is **OWASP Juice Shop** (Node.js).

---

## 🏛️ Network Architecture (WAN - DMZ - LAN)
```
[WAN: Public Internet] ──HTTP (Port 80)──> [DMZ: Nginx + ModSecurity WAF] ──Clean Forward (Port 3000)──> [LAN: Juice Shop]
         │                                               │
  (Attacker: SQLi/XSS)                         [403 Forbidden Block]
```

* **WAN Zone (Internet):** Untrusted public traffic (Legitimate Clients & Attackers).
* **DMZ Zone (Security Gateway):** Nginx Reverse Proxy with ModSecurity v3 and OWASP CRS v3.3.10 listening on Port 80 (mapped to container 8080).
* **LAN Zone (Protected Internal):** OWASP Juice Shop running on Port 3000, completely isolated from direct WAN access.

---

## 📂 Repository Contents
* `README.md`: System architectural documentation and project guide.
* `custom-exclusion.conf`: ModSecurity rule exclusion configuration resolving False Positives for `/socket.io/` (Rule 920420).
* `docker-commands.md`: Complete Docker deployment, port mapping, and container management commands.
* `test-scripts.ps1`: Automated PowerShell attack simulation harness (XSS, SQLi) and DoS load benchmarking scripts.
* `waf_log.txt`: Authentic ModSecurity audit logs demonstrating real-time HTTP 403 blocks (Rules 941100 and 942100).

---

## 🚀 Quick Start

### 1. Run Target Application (OWASP Juice Shop)
```bash
docker run -d -p 3000:3000 --name clever_shtern bkimminich/juice-shop
```

### 2. Run WAF Reverse Proxy
```bash
docker run -d -p 80:8080 \
  -e BACKEND=http://host.docker.internal:3000 \
  -e PARANOIA=1 \
  --name funny_cray \
  owasp/modsecurity-crs:nginx
```

### 3. Verification & Attacks
* **Direct Access (Vulnerable):** `http://localhost:3000/`
* **Protected Access (via WAF):** `http://localhost:80/`
* **Test XSS Attack:**
  `http://localhost:80/#/search?q=<script>alert(1)</script>` ➔ **HTTP 403 Forbidden**
* **Test SQL Injection:**
  Login with `' OR 1=1--` ➔ **HTTP 403 Forbidden**

---

## 📊 Experimental Results Summary
| Metric | Direct Access (Port 3000) | Protected Access (Port 80) | Impact / Status |
| :--- | :---: | :---: | :---: |
| **XSS Defense Rate** | 0% (Exploited) | 100% (Blocked 403) | Protected (Rule 941100) |
| **SQLi Defense Rate** | 0% (Admin Compromised) | 100% (Blocked 403) | Protected (Rule 942100) |
| **Average Latency** | 28.98 ms | 37.73 ms | Overhead: +8.75 ms (Acceptable) |
| **Throughput (100 reqs)** | 34.2 req/s | 26.29 req/s | 100% Success, 0 Crashes |
| **Nmap Service Scan** | Port 3000 Open | Port 80 Open (nginx) | Layer 7 only (Need L4 Firewall) |

---
*Developed for CMU-CS 376 Academic Capstone / Individual Project - Duy Tan University 2026.*
