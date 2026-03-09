<script setup lang="ts">
import { computed } from 'vue'
import { RouterView } from 'vue-router'
import HeaderBar from './components/HeaderBar.vue'
// 1. 引入获取角色的工具函数
import { getToken, getRoleFromToken } from '@/utils/auth'

// 2. 获取当前角色并判断是否为学生
const isStudent = computed(() => {
  const token = getToken()
  if (!token) return false
  
  const role = getRoleFromToken(token)
  return role === 'STUDENT'
})
</script>

<template>
  <HeaderBar v-if="isStudent" />
  <!-- <Sidebar v-else /> -->
  <RouterView />
</template>