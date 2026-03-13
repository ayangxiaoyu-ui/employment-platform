# 学生个人资料页面组件拆分说明

## 📁 组件结构

```
src/
├── views/student/
│   └── ProfileView.vue           # 主容器组件（父组件）
└── components/StudentProfile/
    ├── ProfileSidebar.vue        # 侧边栏组件
    ├── ProfileInfo.vue           # 个人信息编辑组件
    ├── ResumeManagement.vue      # 简历管理组件
    ├── DeliveryStatus.vue        # 投递动态组件
    ├── FavoriteList.vue          # 我的收藏组件
    └── MessageCenter.vue         # 消息中心组件
```

## 📝 各组件说明

### ProfileView.vue（主容器）
职责：
- 管理全局状态（activeTab、form、loading 等）
- 加载学生个人资料
- 协调子组件之间的数据通信
- 路由导航

主要数据：
- `activeTab` - 当前激活的TAB
- `form` - 学生个人信息
- `studentId` - 学生ID
- `avatarPreview` - 头像预览URL
- `usernameFromToken` - 从token中提取的用户名

### ProfileSidebar.vue（侧边栏）
职责：
- 显示用户头像和昵称
- 展示导航菜单
- 返回主页按钮

Props：
- `activeTab` - 当前激活的TAB
- `form` - 学生个人信息
- `avatarPreview` - 头像预览
- `usernameFromToken` - 用户名

Events：
- `update:active-tab` - TAB切换事件
- `go-home` - 返回主页事件

### ProfileInfo.vue（个人信息）
职责：
- 显示和编辑个人基本信息
- 头像上传和预览
- 个人资料表单管理

Props：
- `form` - 学生个人信息
- `avatarPreview` - 头像预览
- `usernameFromToken` - 用户名
- `loading` - 加载状态

Events：
- `update:form` - 信息更新事件
- `update:avatarPreview` - 头像更新事件
- `update:loading` - 加载状态更新

### ResumeManagement.vue（简历管理）
职责：
- 简历列表展示
- 简历上传（支持覆盖）
- 简历预览
- 简历删除

Props：
- `studentId` - 学生ID

公开方法：
- `fetchResumes(studentId)` - 加载简历列表

### DeliveryStatus.vue（投递动态）
职责：
- 显示应聘投递记录
- 应聘状态查看

数据：
- `deliveryData` - 投递记录列表

### FavoriteList.vue（我的收藏）
职责：
- 显示收藏的职位

### MessageCenter.vue（消息中心）
职责：
- 显示系统通知和消息
- 消息已读状态管理

## 🔄 数据流向

```
ProfileView.vue (父)
    ↓
    ├─→ ProfileSidebar
    ├─→ ProfileInfo
    ├─→ ResumeManagement
    ├─→ DeliveryStatus
    ├─→ FavoriteList
    └─→ MessageCenter
```

## 💡 主要改进

1. **代码分离** - 将1个653行的大组件拆分成6个专用组件
2. **职责单一** - 每个组件只负责一个功能模块
3. **可复用性** - 子组件可以独立使用或复用
4. **易于维护** - 修改某个功能只需修改对应的子组件
5. **性能优化** - 可以为子组件设置条件渲染，按需加载

## 🚀 使用建议

- 可以为 `ResumeManagement` 添加分页功能
- 可以为 `DeliveryStatus` 添加数据筛选功能
- 可以为子组件添加动画过渡效果
- 可以将共同的API调用逻辑提取到composables中
