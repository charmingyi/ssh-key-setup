#!/bin/bash

# 确保脚本以 root 身份运行
if [ "$(id -u)" != "0" ]; then
   echo "此脚本必须以 root 身份运行" 1>&2
   exit 1
fi

# 更新包列表并安装 OpenSSH 服务器（如果尚未安装）
apt update
apt install -y openssh-server

# 确保 .ssh 目录存在并设置正确权限
USER_HOME=$(eval echo ~${SUDO_USER})
SSH_DIR="${USER_HOME}/.ssh"
mkdir -p "${SSH_DIR}"
chown "${SUDO_USER}:${SUDO_USER}" "${SSH_DIR}"
chmod 700 "${SSH_DIR}"

# 预定义的公钥
PUB_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCYPLRKZds08tsvT70ahCRa5oX5WWG+saJvoLz4wmR4Jcz+wb7AnGp5KXNFLVEOE804rAueZH3/wjPe00fhL7HCRd1D27Kh/Z3ekPrzCrgNhg2eeROfxsBLskJ00DJhsougpe0krr/847+srxeOUx//GP0WmKDiEv69mQn/cZeV0umFA5adI9+4R3BuvxxciKiBIsgpZ7dx1sBQYaZloseP0/nA1LlmfkDgnwaWRncRupGPD9Fre1L50IXEpPseG/LxGcfUOFlYFdIQUZVU3QDnp9CiS09dee6GMLdpVyVXH6a5CLL2FyJnM/UgdwWCiyQ1WnJ61UI3BOn1N5Kxe6gbcbF3ZuSnIMn8B2TwnjZAllYage79V8AZ25lXLm4FiYzz7MhLiXxtV7t9FEFNqgAJLUy7PBOMpbFlAjOYKW6pD9y8XExnTZhBhuhSxq4GpMEzBXZcGpjGM32L3Z3dnoTjx8j8fWZIoY/3DOZRUnsAfg2vQKQzZms8cfTJdC+0Uj8= root@yxvm"

# 创建或追加公钥到 authorized_keys 文件
echo "${PUB_KEY}" >> "${SSH_DIR}/authorized_keys"
chown "${SUDO_USER}:${SUDO_USER}" "${SSH_DIR}/authorized_keys"
chmod 600 "${SSH_DIR}/authorized_keys"

# 修改 SSH 配置文件以禁用密码验证并启用密钥验证
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# 重启 SSH 服务使配置生效
systemctl restart ssh

echo "SSH 密钥登录已启用。"
