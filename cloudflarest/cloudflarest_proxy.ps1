
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

Write-Output "运行前,确保你的所有代理都关闭了!"
Read-Host "按 Enter 键继续"


# 设置下载链接和本地文件路径
$url = "https://zip.baipiao.eu.org"
$zipFilePath = "$PSScriptRoot\txt.zip"
$destinationFolder = "$PSScriptRoot\txt"

# 下载zip文件
Invoke-WebRequest -Uri $url -OutFile $zipFilePath
Write-Output "下载zip文件成功!"
# 创建解压目录，如果不存在的话
If (!(Test-Path -Path $destinationFolder)) {
    New-Item -ItemType Directory -Force -Path $destinationFolder
}

# 解压zip文件至目标文件夹
Expand-Archive -LiteralPath $zipFilePath -DestinationPath $destinationFolder -Force

# 删除下载的zip文件
Remove-Item -Path $zipFilePath
Write-Output "解压完毕,开始测试:"


$types = @(31898,45102)
$ports = @(443, 2053, 2083, 2087, 2096, 8443)



# CloudflareST.exe 的下载链接
$cloudflareSTUrl = "https://speedtest.zhepama.com/100m"

# 初始化输出的IP列表
$ipList = @()


foreach($type in $types)
{
    # 遍历端口号并执行命令
    foreach ($port in $ports) {
        Write-Output "Testing port $port..."

        $ipTxt = "$PSScriptRoot\txt\$type-1-$port.txt"
        $csvFile = "$PSScriptRoot\result-$type-$port.csv"

        #`echo ""` 会发送一个空的字符串作为输入（类似用户只是按了 Enter）
        echo " " | CloudflareST.exe -n 1000 -tp $port -dn 10  -p 10  -f $ipTxt  -o $csvFile -url $cloudflareSTUrl
        
        Start-Sleep -Seconds 2
        
        # 读取并解析对应端口号的 result.csv 文件
        $csvContent = Get-Content -Path $csvFile
        
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
            $ipList += $ip+":"+$port
        }
    }
}




# 最后将所有记录的IP:PORT组合输出到一个文本文件
$outputPath = "$PSScriptRoot\addressesapi_proxy.txt"
$ipList | Out-File -FilePath $outputPath -Encoding UTF8

# 输出保存路径供参考
Write-Output "Formatted IPs saved to $outputPath"