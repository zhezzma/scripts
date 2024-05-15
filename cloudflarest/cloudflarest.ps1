
Write-Output "运行前,确保你的所有代理都关闭了!"
Read-Host "按 Enter 键继续"


$port = 443
# https://github.com/zhepamagod/CloudflareSpeedTest
CloudflareST.exe -n 1000 -tp $port  -f "$PSScriptRoot\ipv4.txt" -o "$PSScriptRoot\result.csv" -url https://speedtest.zhepama.com/100m

# # 等待命令执行完毕，确保结果已写入文件
Start-Sleep -Seconds 2

# 读取并解析 result.csv 文件
$csvContent = Get-Content -Path "$PSScriptRoot\result.csv"

# 初始化输出的IP列表
$ipList = @()

# 跳过标题行，并遍历CSV中的每一行
$csvContent | Select-Object -Skip 1 | ForEach-Object {
    # 切割每行以逗号为分隔符
    $columns = $_ -split ','
    # 获取IP地址，位于第一列
    $ip = $columns[0]
    # 添加格式化的IP到列表
    $ipList += $ip +":"+ $port + "#SPEEDTEST"
}
Write-Output $ipList
# 将转换后的内容保存到一个新文件
$outputPath = "$PSScriptRoot\addressesapi.txt"
$ipList | Out-File -FilePath $outputPath

# 输出保存路径供参考
Write-Output "Formatted IPs saved to $outputPath"