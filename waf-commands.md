# CMU-CS 376 - WAF DEPLOYMENT DOCKER COMMANDS REFERENCE
**Course:** CMU-CS 376 CIS: Elements of Network Security  
**Student:** Nguyễn Ngọc Tú — ID: 30219251322  
**Instructor:** Thầy Lê Văn Tịnh — Duy Tan University (2026)  

---

## 1. Khởi chạy Ứng dụng đích (OWASP Juice Shop)
```bash
# Khoi chay container Juice Shop lang nghe tai cong 3000
docker run -d -p 3000:3000 --name clever_shtern bkimminich/juice-shop
```

## 2. Khởi chạy Tường lửa WAF (ModSecurity CRS on Nginx)
```bash
# Khoi chay WAF Reverse Proxy chuyen tiep luu luong vao host.docker.internal:3000
docker run -d -p 80:8080 \
  -e BACKEND=http://host.docker.internal:3000 \
  -e PARANOIA=1 \
  --name funny_cray \
  owasp/modsecurity-crs:nginx
```

## 3. Khởi chạy WAF với cấu hình Rule Exclusion (Khắc phục False Positive)
```bash
# Mount file custom-exclusion.conf vao thu muc rules cua container
docker run -d -p 80:8080 \
  -e BACKEND=http://host.docker.internal:3000 \
  -e PARANOIA=1 \
  -v $(pwd)/custom-exclusion.conf:/etc/modsecurity.d/owasp-crs/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf:ro \
  --name funny_cray \
  owasp/modsecurity-crs:nginx
```

## 4. Lệnh kiểm tra và quản lý Container
```bash
# Kiem tra trang thai container dang chay
docker ps

# Xem nhat ky kiem soat audit log cua WAF theo thoi gian thuc
docker logs -f funny_cray
```

## 5. Kịch bản kiểm thử Nmap quét cổng L4 vs L7
```bash
# Quet trinh sat cong 80 va 3000 bang container Nmap
docker run --rm instrumentisto/nmap -sV -p 80,3000 host.docker.internal
```

## 6. Kịch bản kiểm thử tải / DoS Benchmark
```powershell
# Chay script do luong do tre va throughput bang PowerShell
powershell -ExecutionPolicy Bypass -File .\waf_load_test.ps1
```
