# 获取当前用户环境变量的"Path"
$currentPath = [Environment]::GetEnvironmentVariable('Path', 'User')

# 检查是否包含指定路径
$targetPath = 'D:\Applications\Scoop\shims'
$containsTargetPath = $currentPath -split ';' -contains $targetPath

if (-not $containsTargetPath) {
    # 如果不包含指定路径，则添加
    $newPath = $currentPath + ';' + $targetPath
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host "已成功添加路径: $targetPath"

    # 刷新环境变量（仅适用于当前会话）
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'User')

} else {
    Write-Host "路径已存在: $targetPath"
}

# 打印出所有的"Path"
$newPathList = [Environment]::GetEnvironmentVariable('Path', 'User') -split ';'
Write-Host "所有的Path:"
$newPathList


# 设置SCOOP的ROOT PATH
scoop config root_path D:\Applications\Scoop
scoop config proxy 127.0.0.1:1080
# 打印所有配置
scoop config

# 添加git仓库都为 安全
git config --global --add safe.directory "*"

## 建立run的插件目录

# SymbolicLink是通用的文件和目录链接机制，可以链接目录和文件，且可以链接不同盘上的目录和文件。 就是快捷方式
# Hard Link是在文件系统级别创建的链接，只能链接文件，且只能链接同一个盘上的文件。
# Junction是Windows特有的目录连接机制，只能链接目录，且可以跨越不同的盘。
New-Item -ItemType Junction -Path "$env:LOCALAPPDATA\Microsoft\PowerToys\PowerToys Run\Plugins" -Target "D:\Applications\Scoop\persist\PowerToys\PowerToys Run\Plugins"

