#!/bin/bash

set -e

NODE_ID="$1"

if [ -z "$NODE_ID" ]; then
  echo "❌ 请提供 Node ID："
  echo "用法示例： ./install_nexus.sh 13243602"
  exit 1
fi

echo "🚀 开始安装 Rust + Nexus CLI，并启动节点 ID: $NODE_ID"

# === 可选：配置代理（按需取消注释）===
# export https_proxy=http://127.0.0.1:7897
# export http_proxy=http://127.0.0.1:7897

# === 安装 Rust 工具链（如果未安装）===
if ! command -v cargo >/dev/null 2>&1; then
  echo "📦 正在安装 Rust..."
  export RUSTUP_DIST_SERVER=https://rsproxy.cn
  export RUSTUP_UPDATE_ROOT=https://rsproxy.cn/rustup
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
else
  echo "✅ Rust 已安装: $(rustc --version)"
fi

# === 设置 rust 默认版本，防止工具链未配置错误 ===
rustup default stable

# === 设置 Cargo 镜像为 USTC ===
echo "🌐 配置 Cargo 镜像源为 USTC..."
mkdir -p ~/.cargo
cat > ~/.cargo/config.toml <<EOF
[source.crates-io]
replace-with = "ustc"

[source.ustc]
registry = "https://mirrors.ustc.edu.cn/crates.io-index"
EOF

# === 目录存在时先删除，避免 clone 失败 ===
if [ -d "nexus-cli" ]; then
  echo "目录 nexus-cli 已存在，删除旧目录..."
  rm -rf nexus-cli
fi

# === 克隆 Nexus CLI 项目 ===
echo "📥 克隆 Nexus CLI 源码..."
git clone https://github.com/nexus-xyz/nexus-cli.git
cd nexus-cli/clients/cli

# === 编译 nexus-cli ===
echo "🔨 编译中..."
cargo build --release

# === 安装到 ~/.nexus/bin 并配置 PATH ===
# echo "🗂️ 拷贝执行文件到 ~/.nexus/bin..."
# mkdir -p ~/.nexus/bin
# cp ./target/release/nexus-cli ~/.nexus/bin/
# cp ./target/release/nexus-network ~/.nexus/bin/

# if ! grep -q 'export PATH="$HOME/.nexus/bin:$PATH"' ~/.zshrc; then
#   echo 'export PATH="$HOME/.nexus/bin:$PATH"' >> ~/.zshrc
# fi
# source ~/.zshrc
cd target/release

# === 启动 Nexus 节点 ===
echo ""
echo "🚀 启动 Nexus 节点（ID: $NODE_ID）..."
./nexus-network start --node-id "$NODE_ID"
