$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"
    
Describe "wallpaper" {
    
    Context "准备测试环境" {
        # 准备测试环境
        New-Item ~/temp/cache -ItemType Directory
        New-Item ~/temp/root -ItemType Directory
        New-Item ~/temp/cache/1 
        New-Item ~/temp/cache/2
        New-Item ~/temp/cache/3
    }

    Context "测试开始：" {
        # 预测试值
        $wallpaper = [Wallpaper]::new("~/temp/root/dir")
        $wallpaper.CachePath = "~/temp/cache"
        $wallpaper.Ext = ".txt"
        
        It "验证变量[预测试值]： " {
            $wallpaper.CachePath | Should -Be "~/temp/cache"
            $wallpaper.Ext | Should -Be ".txt"
        }

        It "获取壁纸文件地址 Wallpaper::GetWallpaperFilePath" {
            $wallpaper.GetWallpaperFilePath("1") | Should -Be "~/temp/root/dir/1.txt"
        }

        It "获取壁纸缓存文件地址 Wallpaper::GetCacheFilePath" {
            $wallpaper.GetCacheFilePath("1") | Should -Be "~/temp/cache/1"
        }

        It "操作壁纸 Cache2Path" {
            $wallpaper.Cache2Path() | Should -Be 3
        }

        It "操作壁纸 Cache2Path" {
            $wallpaper.Cache2Path() | Should -Be 0
        }
    }
    
    Context "删除测试环境" {
        # 删除测试环境
        Remove-Item ~/temp/cache -Recurse
        Remove-Item ~/temp/root -Recurse
    }
}

