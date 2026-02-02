<script setup lang="ts">
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { clearToken, getToken, getUsernameFromToken, type UserRole } from '@/utils/auth'

const props = defineProps<{
  role: UserRole
}>()

const router = useRouter()

const token = computed(() => getToken())
const username = computed(() => {
  const current = token.value
  return current ? getUsernameFromToken(current) : null
})

const title = computed(() => {
  if (props.role === 'ADMIN') return '管理员页面'
  if (props.role === 'COMPANY') return '企业页面'
  return '学生页面'
})

async function logout() {
  clearToken()
  await router.replace({ name: 'login' })
}
</script>

<template>
  <main class="page">
    <div class="container">
      <h1 class="title">{{ title }}</h1>
      <p class="welcome">欢迎，{{ username }}</p>
      <button class="logout-btn" type="button" @click="logout">退出登录</button>
    </div>
  </main>
</template>

<style scoped>

</style>
