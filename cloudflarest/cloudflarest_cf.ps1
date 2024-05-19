Write-Output "运行前,确保你的所有代理都关闭了!"
Read-Host "按 Enter 键继续"

# 定义要测试的端口号数组
$ports = @(443, 2053, 2083, 2087, 2096, 8443)

# CloudflareST.exe 的下载链接
$cloudflareSTUrl = "https://speedtest.zhepama.com/100m"

# 初始化输出的IP列表
$ipList = @()

# 遍历端口号并执行命令
foreach ($port in $ports) {
    Write-Output "Testing port $port..."

    # `echo ""` 会发送一个空的字符串作为输入（类似用户只是按了 Enter）
    echo "" | CloudflareST.exe -n 1000 -tp $port -dn 10  -p 10  -f "$PSScriptRoot\ipv4.txt" -o "$PSScriptRoot\result-$port.csv" -url $cloudflareSTUrl
    
    # 等待命令执行完毕，确保结果已写入文件
    Start-Sleep -Seconds 2
    
    # 读取并解析对应端口号的 result.csv 文件
    $csvContent = Get-Content -Path "$PSScriptRoot\result-$port.csv"
    
    # 跳过标题行，并遍历CSV中的每一行
    $csvContent | Select-Object -Skip 1 | ForEach-Object {
        # 切割每行以逗号为分隔符
        $columns = $_ -split ','

        # 检查条件丢包率大于75% 或者 延迟大于1000 或者 下载速度小于 1，跳过这行
        if ([float]$columns[3] -ge 0.75 -or [float]$columns[4] -ge 1000 -or [float]$columns[5] -le 1) {
            continue
        }
        # 获取IP地址，位于第一列
        $ip = $columns[0].Trim()
        # 添加格式化的IP到列表
        $ipList += $ip+":"+$port+"#SPEEDTEST"
    }
}

# 最后将所有记录的IP:PORT组合输出到一个文本文件
$outputPath = "$PSScriptRoot\addressesapi_cf.txt"
$ipList | Out-File -FilePath $outputPath -Encoding UTF8

# 输出保存路径供参考
Write-Output "Formatted IPs saved to $outputPath"