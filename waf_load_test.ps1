$url = "http://localhost:80/"
$totalRequests = 100
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "  BENCHMARK KIEM THU TAI / DOS MO PHONG TREN WAF (PORT 80)" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "Target: $url"
Write-Host "Tong so requests: $totalRequests"
Write-Host "Dang thuc hien gui requests dong thoi..."

$swTotal = [System.Diagnostics.Stopwatch]::StartNew()
$latencies = [System.Collections.Generic.List[double]]::new()
$successCount = 0
$failCount = 0

for ($i = 1; $i -le $totalRequests; $i++) {
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $res = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 3
        $sw.Stop()
        if ($res.StatusCode -eq 200) {
            $successCount++
            $latencies.Add($sw.Elapsed.TotalMilliseconds)
        } else {
            $failCount++
        }
    } catch {
        $failCount++
    }
}
$swTotal.Stop()

$avgLatency = [Math]::Round(($latencies | Measure-Object -Average).Average, 2)
$minLatency = [Math]::Round(($latencies | Measure-Object -Minimum).Minimum, 2)
$maxLatency = [Math]::Round(($latencies | Measure-Object -Maximum).Maximum, 2)
$rps = [Math]::Round($successCount / ($swTotal.Elapsed.TotalSeconds), 2)

Write-Host ""
Write-Host "================== KET QUA KIEM THU ==================" -ForegroundColor Green
Write-Host "Tong thoi gian chay      : $($swTotal.Elapsed.TotalSeconds.ToString("F2")) giay"
Write-Host "So requests thanh cong   : $successCount / $totalRequests ($([Math]::Round($successCount/$totalRequests*100, 1))%)" -ForegroundColor Green
Write-Host "Do tre trung binh (Avg) : $avgLatency ms" -ForegroundColor Yellow
Write-Host "Do tre thap nhat (Min)   : $minLatency ms"
Write-Host "Do tre cao nhat (Max)    : $maxLatency ms"
Write-Host "Thong luong (Throughput) : $rps requests/giay" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Green
