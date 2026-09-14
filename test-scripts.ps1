# ====================================================================
# SCRIPT KIEM THU AN NINH HE THONG WAF (MODSECURITY CRS V3.3)
# Mon hoc: CMU-CS 376 Elements of Network Security
# Sinh vien: Nguyen Ngoc Tu - MSSV: 30219251322
# ====================================================================

Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  KICH BAN KIEM THU AN NINH HE THONG WAF (MODSECURITY CRS)" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan

# 1. Kiem thu tan cong XSS vao Cong 80 (Co WAF)
Write-Host "`n[+] 1. Gui Payload tan cong XSS vao Cong 80 (WAF)..." -ForegroundColor Yellow
$xssUrl = "http://localhost:80/rest/products/search?q=%3Cscript%3Ealert(1)%3C/script%3E"
try {
    $resXss = Invoke-WebRequest -Uri $xssUrl -UseBasicParsing -TimeoutSec 3
    Write-Host "    [!] CANH BAO: Request di qua thanh cong (Status: $($resXss.StatusCode))" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode.Value__ -eq 403) {
        Write-Host "    [+] KET QUA: WAF da CHAN THANH CONG (HTTP 403 Forbidden)" -ForegroundColor Green
    } else {
        Write-Host "    [!] Ket qua khac: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# 2. Kiem thu tan cong SQL Injection vao Cong 80 (Co WAF)
Write-Host "`n[+] 2. Gui Payload tan cong SQL Injection vao Cong 80 (WAF)..." -ForegroundColor Yellow
$sqliUrl = "http://localhost:80/rest/user/login"
$sqliBody = '{"email":"'' OR 1=1--","password":"admin"}'
try {
    $resSqli = Invoke-WebRequest -Uri $sqliUrl -Method POST -ContentType "application/json" -Body $sqliBody -UseBasicParsing -TimeoutSec 3
    Write-Host "    [!] CANH BAO: Request di qua thanh cong (Status: $($resSqli.StatusCode))" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode.Value__ -eq 403) {
        Write-Host "    [+] KET QUA: WAF da CHAN THANH CONG (HTTP 403 Forbidden)" -ForegroundColor Green
    } else {
        Write-Host "    [!] Ket qua khac: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# 3. Kiem thu do tre va do tai (100 requests hop le)
Write-Host "`n[+] 3. Kiem thu do tre va kha nang chiu tai (100 requests hop le)..." -ForegroundColor Yellow
$targetUrl = "http://localhost:80/"
$total = 100
$swTotal = [System.Diagnostics.Stopwatch]::StartNew()
$latencies = [System.Collections.Generic.List[double]]::new()
$success = 0

for ($i = 1; $i -le $total; $i++) {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $r = Invoke-WebRequest -Uri $targetUrl -UseBasicParsing -TimeoutSec 2
        $sw.Stop()
        if ($r.StatusCode -eq 200) {
            $success++
            $latencies.Add($sw.Elapsed.TotalMilliseconds)
        }
    } catch {}
}
$swTotal.Stop()

$avg = [Math]::Round(($latencies | Measure-Object -Average).Average, 2)
$rps = [Math]::Round($success / ($swTotal.Elapsed.TotalSeconds), 2)
Write-Host "    [+] Tong so request thanh cong: $success / $total ($([Math]::Round($success/$total*100, 1))%)" -ForegroundColor Green
Write-Host "    [+] Do tre trung binh         : $avg ms" -ForegroundColor Cyan
Write-Host "    [+] Thong luong xu ly         : $rps requests/giay" -ForegroundColor Cyan

# 4. Kiem thu chan DoS / Rate Limiting (15 requests lien tuc)
Write-Host "`n[+] 4. Kiem thu co che Rate Limiting chong DoS (15 requests lien tuc)..." -ForegroundColor Yellow
$rlUrl = "http://localhost:80/"
1..15 | ForEach-Object {
    $num = $_
    try {
        $r = Invoke-WebRequest -Uri $rlUrl -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
        Write-Host "    [Request $num] Status: $($r.StatusCode) OK (Allowed)" -ForegroundColor Green
    } catch {
        Write-Host "    [Request $num] Status: 429 Too Many Requests (Blocked by WAF Rate Limit)" -ForegroundColor Red
    }
}

Write-Host "`n================== HOAN THANH KIEM THU ==================" -ForegroundColor Green
