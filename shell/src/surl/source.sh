#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# const
readonly SURL_SOURCE_PATH=$(dirname "$(readlink -f "$0")")
readonly TEMP_FILE=$SURL_SOURCE_PATH/.temp
readonly TIMEOUT=8

isExistCommand "curl|jq|sed|grep"

# 新浪短网址
# string -> void
_t_cn() {
    local url="https://www.toolnb.com/Tools/Api/duanwangzhi.html"
    local data="url=${1:?}&type=xl"
    ! curl -s -m "$TIMEOUT" -d "$data" "$url" >"$TEMP_FILE" &&
        return 1

    [ -s "$TEMP_FILE" ] &&
        jq -r ".data.url" <"$TEMP_FILE"
}

# t.im 短网址
# string -> void
_t_im() {
    local url="https://t.im/"
    ! curl -s -m "$TIMEOUT" --data-urlencode "url=${1:?}" "$url" >"$TEMP_FILE" &&
        return 1

    [ -s "$TEMP_FILE" ] &&
        grep -E "https?://t.im" "$TEMP_FILE" |
        sed -E "s/(<[^>]*>| )//g"
}

# t.tl 短网址
# string -> void
_t_tl() {
    local url="https://t.tl/"
    ! curl -s -m "$TIMEOUT" --data-urlencode "url=${1:?}" "{$url}" >"$TEMP_FILE" &&
        return 1

    [ -s "$TEMP_FILE" ] &&
        grep -E "https?://t.tl" "$TEMP_FILE" |
        sed -E "s/(<[^>]*>| )//g"
}

# 腾讯短网址
# string -> void
_url_cn() {
    local url="https://tool.chinaz.com/tools/dwz.aspx"
    ! curl -s -m "$TIMEOUT" -d "longurl=${1:?}" "{$url}" >"$TEMP_FILE" &&
        return 1

    [ -s "$TEMP_FILE" ] &&
        grep -E "https?://url.cn" "$TEMP_FILE" |
        sed -E "s/(<[^>]*>| )//g" | sed -E "s/^.*(https?:)/\1/"
}

# 缩我短网址
# string -> void
_suo_im() {
    local url="https://www.toolnb.com/Tools/Api/duanwangzhi.html"
    ! curl -s -m "$TIMEOUT" -d "url=${1:?}&type=suo" "{$url}" >"$TEMP_FILE" &&
        return 1

    [ -s "$TEMP_FILE" ] &&
        jq -r ".data.url" >"$TEMP_FILE"
}

# dwz.mn 短网址
# string -> void
_dwz_mn() {
    local url="https://dwz.mn/create.aspx?https=1"
    ! curl -s -m "$TIMEOUT" --data-urlencode "url=${1:?}" "{$url}" >"$TEMP_FILE" &&
        return 1

    [ -s "$TEMP_FILE" ] &&
        jq -r ".tinyurl" <"$TEMP_FILE"
}
