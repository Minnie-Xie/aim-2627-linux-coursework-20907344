#!/bin/bash
# Q3: 复制素材、备份配置、移动草稿、删除 tmp、设定权限并直接运行 hello.sh。
# 完整接口与验收规格见 Problem.pdf。只修改本文件，不修改测试或工具。
set -eu
input=${1:?需要输入目录}
output=${2:?需要输出目录}

# 定义工作区路径
WORK_DIR="$output/sentry_ws"
SCRIPTS_DIR="$WORK_DIR/scripts"
CONFIG_DIR="$WORK_DIR/config"
BACKUP_DIR="$WORK_DIR/backup"
ARCHIVE_DIR="$WORK_DIR/archive"

# 1. 创建目录结构
mkdir -p "$SCRIPTS_DIR" "$CONFIG_DIR" "$BACKUP_DIR" "$ARCHIVE_DIR"

# 2. 复制素材
cp "$input/hello.sh" "$SCRIPTS_DIR/"
cp "$input/robot.conf" "$CONFIG_DIR/"
cp "$input/draft.conf" "$CONFIG_DIR/"

# 3. 备份 robot.conf
cp "$CONFIG_DIR/robot.conf" "$BACKUP_DIR/robot.conf"

# 4. 移动 draft.conf 到 archive 并重命名
mv "$CONFIG_DIR/draft.conf" "$ARCHIVE_DIR/draft.conf.old"

# 5. 删除 tmp 目录（包括可能存在的 cache.txt）
rm -rf "$WORK_DIR/tmp"

# 6. 设置权限
chmod 750 "$SCRIPTS_DIR/hello.sh"
chmod 640 "$CONFIG_DIR/robot.conf"

# 7. 执行 hello.sh 并保存输出到 output 根目录的 hello-output.txt
"$SCRIPTS_DIR/hello.sh" > "$output/hello-output.txt"