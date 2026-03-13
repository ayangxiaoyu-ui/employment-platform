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
                <el-icon>
                    <component :is="item.icon" />
                </el-icon>
                <span>{{ item.label }}</span>
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
import { getUsernameFromToken } from '@/utils/auth'

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
]

const defaultAvatarText = computed(() => {
    const name = (props.form?.name || props.usernameFromToken || '匿').trim()
    return name!.match(/^[\u4e00-\u9fa5]/) ? name![0] : name![0].toUpperCase()
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
    background: white;
    border-radius: 12px;
    display: flex;
    flex-direction: column;
    padding: 24px 0;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
    height: fit-content;
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
}

.side-avatar,
.side-avatar-default {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #e6f0ff;
    color: #409eff;
    font-size: 32px;
}

.nickname {
    font-weight: bold;
    color: #333;
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
    transition: all 0.3s;
}

.menu-item:hover {
    background-color: #f0f7ff;
    color: #409eff;
}

.menu-item.active {
    background-color: #ecf5ff;
    color: #409eff;
    border-right: 3px solid #409eff;
}

.sidebar-footer {
    padding: 12px 24px;
}
</style>
