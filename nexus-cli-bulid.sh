#!/bin/bash

set -e

echo "🚀 开始安装 Rust + Nexus CLI，并启动节点 ID: $NODE_ID"

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
  echo "目录 nexus-cli 已存在"
  exit 1
fi

# === 克隆 Nexus CLI 项目 ===
echo "📥 克隆 Nexus CLI 源码..."
git clone https://github.com/nexus-xyz/nexus-cli.git
cd nexus-cli/clients/cli

# === 编译 nexus-cli ===
echo "🔨 编译中..."
cargo build --release

echo "✅ 编译成功"
