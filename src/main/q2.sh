#!/bin/bash
set -eu

# 接收测试程序传来的参数
input="$1"
output="$2"

# 定义主目录路径 (使用 sentry_ws 下划线格式)
main_dir="$output/sentry_ws"

# 1. 创建所有子目录
mkdir -p "$main_dir/scripts"
mkdir -p "$main_dir/config"
mkdir -p "$main_dir/logs"
mkdir -p "$main_dir/tmp"

# 2. 创建两个空文件
touch "$main_dir/logs/.keep"
touch "$main_dir/tmp/scratch.txt"

# 3. 写入启动脚本内容
cat << 'EOF' > "$main_dir/scripts/hello.sh"
#!/bin/bash
echo "Hello, AIM Linux!"
EOF

# 4. 写入配置文件内容
# 【关键修改】将 log level 改为 log_level (下划线)
cat << 'EOF' > "$main_dir/config/robot.conf"
robot=sentry
mode=training
log_level=INFO
EOF