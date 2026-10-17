#!/bin/bash
# Q7: 读取 input/remote.env，生成 ssh_config，用 _SSH 和 SCP 获取远程数据。
# 完整接口与验收规格见 Problem.pdf。只修改本文件，不修改测试或工具。

set -eu
input=${1:?需要输入目录}
output=${2:?需要输出目录}

# 1. 读取环境变量
source "$input/remote.env"

# 2. 创建接收目录
mkdir -p "$output/received"

# 3. 生成 ssh_config 文件
# 路径可能包含空格，因此 IdentityFile 和 UserKnownHostsFile 的值必须用双引号包裹
# BatchMode yes 确保不会提示输入密码，保证非交互式执行
cat << EOF > "$output/ssh_config"
Host aim-sentry
    HostName $HOST
    Port $PORT
    User $REMOTE_USER
    IdentityFile "$KEY_PATH"
    UserKnownHostsFile "$KNOWN_HOSTS"
    StrictHostKeyChecking yes
    IdentitiesOnly yes
    BatchMode yes
EOF

# 设置 ssh_config 权限为 600（安全要求）
chmod 600 "$output/ssh_config"

# 4. 通过 SSH 执行远程 whoami 命令，并将结果保存到 remote-user.txt
# -F 参数指定使用我们自己生成的配置文件
ssh -F "$output/ssh_config" aim-sentry whoami > "$output/remote-user.txt"

# 5. 使用 SCP 下载远程日志到本地的 received/errors.log
scp -F "$output/ssh_config" "aim-sentry:$REMOTE_LOG" "$output/received/errors.log"

# 脚本正常退出
exit 0
