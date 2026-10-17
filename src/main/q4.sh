#!/bin/bash
# Q4: 合并日志，按级别提取，保存首尾片段并统计错误行数。
set -eu
input=${1:?需要输入目录}
output=${2:?需要输出目录}

# 1. 合并日志：按 boot, run 顺序完整拼接为 all.log
cat "$input/boot.log" "$input/run.log" > "$output/all.log"

# 2. 提取错误日志：保留级别为 ERROR 的完整行
grep '^ERROR' "$output/all.log" > "$output/errors.log" || true

# 3. 提取告警和错误日志：保留级别为 WARN 或 ERROR 的完整行
grep -E '^(WARN|ERROR)' "$output/all.log" > "$output/attention.log" || true

# 4. 保存末尾 5 行：若不足 5 行则取全部
tail -n 5 "$output/all.log" > "$output/recent.log"

# 5. 保存错误的前 3 行：若不足 3 行则取全部
head -n 3 "$output/errors.log" > "$output/first-errors.log"

# 6. 统计错误行数并输出到 error-count.txt
# 使用 grep -c 统计匹配行数，因为前面加了 || true，即使为 0 也能正常继续执行
grep -c '^ERROR' "$output/all.log" > "$output/error-count.txt" || echo "0" > "$output/error-count.txt"