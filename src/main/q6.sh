#!/bin/bash
# Q6: 将本地 Debian 包安装到 output/sysroot，运行安装后的工具。
# 完整接口与验收规格见 Problem.pdf。只修改本文件，不修改测试或工具。
set -eu
input=${1:?需要输入目录}
output=${2:?需要输出目录}

# 1. 创建 sysroot 目录（如果不存在）
mkdir -p "$output/sysroot"

# 2. 定义包路径
DEB_PACKAGE="$input/aim-sentry-tools.deb"

# 3. 使用 dpkg 安装到 sysroot
# --root 指定安装根目录
# --force-not-root 允许非 root 用户安装
# --log=/dev/null 关闭日志（可选，但按题目建议）
dpkg -i --root="$output/sysroot" --force-not-root --log=/dev/null "$DEB_PACKAGE"

# 4. 运行安装后的工具，保存 stdout 到 tool-output.txt
"$output/sysroot/usr/bin/aim-sentry-info" > "$output/tool-output.txt"