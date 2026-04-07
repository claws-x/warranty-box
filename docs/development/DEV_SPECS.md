# WarrantyBox - iOS 应用开发规范

**版本**: v1.0  
**日期**: 2026-04-01  
**遵循标准**: Apple Human Interface Guidelines

---

## 📐 设计规范

### 界面规范
- ✅ SwiftUI (iOS 17+)
- ✅ SF Symbols 5.0
- ✅ 动态字体 (Dynamic Type)
- ✅ 深色模式支持
- ✅ 横屏适配 (iPad)

### 颜色系统
```swift
// 主色调
.primary: Color.blue
.secondary: Color.gray

// 语义色
.success: Color.green
.warning: Color.orange
.error: Color.red
.expired: Color.gray
```

### 字体规范
```swift
// 使用系统字体
.title: .title
.headline: .headline
.body: .body
.caption: .caption
```

---

## 🏗️ 架构规范

### MVVM 架构
```
WarrantyBox/
├── Models/          # 数据模型
├── Views/           # SwiftUI 视图
├── ViewModels/      # 视图模型
├── Managers/        # 管理器
└── Utilities/       # 工具类
```

### CoreData 栈
```swift
// 持久化容器
- WarrantyItem (主实体)
- Category (分类实体)
```

---

## 📱 功能实现清单

### Phase 1: 基础架构 (Day 1)
- [x] 项目结构
- [x] CoreData 模型
- [ ] 导航架构

### Phase 2: 核心功能 (Day 2-3)
- [ ] 首页列表
- [ ] 添加凭证
- [ ] 凭证详情
- [ ] 分类管理

### Phase 3: 高级功能 (Day 4)
- [ ] 搜索功能
- [ ] 到期提醒
- [ ] 数据导出

### Phase 4: 测试发布 (Day 5-6)
- [ ] 单元测试
- [ ] UI 测试
- [ ] TestFlight

---

## ✅ App Store 审核要点

### 必须满足
- [ ] 隐私政策 URL
- [ ] 用户协议 URL
- [ ] 应用截图 (6.7", 6.5", 5.5")
- [ ] 应用图标 (1024x1024)
- [ ] 支持 URL

### 数据隐私
- [ ] 声明不收集用户数据
- [ ] 声明无第三方追踪
- [ ] 声明无广告

### 功能要求
- [ ] 应用能正常启动
- [ ] 所有按钮有响应
- [ ] 无崩溃
- [ ] 无占位内容

---

## 🚀 自动化脚本

### 构建脚本
```bash
#!/bin/bash
xcodebuild -scheme WarrantyBox \
           -destination 'platform=iOS Simulator,name=iPhone 15' \
           clean build
```

### 测试脚本
```bash
#!/bin/bash
xcodebuild test -scheme WarrantyBox \
                -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

**开发中... 严格执行苹果规范**
