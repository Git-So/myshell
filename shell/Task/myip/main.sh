#!/usr/bin/env bash
# myip 查看当前IP 或 其他IP信息
#
set -eo pipefail

# 构造函数
start() {
    # 脚本路径
    export MYSHELL_MYIP_PATH="$(dirname $(readlink -f $0))"

    # 操作ID
    export MYSHELL_MYIP_ID=$(echo $[$(date +%s%N)/1000000])

    # 引入函数
    . "${MYSHELL_MYIP_PATH}/func.sh"

    return
}

# 主函数
main() {
    # 参数
    command=$1

    # 命令
    case "${command}" in
        list|-l)
            showList $@
            ;;
        test|-t)
            runTest $@
            ;;
        help|-h)
            showHelp $@
            ;;
        default|-d)
            setDefault $@
            ;;
        number|-n)
            runNumber $@
            ;;
        *)
            showIP $@
            exit 1
            ;;
    esac

    return
}

# 虚构函数
end() {
    unset MYSHELL_MYIP_PATH
    return
}

# ...
start
main $@
end
