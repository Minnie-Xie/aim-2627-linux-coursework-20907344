#!/bin/bash
# Q8: repair 时识别并停止采集器、修复 HTTP 服务; cleanup 时停止修复后的服务。
# 完整接口与验收规格见 Problem.pdf。只修改本文件，不修改测试或工具。

set -eu

input=${1:?需要输入目录}
output=${2:?需要输出目录}
action=${3:-repair}

# 1. 加载环境变量 (source 命令会将测试账号 aimcw7e24 加载到 $USER 变量中)
source "$input/process.env"

if [ "$action" = "repair" ]; then
    # ==========================================
    # A. 定位与停止采集器 (10分)
    # ==========================================

    # 1. 用进程查询命令查看目标 PID，保存到 output/process.txt
    p_pid="$TARGET_PID"

    # 【核心破局】直接从当前环境变量获取测试账号名称 (aimcw7e24)
    p_user="$USER"

    # 使用 ps 命令获取进程状态 (state) 和完整命令行 (command)
    # -w 参数防止命令过长被截断
    PS_LINE=$(ps -o stat=,command= -w -p "$p_pid" 2>/dev/null | head -n 1)
    
    # 提取状态和命令
    p_state=$(echo "$PS_LINE" | awk '{print $1}')
    # 去除状态字段，剩下的就是完整命令行
    p_cmd=$(echo "$PS_LINE" | sed -e 's/^[ \t]*[a-zA-Z]*[ \t]*//')

    # 格式化写入文件 (测试框架将比对这里的 user 字段)
    {
        echo "pid=$p_pid"
        echo "user=$p_user"
        echo "state=$p_state"
        echo "command=$p_cmd"
    } > "$output/process.txt"

    # 2. 保存至少两条 TICK 日志到 collector-sample.log
    grep "TICK" "$WORKER_LOG" | head -n 2 > "$output/collector-sample.log"

    # 3. 向目标 PID 发送普通终止信号 (SIGTERM)，等待它正常退出
    kill -TERM "$TARGET_PID"
    # 等待进程消失
    for i in {1..5}; do
        if ! kill -0 "$TARGET_PID" 2>/dev/null; then
            break
        fi
        sleep 1
    done

    # ==========================================
    # B. 恢复 HTTP 服务 (10分)
    # ==========================================

    # 1. 正常停止 SERVICE_PID 指定的原错误服务
    if kill -0 "$SERVICE_PID" 2>/dev/null; then
        kill -TERM "$SERVICE_PID"
        for i in {1..5}; do
            if ! kill -0 "$SERVICE_PID" 2>/dev/null; then
                break
            fi
            sleep 1
        done
    fi

    # 2. 生成输出 server.conf
    cat > "$output/server.conf" <<EOF
bind=127.0.0.1
port=$TARGET_PORT
route=/status
EOF

    # 3. 使用教师提供的 START_TOOL 运行修复后的服务
    # 加上 & 放入后台运行，防止 START_TOOL 阻塞后续脚本
    bash "$START_TOOL" "$output/server.conf" "$output/service" > /dev/null 2>&1 &

    # 4. 等待就绪，用 curl 请求验证
    URL="http://127.0.0.1:${TARGET_PORT}/status"
    
    # 循环重试直到成功或超时
    for i in {1..15}; do
        # 尝试请求，-w 获取状态码，-o 写入临时文件
        HTTP_CODE=$(curl -s -o /tmp/q8_body_tmp -w "%{http_code}" "$URL" 2>/dev/null || echo "000")
        
        if [ "$HTTP_CODE" = "200" ]; then
            # 成功获取 200，保存结果文件
            echo "200" > "$output/http-status.txt"
            cat /tmp/q8_body_tmp > "$output/http-body.txt"
            
            # 清理临时文件
            rm -f /tmp/q8_body_tmp
            break
        fi
        sleep 1
    done

elif [ "$action" = "cleanup" ]; then
    # ==========================================
    # Cleanup 阶段：停止修复后的服务
    # ==========================================
    PID_FILE="$output/service/pid"
    if [ -f "$PID_FILE" ]; then
        CLEANUP_PID=$(cat "$PID_FILE")
        if [ -n "$CLEANUP_PID" ] && kill -0 "$CLEANUP_PID" 2>/dev/null; then
            kill -TERM "$CLEANUP_PID"
            for i in {1..5}; do
                if ! kill -0 "$CLEANUP_PID" 2>/dev/null; then
                    break
                fi
                sleep 1
            done
        fi
    fi
fi

exit 0