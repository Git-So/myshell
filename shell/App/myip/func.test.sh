#!/usr/bin/env bash
# 功能函数测试
set -eo pipefail

# 脚本路径
export MYSHELL_MYIP_PATH="$MYSHELL/shell/App/myip"

# 加载调试文件
. ${MYSHELL_MYIP_PATH}/func.sh

# IsKey 测试
testIsKey() {
    assertEquals  $(IsKey 123)   1
    assertEquals  $(IsKey 1)     1
    assertEquals  $(IsKey 123a)  0
    assertEquals  $(IsKey -123)  0
}

# GetConf 测试
testGetConf() {
    assertEquals  $(GetConf 0 | jq -r ".name")       "淘宝"
    assertEquals  $(GetConf 1 | jq -r ".name")       "360"
    assertEquals  $(GetConf -1 | jq -r ".name")      "淘宝"
    assertEquals  $(GetConf 232)""                   ""
    assertEquals  $(GetConf 123a | jq -r ".name")    "淘宝"
}

# 引入调试环境
. ${APP_SHUNIT2_PATH}/shunit2
