<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import {
    getToken,
    getRoleFromToken,
    getUsernameFromToken,
    type UserRole,
    clearToken,
} from '@/utils/auth'

const router = useRouter()

const token = computed(() => getToken())
const role = computed<UserRole | null>(() => {
    const t = token.value
    return t ? getRoleFromToken(t) : null
})
const username = computed(() => {
    const t = token.value
    return t ? getUsernameFromToken(t) : null
})

const isAuthed = computed(() => !!token.value)
// 只有学生 / 企业显示“个人中心”
const canShowProfile = computed(
    () => role.value === 'STUDENT' || role.value === 'COMPANY'
)


async function goHome() {
    await router.push('/')
}

async function goLogin() {
    await router.push({ name: 'login' })
}

async function goRegister() {
    await router.push({ name: 'register' })
}

function goProfile() {
    if (role.value === 'STUDENT') {
        router.push({ name: 'studentProfile' })
    } else if (role.value === 'COMPANY') {
        router.push({ name: 'companyProfile' })
    }
}

async function handleLogout() {
    clearToken()
    await router.push({ name: 'login' })
}
</script>

<template>
    <header class="header">
        <!-- 左侧 Logo + 名称 -->
        <div class="logo-area" @click="goHome">
            <!-- 你可以换成 <img> -->
            <div><img src="../assets/logo.jpg" alt="" class="logo-circle"></div>
            <div class="logo-text">
                <div class="name">大学生就业服务平台</div>
                <div class="sub">Employment Service Platform</div>
            </div>
        </div>

        <!-- 中间主导航 -->
        <nav class="nav">
            <RouterLink class="nav-item" to="/">首页</RouterLink>
            <RouterLink class="nav-item" to="/jobs">招聘信息</RouterLink>
            <RouterLink class="nav-item" to="/companies">企业列表</RouterLink>
            <RouterLink class="nav-item" to="/guidance">就业指导</RouterLink>
            <RouterLink class="nav-item" to="/news">公告通知</RouterLink>
        </nav>

        <!-- 右侧登录 / 注册 / 个人中心 -->
        <div class="auth-area">
            <!-- 未登录：显示 登录 / 注册 -->
            <template v-if="!isAuthed">
                <button class="text-btn" type="button" @click="goLogin">登录</button>
                <button class="primary-btn" type="button" @click="goRegister">注册</button>
            </template>

            <!-- 已登录：显示用户名 + 个人中心（仅学生/企业） + 退出 -->
            <template v-else>
                <span class="user-info">
                    {{ username || '已登录用户' }}
                    <span v-if="role">（{{ role }}）</span>
                </span>

                <button v-if="canShowProfile" class="primary-btn" type="button" @click="goProfile">
                    个人中心
                </button>

                <button class="text-btn" type="button" @click="handleLogout">
                    退出
                </button>
            </template>
        </div>
    </header>
</template>

<style scoped>
.header {
    height: 64px;
    padding: 0 32px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    position: relative; 
    gap: 24px;
    border-bottom: 1px solid var(--color-border);
    background-color: #0168d1;
    color: #fff;
}

.logo-area {
    display: flex;
    align-items: center;
    gap: 12px;
    cursor: pointer;
}

.logo-circle {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    background: var(--color-background-mute);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 18px;
}

.logo-text .name {
    font-size: 16px;
    font-weight: 600;
    color: #fff;
}

.logo-text .sub {
    font-size: 11px;
    color: #fff;
}

.nav {
    position: absolute;     /* 👈 关键 */
    left: 50%;
    transform: translateX(-50%);
    display: flex;
    align-items: center;
    gap: 40px;
}

.nav-item {
    font-size: 16px;
    color: #fff;
    position: relative;
    padding: 0 16px; /* 给分割线留空间 */
    text-decoration: none;  
}


.nav-item::after {
    content: '';
    position: absolute;
    right: 0;
    top: 50%;
    transform: translateY(-50%);
    width: 1px;
    height: 14px;
    background-color: rgba(255, 255, 255, 0.6);
}

.nav-item:last-child::after {
    display: none;
}

.nav-item.router-link-active {
    opacity: 1;
    font-weight: 600;
}

.auth-area {
    display: flex;
    align-items: center;
    gap: 12px;
}

.user-info {
    font-size: 13px;
}

.text-btn {
    border: none;
    background: transparent;
    color: #fff;
    cursor: pointer;
    font-size: 14px;
}

.primary-btn {
    padding: 6px 14px;
    border-radius: 999px;
    border: 1px solid var(--color-border);
    background: #EFF4FA;
    color: #000;
    cursor: pointer;
    font-size: 14px;
}
</style>