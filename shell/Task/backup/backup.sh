#!/usr/bin/env bash

# 根目录
rootPath="/run/media/Disk/Backup"

# 目录备份
bakPath="${rootPath}/workspace"

# 配置备份
confBakPath="${rootPath}/config"

# 日志
logFile="${rootPath}/log/$(date '+%Y-%m').log"
touch ${logFile}

# 统计时间
date '+%Y-%m-%d %H:%M:%S: 备份开始' >> ${logFile}
start=$(date "+%s")


# Code 目录备份
CodePath="$HOME/Documents/Code"
sudo rsync -a ${CodePath} ${bakPath} >> ${logFile}

# myshell 目录备份
myshellPath="$HOME/Documents/myshell"
sudo rsync -a ${myshellPath} ${bakPath} >> ${logFile}

# App 目录备份
AppPath="$HOME/Documents/App"
sudo rsync -a ${AppPath} ${bakPath} >> ${logFile}

# Doc 目录备份
DocPath="$HOME/Documents/Doc"
sudo rsync -a ${DocPath} ${bakPath} >> ${logFile}

# .zshrc .envrc .xprofile .oh-my-zsh
sudo rsync -a "${HOME}/.zshrc" "${HOME}/.envrc" "${HOME}/.xprofile" "${HOME}/.oh-my-zsh" "${bakPath}/zsh" >> ${logFile}


# 结束时间
end=$(date "+%s")
msg=$(date '+%Y-%m-%d %H:%M:%S: 备份结束'",耗时$((end - start))秒")
echo ${msg} >> ${logFile}

# 备份成功
# notify-send -i "${confBakPath}/icon.png" "${msg}"
