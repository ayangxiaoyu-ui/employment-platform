<!-- components/Sidebar/index.vue -->
<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { ElMessageBox } from 'element-plus'
import { getToken, getRoleFromToken, clearToken } from '@/utils/auth'

import {
  Menu as IconMenu,
  OfficeBuilding,
  Briefcase,
  Document,
  Message,
  Fold,
  Expand,
  Reading,
  Odometer,
  School,
  SwitchButton,
  Bell,
} from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()

const handleLogout = () => {
  ElMessageBox.confirm(getLogoutConfirmMessage(), '退出登录', {
    confirmButtonText: '退出',
    cancelButtonText: '取消',
    type: 'warning',
  })
    .then(() => {
      clearToken()
      router.push({ name: 'login' })
    })
    .catch(() => {})
}

const role = computed(() => {
  const token = getToken()
  return token ? getRoleFromToken(token) : null
})

const isAdmin = computed(() => role.value === 'ADMIN')
const isCompany = computed(() => role.value === 'COMPANY')
const canLogout = computed(() => isAdmin.value || isCompany.value)

// 控制折叠
const isCollapsed = ref(false)
const toggleCollapse = () => {
  isCollapsed.value = !isCollapsed.value
}

const getLogoutConfirmMessage = () => {
  if (isAdmin.value) return '确定退出当前管理员账号？'
  return '确定退出当前企业账号？'
}
</script>

<template>
  <div class="sidebar-wrapper" :class="{ collapsed: isCollapsed }">
    <el-menu :default-active="route.path" class="el-menu-vertical menu-scroll" :collapse="isCollapsed" router
      background-color="var(--el-menu-bg-color)" text-color="var(--el-menu-text-color)"
      active-text-color="var(--el-menu-active-color)">
      <!-- Logo + 折叠按钮 -->
      <div class="logo-area">
        <div class="logo" :style="{ display: isCollapsed ? 'none' : 'block' }">管理后台</div>
        <el-button type="primary" :icon="isCollapsed ? Expand : Fold" circle size="small" class="toggle-btn"
          @click="toggleCollapse" style="color: #0168d1;" />
      </div>

      <!-- ADMIN 菜单 -->
      <template v-if="isAdmin">
        <el-menu-item index="/admin/dashboard">
          <el-icon>
            <Odometer />
          </el-icon>
          <template #title>数据看板</template>
        </el-menu-item>

        <el-menu-item index="/admin/news">
          <el-icon>
            <Bell />
          </el-icon>
          <template #title>公告通知</template>
        </el-menu-item>

        <el-menu-item index="/admin/guide">
          <el-icon>
            <Reading />
          </el-icon>
          <template #title>就业指导</template>
        </el-menu-item>

      </template>

      <!-- COMPANY 菜单 -->
      <template v-if="isCompany">
        <el-menu-item index="/company">
          <el-icon>
            <Odometer />
          </el-icon>
          <template #title>工作台</template>
        </el-menu-item>

        <el-menu-item index="/company/profile">
          <el-icon>
            <OfficeBuilding />
          </el-icon>
          <template #title>个人中心</template>
        </el-menu-item>

        <el-menu-item index="/company/jobs">
          <el-icon>
            <Briefcase />
          </el-icon>
          <template #title>职位发布</template>
        </el-menu-item>

        <el-menu-item index="/company/resumes">
          <el-icon>
            <Document />
          </el-icon>
          <template #title>简历收件箱</template>
        </el-menu-item>

        <el-menu-item index="/company/students">
          <el-icon>
            <School />
          </el-icon>
          <template #title>学生库</template>
        </el-menu-item>

        <!-- ⭐ 新增：互动消息 -->
        <el-menu-item index="/company/messages">
          <el-icon>
            <Message />
          </el-icon>
          <template #title>互动消息</template>
        </el-menu-item>

        <el-menu-item index="/company/guide">
          <el-icon>
            <Reading />
          </el-icon>
          <template #title>就业指导</template>
        </el-menu-item>
      </template>
    </el-menu>

    <div v-if="canLogout" class="sidebar-footer">
      <el-button class="logout-btn" :class="{ 'is-collapsed': isCollapsed }" plain @click="handleLogout">
        <el-icon><SwitchButton /></el-icon>
        <span v-show="!isCollapsed" class="logout-text">退出登录</span>
      </el-button>
    </div>
  </div>
</template>

<style scoped>
.sidebar-wrapper {
  height: 100vh;
  transition: width 0.3s ease;
  overflow: hidden;
  background: #ffffff;
  border-right: 1px solid #e6e9ef;
  display: flex;
  flex-direction: column;
}

.menu-scroll {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
  border-right: none !important;
}

.sidebar-footer {
  flex-shrink: 0;
  padding: 12px;
  border-top: 1px solid #e6e9ef;
  background: #fafbfc;
}

.logout-btn {
  width: 100%;
  justify-content: flex-start;
  color: #606266;
  border-color: #dcdfe6;
}

.logout-btn:hover {
  color: #f56c6c;
  border-color: #fbc4c4;
  background: #fef0f0;
}

.logout-btn.is-collapsed {
  width: 100%;
  padding: 8px;
  justify-content: center;
}

.logout-text {
  margin-left: 8px;
}

.sidebar-wrapper:not(.collapsed) {
  width: 220px;
}

.sidebar-wrapper.collapsed {
  width: 64px;
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

:deep(.el-menu-item.is-active) {
  background-color: #e8f3ff !important;
  color: #0168d1 !important;
  font-weight: 600;
  border-right: 3px solid #0168d1;
}
</style>
