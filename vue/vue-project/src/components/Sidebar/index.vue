<!-- components/Sidebar/index.vue -->
<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { getToken, getRoleFromToken } from '@/utils/auth'

import {
  Menu as IconMenu,
  UserFilled,
  OfficeBuilding,
  Briefcase,
  Document,
  Setting,
  Fold,       // 收起图标
  Expand      // 展开图标
} from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()

const role = computed(() => {
  const token = getToken()
  return token ? getRoleFromToken(token) : null
})

const isAdmin = computed(() => role.value === 'ADMIN')
const isCompany = computed(() => role.value === 'COMPANY')

// 核心：控制收起/展开状态
const isCollapsed = ref(false)

// 可选：点击 logo 或某个按钮收起/展开
const toggleCollapse = () => {
  isCollapsed.value = !isCollapsed.value
}
</script>

<template>
  <div class="sidebar-wrapper" :class="{ collapsed: isCollapsed }">
    <el-menu
      :default-active="route.path"
      class="el-menu-vertical"
      :collapse="isCollapsed"
      :collapse-transition="true"
      router
      background-color="var(--el-menu-bg-color)"
      text-color="var(--el-menu-text-color)"
      active-text-color="var(--el-menu-active-color)"
    >
      <!-- Logo + 折叠按钮 -->
      <div class="logo-area">
        <div class="logo" :style="{ display: isCollapsed ? 'none' : 'block' }">管理后台</div>
        <el-button
          type="primary"
          :icon="isCollapsed ? Expand : Fold"
          circle
          size="small"
          class="toggle-btn"
          @click="toggleCollapse"
          style="color: #0168d1;"
        />
      </div>

      <!-- ADMIN 菜单 -->
      <template v-if="isAdmin">
        <el-menu-item index="/admin/users">
          <el-icon><UserFilled /></el-icon>
          <template #title>用户管理</template>
        </el-menu-item>
        <el-menu-item index="/admin/settings">
          <el-icon><Setting /></el-icon>
          <template #title>系统设置</template>
        </el-menu-item>
      </template>

      <!-- COMPANY 菜单 -->
      <template v-if="isCompany">
        <el-menu-item index="/company/jobs">
          <el-icon><Briefcase /></el-icon>
          <template #title>职位发布</template>
        </el-menu-item>
        <el-menu-item index="/company/resumes">
          <el-icon><Document /></el-icon>
          <template #title>简历收件箱</template>
        </el-menu-item>
      </template>
    </el-menu>
  </div>
</template>

<style scoped>
.sidebar-wrapper {
  height: 100vh;
  transition: width 0.3s ease;
  overflow: hidden;
  background: #ffffff;
  border-right: 1px solid #e6e9ef;
}

.sidebar-wrapper:not(.collapsed) {
  width: 220px;  /* 展开宽度，可调 */
}

.sidebar-wrapper.collapsed {
  width: 64px;   /* 收起只剩图标宽度 */
}

.logo-area {
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 16px;
  border-bottom: 1px solid #e6e9ef;
  position: relative;
}

.logo {
  font-size: 1.25rem;
  font-weight: 600;
  color: #0168d1;
  white-space: nowrap;
}

.toggle-btn {
  --el-button-bg-color: transparent;
  --el-button-border-color: transparent;
  --el-button-hover-bg-color: #f0f5ff;
  --el-button-hover-text-color: #0168d1;
  position: absolute;
  right: 12px;
}

/* 收起时隐藏文字，只显示图标 */
:deep(.el-menu--collapse) .el-menu-item__title {
  display: none;
}

:deep(.el-menu-item) {
  justify-content: flex-start;
}
.el-menu-item:hover {
  background-color: #f0f5ff;
  color: #0168d1;
}
</style>