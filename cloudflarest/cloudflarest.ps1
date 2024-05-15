
Write-Output "运行前,确保你的所有代理都关闭了!"
Read-Host "按 Enter 键继续"

# https://github.com/zhepamagod/CloudflareSpeedTest
CloudflareST.exe -n 200 -tp 443  -f "$PSScriptRoot\ipv4.txt" -o "$PSScriptRoot\result.csv" -url https://speedtest.zhepama.com/100m
