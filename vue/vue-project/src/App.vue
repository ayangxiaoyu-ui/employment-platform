<!-- src/App.vue 或 layouts/DefaultLayout.vue -->
<script setup lang="ts">
import { ref, computed } from 'vue'
import { RouterView } from 'vue-router'
import HeaderBar from './components/HeaderBar.vue'
import SideBar from './components/Sidebar/index.vue'
import { getToken, getRoleFromToken } from '@/utils/auth'

// 收起状态（默认展开）
const collapsed = ref(false)

const role = computed(() => {
  const token = getToken()
  return token ? getRoleFromToken(token) : null
})

const isStudent = computed(() => role.value === 'STUDENT')
const isManagement = computed(() => role.value === 'ADMIN' || role.value === 'COMPANY')
</script>

<template>
  <div class="app-container">
    <!-- 学生端：只有顶栏 -->
    <HeaderBar v-if="isStudent" />

    <!-- 管理/企业端：侧边栏 + 内容区 -->
    <div class="main-layout" v-if="isManagement || isStudent">
      <SideBar
        v-if="isManagement"
        v-model:collapsed="collapsed"
      />

      <main
        class="content"
      >
        <RouterView />
      </main>
    </div>

    <!-- 如果既不是学生也不是管理角色，可以放一个 fallback 或 404 -->
  </div>
</template>

<style scoped>
.app-container {
  height: 100vh;
  overflow: hidden;
}

.main-layout {
  display: flex;
  height: 100%;
}

.content {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  background: #f8f9fc; /* 浅底色，保持亮色感 */
}
</style>