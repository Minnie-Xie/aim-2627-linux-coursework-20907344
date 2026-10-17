#!/bin/bash
# Q5: 运行 launch.env 给定的启动前检查，保存 stdout/stderr、真实退出码和诊断报告。
# 完整接口与验收规格见 Problem.pdf。只修改本文件，不修改测试或工具。
set -eu

input=${1:?需要输入目录}
output=${2:?需要输出目录}

# 1. 读取参数，加载环境变量
source "$input/launch.env"

# 2. 运行教师提供的检查程序，并捕获真实退出码
# 将命令放入 if 结构中，这样即使退出码是 10 或 20，脚本也绝对不会被 set -e 强行杀掉
if bash "$LAUNCH_TOOL" "$MODEL_PATH" "$CAMERA_PATH" > "$output/stdout.log" 2> "$output/stderr.log"; then
    REAL_EXIT_CODE=0
else
    # 只要进入了 else，说明检查程序退出了非 0 状态（比如 10 或 20）
    # $? 此时保存的就是刚才 bash 命令的真实退出码
    REAL_EXIT_CODE=$?
fi

# 3. 写入退出码文件
echo "$REAL_EXIT_CODE" > "$output/exit-code.txt"

# 4. 根据退出码生成诊断报告
if [ "$REAL_EXIT_CODE" -eq 0 ]; then
    RESULT="SUCCESS"
    REASON="NONE"
elif [ "$REAL_EXIT_CODE" -eq 10 ]; then
    RESULT="FAILED"
    REASON="MODEL_MISSING"
elif [ "$REAL_EXIT_CODE" -eq 20 ]; then
    RESULT="FAILED"
    REASON="CAMERA_DENIED"
else
    # 兜底处理，防止出现其他未知退出码
    RESULT="FAILED"
    REASON="NONE"
fi

# 5. 写入报告文件（固定三行）
printf 'result=%s\nexit_code=%s\nreason=%s\n' "$RESULT" "$REAL_EXIT_CODE" "$REASON" > "$output/report.txt"

# 6. 脚本正常退出
exit 0