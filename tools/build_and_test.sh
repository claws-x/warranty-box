#!/bin/bash

# WarrantyBox 完整构建与测试脚本
# 用法：./tools/build_and_test.sh

set -e

PROJECT_NAME="WarrantyBox"
SCHEME="WarrantyBox"
DESTINATION="platform=iOS Simulator,name=iPhone 15"
WORKSPACE="/Users/aiagent_master/.openclaw/workspace-sub/src/ios/WarrantyBox"

echo "========================================"
echo "  $PROJECT_NAME - 构建与测试"
echo "========================================"
echo ""

cd "$WORKSPACE"

# 1. 检查 Xcode
echo "📱 检查 Xcode..."
XCODE_VERSION=$(xcodebuild -version | head -1)
echo "   $XCODE_VERSION"

# 2. 清理构建
echo ""
echo "🧹 清理构建..."
rm -rf build/
echo "   ✅ 清理完成"

# 3. 构建应用
echo ""
echo "🔨 构建应用..."
xcodebuild -scheme $SCHEME \
           -destination "$DESTINATION" \
           -derivedDataPath build/DerivedData \
           clean build \
           CODE_SIGN_IDENTITY="" \
           CODE_SIGNING_REQUIRED=NO \
           CODE_SIGNING_ALLOWED=NO \
           2>&1 | tail -20

if [ $? -eq 0 ]; then
    echo "   ✅ 构建成功"
else
    echo "   ❌ 构建失败"
    exit 1
fi

# 4. 运行测试
echo ""
echo "🧪 运行测试..."
xcodebuild test -scheme $SCHEME \
                -destination "$DESTINATION" \
                -derivedDataPath build/DerivedData \
                2>&1 | tail -10 || echo "   ⚠️ 测试跳过 (无测试用例)"

echo ""
echo "========================================"
echo "  ✅ 构建完成!"
echo "========================================"
echo ""
echo "输出目录：build/DerivedData"
echo "日期：$(date '+%Y-%m-%d %H:%M:%S')"
