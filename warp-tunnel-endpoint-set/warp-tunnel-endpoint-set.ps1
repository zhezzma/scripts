# warp优选ip

function Get-CurrentWarpEndpoint {
    # 执行warp-cli settings命令并捕获输出
    $output = warp-cli settings

    # 使用正则表达式查找包含特定文本的行
    $endpointLine = $output | Select-String "\(user set\)\s+Override WARP endpoint: (.+)"

    # 如果找到行，则从匹配结果中提取IP:端口字符串
    if ($endpointLine -ne $null) {
        # 正则匹配结果中Groups集合的第二个元素包含了IP:端口字符串
        $currentEndpoint = $endpointLine.Matches.Groups[1].Value

        # 返回当前Endpoint
        $currentEndpoint
    } else {
        return $null
    }
}

Write-Output "运行前,确保你的所有代理都关闭了!"
Read-Host "按 Enter 键继续"

CloudflareWarpSpeedTest -f "$PSScriptRoot\ipv4.txt" -o "$PSScriptRoot\result.csv"

# 等待命令执行完毕，确保结果已写入文件
Start-Sleep -Seconds 2

# 读取并解析 result.csv 文件
$resultData = Get-Content -Path "$PSScriptRoot\result.csv"

# 获取第二行记录（跳过标题行）
$secondLine = $resultData[1]

# 分析第二行内容并提取 IP 地址
$endpoint = $secondLine.Split(',')[0]
$loss = $secondLine.Split(',')[1]
$delay = $secondLine.Split(',')[2]

# 获得当前的endpoint
$currentEndpoint = Get-CurrentWarpEndpoint
if ($currentEndpoint) {
    Write-Output "当前Endpoint: $currentEndpoint"
}
# 以下用 warp-cli 执行命令更新 endpoint
warp-cli disconnect > $null 2>&1
warp-cli tunnel endpoint reset > $null 2>&1
warp-cli tunnel endpoint set $endpoint
$currentEndpoint = Get-CurrentWarpEndpoint
if ($currentEndpoint) {
    Write-Output "当前Endpoint: $currentEndpoint"
}
warp-cli connect > $null 2>&1

# 打印信息，即 result.csv 的第二行记录

$message = @"
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::                                                                 ::
           自选服务器已经设置为$endpoint
           丢包率 $loss 平均延迟 $delay               
::                                                                 ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
"@
Write-Output $message 
