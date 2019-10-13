#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# const
readonly INSTALL_PATH=$(dirname "$(readlink -f "$0")")
readonly BIN_PATH=$INSTALL_PATH/bin

# 建立软链接
# string -> void
_install_bin() {
    local file_name=${1##*/}
    [[ $file_name != "main.sh" ]] &&
        return

    local dir_name=${1%/*}
    local bin_name=${dir_name##*/}
    local bin_path=$BIN_PATH/$bin_name
    [[ -e $bin_path ]] &&
        rm -rf "$bin_path"

    ln -s "$1" "$bin_path"
}

# 处理文件
# string -> void
_install_file() {
    [[ ! $1 =~ .sh$ ]] &&
        return

    [[ ! -x $1 ]] &&
        chmod +x "$1"

    _install_bin "$path"
}

# 处理目录
# string -> void
_install_dir() {
    for path in "$1"/*; do
        [[ -d $path ]] &&
            _install_dir "$path"

        [[ -f $path ]] &&
            _install_file "$path"
    done
}

_install_dir "$INSTALL_PATH"/src
