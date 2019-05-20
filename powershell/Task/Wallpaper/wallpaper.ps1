
# PowerShell Core 6.0
#

# 壁纸对象
class Wallpaper {
    # 焦点壁纸缓存路径
    [string]$CachePath = "~/AppData/Local/Packages/Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy/LocalState/Assets"

    # 壁纸保存目录
    [string]$SavePath = "~/Pictures/wallpapers"

    # 图片后缀
    [string]$Ext = ".png"

    # 使用默认参数
    Wallpaper() {
        # 新建壁纸文件夹
        if ( -not (Test-Path  $this.SavePath -PathType Container)) {
            New-Item $this.SavePath -ItemType Directory | Out-Null
        }
    }

    # 使用保存目录参数
    Wallpaper([string]$savePath) {
        # 壁纸保存目录
        $this.SavePath = $savePath

        # 新建壁纸文件夹
        if ( -not (Test-Path  $this.SavePath -PathType Container)) {
            New-Item $this.SavePath -ItemType Directory | Out-Null
        }
    }

    # 获取壁纸文件地址
    [string] GetWallpaperFilePath([string] $filename) {
        return $this.SavePath + '/' + $filename + $this.Ext
    }

    # 获取壁纸缓存文件地址
    [string] GetCacheFilePath([string] $filename) {
        return $this.CachePath + '/' + $filename
    }
    
    # 壁纸处理
    [uint] Cache2Path() {
        [uint32]$count = 0

        Get-ChildItem -Path $this.CachePath -File | ForEach-Object -Process {
            # 路径
            $wallpaperFilePath = $this.GetWallpaperFilePath($_.Name) # 对应壁纸路径
            $cacheFilePath = $this.GetCacheFilePath($_.Name) # 对应缓存路径

            # 操作
            if ( -not (Test-Path $wallpaperFilePath -PathType Leaf )) {
                Copy-Item $cacheFilePath -Destination $wallpaperFilePath
                $count++
            }
        }

        return [uint32]$count
    }
}

# 壁纸处理
function main() {
    $wallpaper = [Wallpaper]::new()
    $count = $wallpaper.Cache2Path()
    Write-Host "本次已经处理"$count" 张壁纸"
}

# 入口
main