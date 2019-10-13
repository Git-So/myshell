#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# const
readonly CIP_SOURCE_PATH=$(dirname "$(readlink -f "$0")")
readonly TEMP_FILE=$CIP_SOURCE_PATH/.temp

isExistCommand "curl|iconv|jq"

# HTTP GET
# string -> void[int]
_http_get() {
    if ! curl -s -m 8 "${1?}" >"$TEMP_FILE"; then
        return 1
    fi
}

# 太平洋 IP 源
# void -> void
_pconline() {
    local url="https://whois.pconline.com.cn/ipJson.jsp?json=true&ip=${1:-}"
    ! _http_get "$url" && return 1

    [ -s "$TEMP_FILE" ] &&
        iconv -f gbk -t utf8 "$TEMP_FILE" | jq &&
        exit
}

# IPAPI 源
# void -> void
_ipapi() {
    local url="https://ipapi.co/${1:-}/json/"
    ! _http_get "$url" && return 1

    [ -s "$TEMP_FILE" ] &&
        jq <"$TEMP_FILE" &&
        exit
}

# IP-API 源
# void -> void
_ip_api() {
    local url="https://ipapi.co/${1:-}/json/"
    ! _http_get "$url" && return 1

    [ -s "$TEMP_FILE" ] &&
        jq <"$TEMP_FILE" &&
        exit
}

# IPSB 源
# void -> void
_ipsb() {
    local url="https://ipapi.co/${1:-}/json/"
    ! _http_get "$url" && return 1

    [ -s "$TEMP_FILE" ] &&
        jq <"$TEMP_FILE" &&
        exit
}

# CIP 源
# void -> void
_cip() {
    local url="cip.cc/"${1:-}
    if ! _http_get "$url"; then
        return 1
    fi

    [ -s "$TEMP_FILE" ] &&
        cat "$TEMP_FILE" &&
        exit
}
