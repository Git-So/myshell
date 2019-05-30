#!/usr/bin/env bash
# 功能函数
set -eo pipefail

# 模块
# if [[ -n ${MYSHELL_MYIP_MOD_FUNC} ]] ;then
#     return 0
# else
#     export MYSHELL_MYIP_MOD_FUNC="true"
# fi

# 配置文件
export MYSHELL_MYIP_CONF_PATH="${MYSHELL_MYIP_PATH}/conf.json"
export MYSHELL_MYIP_CONF=$(cat ${MYSHELL_MYIP_PATH}/conf.json)

# 清理垃圾文件
# rm "${MYSHELL_MYIP_CONF_PATH}.*.tmp"

# IsKey 是否为一个合格的键值
# 参数 $1 判断值
# 成功返回 1,否则为 0
IsKey() {
    if [[ $(echo $1 | grep -w -c "^[0-9]\+$") -gt 0 ]] ;then
        echo 1
    else
        echo 0
    fi
}

# GetConf 获取指定键值配置
# 参数 $1 键值
# 成功返回 json 配置,失败返回 空
GetConf() {
    # 无效键值获取默认配置,合法键值对应配置
    if [[ $(IsKey $1) -eq 1 ]] ;then
        # 配置长度
        local len=$(echo ${MYSHELL_MYIP_CONF} | jq "length")

        # 配置内容存在显示
        if [[ -n "${len}" && "$1" -lt "${len}" ]]
        then
            echo ${MYSHELL_MYIP_CONF} | jq ".[$1]"
        else
            echo ""
        fi
    else
        # 显示默认配置
        echo ${MYSHELL_MYIP_CONF} | jq "map( select( . | .default=true ) ) | .[0]"
    fi
}

# GetIP 获取IP信息
# 参数 $1 配置 json
# 参数 $2 IP, 不设置为 本地IP
GetIP() {
    if [[ -n "$1" ]] ;then

        # 配置
        local conf="$1"
        local data=""
        local timeout=5

        # 获取配置
        if [[ -n "$2" ]] ;then
            # 获取本地IP
            conf=$(echo $conf | jq -r ".custom")
            data=$(echo $conf | jq -r ".data")
            data=$(echo $data | sed s/\${IP}/$2/g)
        else
            # 获取自定义IP数据
            conf=$(echo $conf | jq -r ".current")
            data=$(echo $conf | jq -r ".data")
            data=$(echo $data | sed s/\${IP}/$2/g)
        fi

        # 方法
        local method=$(echo $conf | jq -r ".method")
        local dataType=$(echo $conf | jq -r ".dataType")
        local coding=$(echo $conf | jq -r ".coding")
        local url=$(echo $conf | jq -r ".url")
        local url=$(echo $url | sed s/\${GET}/$data/g)

        # data
        local response=""
        if [[ "${method}" == "POST" ]] ;then
            response=$(curl -s –connect-timeout $timeout -m $timeout -d "${data}" "${url}" )
        else
            data=$(echo $data | sed s/\&/\\\\\\\\\&/g)
            url=$(echo $url | sed s/\${GET}/$data/g)
            response=$(curl -s –connect-timeout $timeout -m $timeout "${url}" )
        fi

        # coding
        if [[ "${coding}" != "utf8" ]] ;then
             response=$(echo "${response}" | iconv -f $coding -t utf8 )
        fi

        # dataType
        if [[ "${dataType}" == "json" ]] ;then
            echo "${response}" | jq
        else
            echo "${response}"
        fi

    else
        echo "配置错误"
        exit 1
    fi
}

# showIP 显示IP消息
showIP() {
    # 参数效验
    if [[ $# -gt 1 ]] ;then
        showHelp $#
        exit 1
    fi

    GetIP "$(GetConf)" $1
    return
}

# showList 显示源列表
showList() {
    # 参数效验
    if [[ $# -ne 1 ]] ;then
        showHelp $#
        exit 1
    fi

    # 显示列表
    echo $MYSHELL_MYIP_CONF \
        | jq -r  ".[].name,.[].default,.[].speed" \
        | awk '{ \
                nums[NR]=$1; \
            }END{ \
                printf("%s %s %s %s\n","------","------","------","------"); \
                printf("%s %s %s %s\n","ID","源名称","是否默认","速度"); \
                printf("%s %s %s %s\n","------","------","------","------"); \
                for(i=0; i<NR/3; i++){ \
                    # 速度
                    speed = nums[NR/3*2+i+1]
                    # 是否默认
                    if ( nums[NR/3+i+1] == "true" ) {
                        isDefault = "是"
                    } else {
                        isDefault = "否"
                    }

                    printf("%d %s %s %s毫秒\n",i,nums[i+1],isDefault,speed) \
                } \
            }' \
        | column  -t
    return
}

# runTest 运行源测试
runTest() {
     if [[ $# -eq 1 ]] ;then
        # 获取配置长度
        local len=$(echo $MYSHELL_MYIP_CONF | jq 'length')

        # 时间测试
        touch "${MYSHELL_MYIP_CONF_PATH}.${MYSHELL_MYIP_ID}.tmp"
        while [[ "$len" -gt 0 ]] ;do
            # 键值
            len=$(($len - 1))

            # 测试
            local name=$(echo $MYSHELL_MYIP_CONF | jq -r ".[${len}].name")
            echo "${name} :"

            # 测试源
            local start=$(echo $[$(date +%s%N)/1000000])
            local result=$($MYSHELL_MYIP_PATH/main.sh -n "$len")
            local end=$(echo $[$(date +%s%N)/1000000])

            # 保存响应时间
            local count=$(($end - $start))
            echo "      耗时 ${count} 毫秒"
            echo $MYSHELL_MYIP_CONF | jq ".[${len}].speed = ${count}" > "${MYSHELL_MYIP_CONF_PATH}.${MYSHELL_MYIP_ID}.tmp"
            cat "${MYSHELL_MYIP_CONF_PATH}.${MYSHELL_MYIP_ID}.tmp" | jq ". | sort_by(.speed)" > $MYSHELL_MYIP_CONF_PATH
        done
            rm "${MYSHELL_MYIP_CONF_PATH}.${MYSHELL_MYIP_ID}.tmp"

    else
        showHelp $#
        exit 1
    fi

    # 提示
    # echo ""
    # echo "IP源测试完成"

    return
}

# setDefault 设置默认源
setDefault() {
    if [[ $# -eq 2 && $(IsKey "$2") -eq 1 ]] ;then
        # 获取配置长度
        local len=$(echo $MYSHELL_MYIP_CONF | jq 'length')
        # 超出有效key
        if [ "$2" -ge "$len" ] ;then
            echo "键值错误"
            exit 1
        fi
        # 设置处理
        echo $MYSHELL_MYIP_CONF | jq ".[].default = false" > "${MYSHELL_MYIP_CONF_PATH}.${MYSHELL_MYIP_ID}.tmp"
        cat "${MYSHELL_MYIP_CONF_PATH}.${MYSHELL_MYIP_ID}.tmp" | jq ".[$2].default = true" > $MYSHELL_MYIP_CONF_PATH
        rm "${MYSHELL_MYIP_CONF_PATH}.${MYSHELL_MYIP_ID}.tmp"
    else
        showHelp $#
        exit 1
    fi

    # 提示
    local name=$(echo $MYSHELL_MYIP_CONF | jq -r ".[$2].name")
    echo "［${name}］已设置为默认值"

    return
}

# runNumber 指定源显示IP信息
runNumber() {
    GetIP "$(GetConf $2)" $3
    return
}

# showHelp 显示帮助信息
showHelp() {
    echo "使用:"
    echo "    [ip?]                           查看当前IP[指定IP]信息"
    echo ""
    echo "命令:"
    echo "    list, -l                        源列表"
    echo "    number, -n    [key]   [ip?]     使用指定源查看IP信息"
    echo "    test, -t                        测试源速度"
    echo "    default, -d   [key]             设置默认源"
    echo "    help, -h                        帮助"
    return
}
