#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# const
readonly SURL_PATH=$(dirname "$(readlink -f "$0")")

readonly WARN_IGNORE_ID_ARG='忽略后面ID选择参数,同时存在多个 -n -t 参数'
readonly WARN_IGNORE_TYPE_ARG='忽略后面类型选择参数,同时存在多个 -n -t 参数'
readonly ERR_INVALID_ID='无效编号选择参数,检查 -n 参数'
readonly ERR_INVALID_TYPE='无效类型选择参数,检查 -t 参数'
readonly ERR_INVALID_ARGS='存在无法识别参数,使用 -h 查看帮助'
readonly ERR_SURL_FAIL='缩短网址失败'
readonly ERR_INVALID_URL='无效长网址参数,检查 -u 参数'

readonly SURL_TYPES=(t.cn t.im t.tl url.cn suo.im dwz.mn)

# var
SURL_Long_URL=""
SURL_Type=""
SURL_Default_Type=${SURL_TYPES[0]}

# shellcheck source=../common/core.sh
. "$SURL_PATH"/../common/core.sh

# shellcheck source=source.sh
. "$SURL_PATH"/source.sh

# usage
# string -> void
usage() {
    echo '使用：'
    echo '  surl [args] [value]'
    echo
    echo '参数：'
    echo '  -h                    显示帮助'
    echo '  -l                    显示列表'
    echo '  -u   [url]            长网址'
    echo '  -n   [id]             用ID选择源'
    echo '  -t   [type]           用类型名称选择源'
    echo

}

# list
# string -> void
list() {
    echo '短网址源列表：'

    idx=1
    for surl_type in "${SURL_TYPES[@]}"; do
        echo '  '$idx'    '"$surl_type"
        ((idx++))
    done

    echo
    echo "使用例子： "
    echo '  surl -u http://baidu.com            # 转换为默认类型短网址'
    echo '  surl -n1     -u http://baidu.com    # 转换为t.cn类型短网址'
    echo '  surl -t t.cn -u http://baidu.com    # 转换为t.cn类型短网址'
}

# main
# string -> void
main() {
    # 参数选项
    while getopts ":hln:t::u::" opt; do
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
            # ID 选择源
            [[ -n $SURL_Type ]] &&
                Warn "$WARN_IGNORE_ID_ARG" &&
                continue

            ! isNumber "$OPTARG" &&
                [[ $OPTARG -gt ${#SURL_TYPES[@]} ]] &&
                IfErr "$ERR_INVALID_ID"

            ((OPTARG--))
            SURL_Type=${SURL_TYPES[OPTARG]}
            ;;
        t)
            # 按类型选择短网址
            [[ -n $SURL_Type ]] &&
                Warn "$WARN_IGNORE_TYPE_ARG" &&
                continue

            [[ ! "${SURL_TYPES[*]}" =~ (^|[^0-z\-])"$OPTARG"([^0-z\-]|$) ]] &&
                IfErr "$ERR_INVALID_TYPE"

            SURL_Type=$OPTARG
            ;;
        u)
            # 长网址
            [[ ! $OPTARG =~ ^https?://.+\..+$ ]] &&
                IfErr "$ERR_INVALID_URL"

            SURL_Long_URL=$OPTARG
            ;;
        ?)
            IfErr "$ERR_INVALID_ARGS"
            ;;
        esac
    done

    [[ -z $SURL_Long_URL ]] &&
        IfErr "$ERR_INVALID_URL"

    # 使用源获取 IP
    [[ -z $SURL_Type ]] &&
        SURL_Type=$SURL_Default_Type

    local func_name=_"${SURL_Type//[.-]/_}"
    ! $func_name "$SURL_Long_URL" &&
        IfErr $ERR_SURL_FAIL
}

main "$@"
