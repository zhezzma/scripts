Write-Output "运行前,确保你的所有代理都关闭了!"
Read-Host "按 Enter 键继续"

# CloudflareST.exe 的下载链接
$cloudflareSTUrl = "https://speedtest.zhepama.com/100m"

CloudflareWarpSpeedTest -n 1000  -p 10 -f "$PSScriptRoot\ipv4.txt" -o "$PSScriptRoot\result.csv" 


# 等待命令执行完毕，确保结果已写入文件
Start-Sleep -Seconds 2
