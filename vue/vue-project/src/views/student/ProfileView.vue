<template>
  <div class="student-profile-container">
    <div class="main-layout">
      <ProfileSidebar :active-tab="activeTab" :form="form" :avatar-preview="avatarPreview"
        :username-from-token="usernameFromToken" @update:active-tab="activeTab = $event" @go-home="goToHome" />

      <main class="content-body" v-loading="loading">
        <ProfileInfo v-if="activeTab === 'info'" :form="form" :avatar-preview="avatarPreview"
          :username-from-token="usernameFromToken" :loading="loading" @update:form="form = $event"
          @update:avatar-preview="avatarPreview = $event" @update:loading="loading = $event" />

        <ResumeManagement v-if="activeTab === 'resume'" :student-id="studentId" ref="resumeComponent" />

        <DeliveryStatus v-if="activeTab === 'apply'" :student-id="studentId" />

        <FavoriteList v-if="activeTab === 'favorite'" :student-id="studentId" />

        <MessageCenter v-if="activeTab === 'message'" :user-id="studentId" />


      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getToken, getUsernameFromToken } from '@/utils/auth'

// 导入子组件
import ProfileSidebar from '@/components/StudentProfile/ProfileSidebar.vue'
import ProfileInfo from '@/components/StudentProfile/ProfileInfo.vue'
import ResumeManagement from '@/components/StudentProfile/ResumeManagement.vue'
import DeliveryStatus from '@/components/StudentProfile/DeliveryStatus.vue'
import FavoriteList from '@/components/StudentProfile/FavoriteList.vue'
import MessageCenter from '@/components/StudentProfile/MessageCenter.vue'
import { nextTick } from 'vue'

// 类型定义
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

const router = useRouter()
const activeTab = ref('info')
const loading = ref(false)
const resumeComponent = ref()

// 数据
const form = ref<StudentProfile>({
  name: '',
  gender: '',
  phone: '',
  email: '',
  university: '',
  major: '',
  graduationYear: null,
  avatar: ''
})
const studentId = ref<number | null>(null)
const userId = ref<number | null>(null)
const avatarPreview = ref('')

// 计算属性
const usernameFromToken = computed(() => getUsernameFromToken(getToken() || '') || '未知用户')

// 方法
const fetchProfile = async () => {
  loading.value = true
  try {
    const res = await fetch('/api/student/profile', {
      headers: { 'Authorization': `Bearer ${getToken()}` }
    })
    const result = await res.json()
    if (result.code === '200' && result.data) {
      form.value = { ...result.data, name: result.data.name || usernameFromToken.value }
      avatarPreview.value = result.data.avatar ? `http://localhost:9999${result.data.avatar}` : ''
      studentId.value = result.data.id ? Number(result.data.id) : null
      // 你父组件里的这行可能有误
      userId.value = result.data.userId ? Number(result.data.userId) : null
      console.log("加载到 studentId =", studentId.value)
    }
  } finally {
    loading.value = false
  }
}

const goToHome = () => router.push({ name: 'student' })

// 监听 Tab 切换 - 当切换到 resume 时加载简历列表
watch(activeTab, async (newTab) => {
  if (newTab === 'resume') {
    // 等待 Vue 完成 DOM 更新（即 v-if 渲染完成）
    await nextTick()

    if (resumeComponent.value && studentId.value) {
      resumeComponent.value.fetchResumes(studentId.value)
    }
  }
  if (newTab === 'apply') {
    // 切换到投递记录时，刷新投递记录数据
    await nextTick()

  }
})
onMounted(() => {
  if (!getToken()) return router.push({ name: 'login' })
  fetchProfile()
})
</script>

<style scoped>
.student-profile-container {
  min-height: 100vh;
  background-color: #f5f7fa;
  padding: 20px;
}

.main-layout {
  max-width: 1100px;
  margin: 0 auto;
  display: flex;
  gap: 20px;
}

/* 内容区样式 */
.content-body {
  flex: 1;
}
</style>