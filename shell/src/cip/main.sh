#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# const
readonly CIP_PATH=$(dirname "$(readlink -f "$0")")

readonly WARN_IGNORE_NUM_ARG='忽略后面编号选择参数,同时存在多个 -n -t 参数'
readonly WARN_IGNORE_TYPE_ARG='忽略后面类型选择参数,同时存在多个 -n -t 参数'
readonly ERR_INVALID_NUM='无效编号选择参数,检查 -n 参数'
readonly ERR_INVALID_TYPE='无效类型选择参数,检查 -t 参数'
readonly ERR_INVALID_ARGS='存在无法识别参数,使用 -h 查看帮助'
readonly ERR_CIP_FAIL='获取IP失败'
readonly ERR_INVALID_IPV4='无效IP参数,检查 -i 参数'

readonly CIP_TYPES=(pconline ip-api cip ipapi ipsb)

# var
CIP_IP=""
CIP_Type=""
CIP_Default_Type=${CIP_TYPES[0]}

# shellcheck source=../common/core.sh
. "$CIP_PATH"/../common/core.sh

# shellcheck source=source.sh
. "$CIP_PATH"/source.sh

# usage
# string -> void
usage() {
    echo '使用：'
    echo '  cip [args] [value]'
    echo
    echo '参数：'
    echo '  -h                    显示帮助'
    echo '  -l                    显示列表'
    echo '  -i   [ip]             指定查询IP'
    echo '  -n   [num]            用编号选择源'
    echo '  -t   [type]           用类型名称选择源'
    echo
    echo '注：不使用IP参数显示本机IP'

}

# list
# string -> void
list() {
    echo '查询IP源列表：'

    idx=1
    for cip_type in "${CIP_TYPES[@]}"; do
        echo '  '$idx'    '"$cip_type"
        ((idx++))
    done

    echo
    echo "使用例子： "
    echo '  cip -n1                         # 编号查询本机IP信息'
    echo '  cip -t pconline -i 127.0.0.1    # 类型查询指定IP信息'
}

# main
# string -> void
main() {
    # 参数选项
    while getopts ":hln:t::i::" opt; do
        case "${opt}" in
        h)
            usage
            exit
            ;;
        l)
            list
            exit
            ;;
        n)
            # 编号选择源
            [[ -n $CIP_Type ]] &&
                Warn "$WARN_IGNORE_NUM_ARG" &&
                continue

            ! isNumber "$OPTARG" &&
                [[ $OPTARG -gt ${#CIP_TYPES[@]} ]] &&
                IfErr "$ERR_INVALID_NUM"

            ((OPTARG--))
            CIP_Type=${CIP_TYPES[OPTARG]}
            ;;
        t)
            # 按类型选择短网址
            [[ -n $CIP_Type ]] &&
                Warn "$WARN_IGNORE_TYPE_ARG" &&
                continue

            [[ ! "${CIP_TYPES[*]}" =~ (^|[^0-z\-])"$OPTARG"([^0-z\-]|$) ]] &&
                IfErr "$ERR_INVALID_TYPE"

            CIP_Type=$OPTARG
            ;;
        i)
            # 查询指定IP
            ! isIPv4 "$OPTARG" &&
                IfErr "$ERR_INVALID_IPV4"

            CIP_IP=$OPTARG
            ;;
        ?)
            IfErr "$ERR_INVALID_ARGS"
            ;;
        esac
    done

    # 使用源获取 IP
    [[ -z $CIP_Type ]] &&
        CIP_Type=$CIP_Default_Type

    local func_name=_"${CIP_Type//[.-]/_}"
    ! $func_name "$CIP_IP" &&
        IfErr $ERR_CIP_FAIL
}

main "$@"
