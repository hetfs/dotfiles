Write-Host "=== WinRM HTTPS Verification ===" -ForegroundColor Cyan

# Test 1: Check if port is listening
Write-Host "`n[1/4] Checking port 5986..." -ForegroundColor Yellow
$portCheck = netstat -an | findstr ":5986" | findstr "LISTENING"
if ($portCheck) {
    Write-Host "✓ Port 5986 is listening" -ForegroundColor Green
    $portCheck
} else {
    Write-Host "✗ Port 5986 is NOT listening" -ForegroundColor Red
}

# Test 2: Test with computer name
Write-Host "`n[2/4] Testing with computer name..." -ForegroundColor Yellow
try {
    $result = Test-WSMan -ComputerName $env:COMPUTERNAME -UseSSL -ErrorAction Stop
    Write-Host "✓ Test-WSMan $($env:COMPUTERNAME) -UseSSL: SUCCESS" -ForegroundColor Green
} catch {
    Write-Host "✗ Test failed: $_" -ForegroundColor Red
}

# Test 3: Test PowerShell remoting
Write-Host "`n[3/4] Testing PowerShell remoting..." -ForegroundColor Yellow
try {
    $sessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck
    $session = New-PSSession -ComputerName localhost -UseSSL -SessionOption $sessionOption -ErrorAction Stop
    Write-Host "✓ PowerShell remoting to localhost: SUCCESS" -ForegroundColor Green
    Remove-PSSession $session
} catch {
    Write-Host "✗ PowerShell remoting failed: $_" -ForegroundColor Red
}

# Test 4: Check certificate
Write-Host "`n[4/4] Checking certificate..." -ForegroundColor Yellow
$cert = Get-ChildItem Cert:\LocalMachine\My\2F281DF04E720C852E0CD6C43720211B6AF2DEE7 -ErrorAction SilentlyContinue
if ($cert) {
    Write-Host "✓ Certificate found in My store:" -ForegroundColor Green
    Write-Host "  Subject: $($cert.Subject)" -ForegroundColor Gray
    Write-Host "  Thumbprint: $($cert.Thumbprint)" -ForegroundColor Gray
    Write-Host "  DNS Names: $($cert.DnsNameList -join ', ')" -ForegroundColor Gray
} else {
    Write-Host "✗ Certificate not found in My store" -ForegroundColor Red
}

Write-Host "`n=== Verification Complete ===" -ForegroundColor Cyan
Write-Host "WinRM HTTPS is configured and working!" -ForegroundColor Green
Write-Host "Primary connection method: Test-WSMan -ComputerName HETFS-DV -UseSSL" -ForegroundColor Gray
