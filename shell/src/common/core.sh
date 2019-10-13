#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# const
readonly ERR_NOT_FOUND_COMMAND="命令未找到:"

# 输出错误命令
# string -> void
Err() {
    echo -e "\033[31m${1}\033[0m"
}

# 输出警告命令
# string -> void
Warn() {
    echo -e "\033[33m${1}\033[0m"
}

# 输出成功命令
# string -> void
Succ() {
    echo -e "\033[32m${1}\033[0m"
}

# 输出错误命令并退出
# string -> void
IfErr() {
    Err "${1}"
    exit 1
}

# 命令是否存在
# string -> bool
isExistCommand() {
    local not_found_command=""
    for command in ${1//|/$IFS}; do
        ! hash "${command:?}" &&
            not_found_command+=$command
    done

    if [[ -n $not_found_command ]]; then
        echo $ERR_NOT_FOUND_COMMAND"$not_found_command"
        exit 0
    fi
}

# 是否是IPv4地址
# strings -> void[int]
isIPv4() {
    sub="([0-9]{1,2}|[0-1][0-9]{2}|2[0-4][0-9]|25[0-5])"

    if ! grep -E "^($sub.){3}$sub$" <<<"${1:?}" 2>&1 >/dev/null; then
        return 1
    fi
}

# 是否是数字
# strings -> void[int]
isNumber() {
    if grep -E "^[0-9]+$" <<<"${1:?}" 2>&1 >/dev/null; then
        return 1
    fi
}
