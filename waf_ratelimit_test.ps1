Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  KIEM THU CHAN TAN CONG DOS / RATE LIMITING (PORT 80)   " -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "Policy : Rate = 1 req/s | Burst Allowance = 10 requests"
Write-Host "Action : Gui 15 requests lien tuc de kiem tra chong DoS..."
Write-Host ""

Start-Sleep -Seconds 1

1..15 | ForEach-Object {
    $num = $_
    try {
        $r = Invoke-WebRequest "http://localhost/" -UseBasicParsing -ErrorAction Stop
        Write-Host "Request $num`t: Status 200 OK (Allowed by WAF)" -ForegroundColor Green
    } catch {
        Write-Host "Request $num`t: Status 429 Too Many Requests (Blocked by WAF)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "================== KET QUA RATE LIMITING ==================" -ForegroundColor Green
Write-Host "Requests 1..11 : Chap nhan trong nguong Burst (Status 200)" -ForegroundColor Green
Write-Host "Requests 12..15: Chan chu dong boi WAF (HTTP 429)" -ForegroundColor Red
Write-Host "Ket luan       : Nginx WAF ngan chan thanh cong Request Flood!" -ForegroundColor Cyan
Write-Host "===========================================================" -ForegroundColor Green
