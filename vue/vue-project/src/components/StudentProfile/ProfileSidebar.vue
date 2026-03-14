<template>
    <aside class="sidebar">
        <div class="user-info-brief">
            <div class="avatar-wrapper">
                <img v-if="avatarPreview" :src="avatarPreview" class="side-avatar" />
                <div v-else class="side-avatar-default">{{ defaultAvatarText }}</div>
            </div>
            <p class="nickname">{{ form.name || '未登录用户' }}</p>
        </div>

        <nav class="menu-nav">
            <div v-for="item in menuItems" :key="item.key" class="menu-item" :class="{ active: activeTab === item.key }"
                @click="handleMenuClick(item.key)">
                <el-icon class="menu-icon">
                    <component :is="item.icon" />
                </el-icon>
                <span class="menu-label">{{ item.label }}</span>
            </div>
        </nav>

        <div class="sidebar-footer">
            <el-button type="info" plain :icon="House" @click="goToHome" class="w-full">
                返回主页
            </el-button>
        </div>
    </aside>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { House, User, Document, Promotion, Star, ChatDotRound } from '@element-plus/icons-vue'

interface StudentProfile {
    id?: number
    userId?: number
    name: string
    gender: string
    phone: string
    email: string
    university: string
    major: string
    graduationYear: number | null
    avatar: string
}

interface Props {
    activeTab: string
    form: StudentProfile
    avatarPreview: string
    usernameFromToken: string
}

const props = withDefaults(defineProps<Props>(), {
    activeTab: 'info'
})

const emit = defineEmits<{
    'update:activeTab': [value: string]
    'go-home': []
}>()

const menuItems = [
    { key: 'info', label: '个人信息', icon: User },
    { key: 'resume', label: '简历管理', icon: Document },
    { key: 'apply', label: '我的投递', icon: Promotion },
    { key: 'favorite', label: '我的收藏', icon: Star },
    { key: 'message', label: '互动消息', icon: ChatDotRound },
    { key: 'footprint', label: '访问足迹', icon: House },
]

// 计算默认头像显示的文字
const defaultAvatarText = computed(() => {
    const name = (props.form?.name || props.usernameFromToken || '匿').trim()
    return /^[\u4e00-\u9fa5]/.test(name) ? name[0] : name[0].toUpperCase()
})

const handleMenuClick = (key: string) => {
    emit('update:activeTab', key)
}

const goToHome = () => {
    emit('go-home')
}
</script>

<style scoped>
.sidebar {
    width: 240px;
    background: #ffffff;
    border-radius: 12px;
    display: flex;
    flex-direction: column;
    padding: 24px 0;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
    height: fit-content;
    user-select: none;
    /* 防止文字被意外选中 */
}

.user-info-brief {
    text-align: center;
    padding-bottom: 24px;
    border-bottom: 1px solid #f0f0f0;
    margin-bottom: 12px;
}

.avatar-wrapper {
    width: 80px;
    height: 80px;
    margin: 0 auto 12px;
    border-radius: 50%;
    overflow: hidden;
    border: 2px solid #409eff;
    background: #f5f7fa;
}

.side-avatar {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.side-avatar-default {
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #e6f0ff;
    color: #409eff;
    font-size: 32px;
    font-weight: bold;
}

.nickname {
    font-weight: 600;
    color: #303133;
    margin: 0;
    font-size: 16px;
}

.menu-nav {
    flex: 1;
}

.menu-item {
    display: flex;
    align-items: center;
    padding: 14px 24px;
    gap: 12px;
    cursor: pointer;
    color: #606266;
    transition: all 0.25s ease;
    width: 240px;

    box-sizing: border-box;
    position: relative;
}

.menu-item:hover {
    background-color: #f5f7fa;
    color: #409eff;
}

/* 核心修复：使用内阴影模拟右侧边框，不占用布局宽度 */
.menu-item.active {
    width: 240px;
    background-color: #ecf5ff;
    color: #409eff;
    font-weight: 500;
    box-shadow: inset -4px 0 0 0 #409eff;
}

.menu-icon {
    font-size: 18px;
}

.menu-label {
    font-size: 14px;
}

.sidebar-footer {
    padding: 12px 24px;
    margin-top: 12px;
}

.w-full {
    width: 100%;
}
</style>