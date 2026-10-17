#!/bin/bash
set -eu

# 接收测试程序传来的参数
input="$1"
output="$2"

# 创建输出目录
mkdir -p "$output"

# Q1 核心逻辑
# 1. 进入 handover 目录
cd "$input/handover"
pwd -P > "$output/location.txt"

# 2. 读取隐藏文件
cat .robot-id > "$output/robot-id.txt"

# 3. 读取欢迎文本 (使用绝对路径，防止 cd 失败后找不到文件)
cat "$input/notes/welcome.txt" > "$output/welcome.txt"