<template>
  <div class="student-profile-container">
    <div class="main-layout">
      <ProfileSidebar :active-tab="activeTab" :form="form" :avatar-preview="avatarPreview"
        :username-from-token="usernameFromToken" @update:active-tab="changeTab" @go-home="goToHome" />

      <main class="content-body" v-loading="loading">
        <!-- 基本信息 -->
        <ProfileInfo v-if="activeTab === 'info'" :form="form" :avatar-preview="avatarPreview"
          :username-from-token="usernameFromToken" :loading="loading" @update:form="form = $event"
          @update:avatar-preview="avatarPreview = $event" @update:loading="loading = $event" />

        <!-- 简历管理 -->
        <ResumeManagement v-if="activeTab === 'resume'" :student-id="studentId" ref="resumeComponent" />

        <!-- 投递记录 -->
        <DeliveryStatus v-if="activeTab === 'apply'" :student-id="studentId" />

        <!-- 收藏列表 -->
        <FavoriteList v-if="activeTab === 'favorite'" :student-id="studentId" />

        <!-- 消息中心 -->
        <MessageCenter v-if="activeTab === 'message'" :user-id="studentId" />

        <!-- 足迹 -->
        <FootprintList v-if="activeTab === 'footprint'" :student-id="studentId" @open-detail="openJobDetail" />

        <!-- 职位详情弹窗 -->
        <JobDetailDialog ref="jobDetailRef" :student-id="studentId" :current-job-id="currentJobId" />
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed, watch, nextTick } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { getToken, getUsernameFromToken } from '@/utils/auth'

// 子组件
import ProfileSidebar from '@/components/StudentProfile/ProfileSidebar.vue'
import ProfileInfo from '@/components/StudentProfile/ProfileInfo.vue'
import ResumeManagement from '@/components/StudentProfile/ResumeManagement.vue'
import DeliveryStatus from '@/components/StudentProfile/DeliveryStatus.vue'
import FavoriteList from '@/components/StudentProfile/FavoriteList.vue'
import MessageCenter from '@/components/StudentProfile/MessageCenter.vue'
import FootprintList from '@/components/StudentProfile/FootprintList.vue'
import JobDetailDialog from '@/components/StudentProfile/JobDetailDialog.vue'

const router = useRouter()
const route = useRoute()

// ⭐ 从 URL 初始化 activeTab
const activeTab = ref(route.query.tab || 'info')

// ⭐ 监听 URL 变化（从首页快捷入口跳转时触发）
watch(
  () => route.query.tab,
  (newTab) => {
    if (newTab) activeTab.value = newTab
  }
)

// ⭐ 切换 tab 时同步 URL
const changeTab = (tab: string) => {
  activeTab.value = tab
  router.replace({
    path: '/student/profile',
    query: { tab }
  })
}

const loading = ref(false)
const resumeComponent = ref()

const form = ref({
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

// 用户名
const usernameFromToken = computed(() =>
  getUsernameFromToken(getToken() || '') || '未知用户'
)

// 加载学生信息
const fetchProfile = async () => {
  loading.value = true
  try {
    const res = await fetch('/api/student/profile', {
      headers: { Authorization: `Bearer ${getToken()}` }
    })
    const result = await res.json()

    if (result.code === '200' && result.data) {
      form.value = { ...result.data }
      avatarPreview.value = result.data.avatar
        ? `http://localhost:9999${result.data.avatar}`
        : ''
      studentId.value = Number(result.data.id)
      userId.value = Number(result.data.userId)
    }
  } finally {
    loading.value = false
  }
}

const goToHome = () => router.push({ name: 'student' })

// ⭐ 简历 tab：加载简历列表
watch(activeTab, async newTab => {
  if (newTab === 'resume') {
    await nextTick()
    if (resumeComponent.value && studentId.value) {
      resumeComponent.value.fetchResumes(studentId.value)
    }
  }
})

// 足迹 → 打开职位详情
const jobDetailRef = ref(null)
const currentJobId = ref(null)

const openJobDetail = (jobId: number) => {
  currentJobId.value = jobId
  jobDetailRef.value.open(jobId)
}

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

.content-body {
  flex: 1;
}
</style>
