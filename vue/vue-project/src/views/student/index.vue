<template>
  <div class="w-[900px] mx-auto py-6 flex flex-col gap-[20px]">

    <!-- 轮播图 -->
    <SlideShow />

    <!-- 最新发布岗位 -->
    <LatestJobs @open-detail="openJobDetail" />

    <!-- 职位详情弹窗 -->
    <JobDetailDialog ref="jobDetailRef" :student-id="studentId" :current-job-id="currentJobId" />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { getToken } from '@/utils/auth'

import SlideShow from './SlideShow.vue'
import LatestJobs from '@/components/StudentProfile/LatestJobs.vue'
import JobDetailDialog from '@/components/StudentProfile/JobDetailDialog.vue'

const studentId = ref(null)
const jobDetailRef = ref(null)
const currentJobId = ref(null)

// ⭐ 点击岗位 → 打开弹窗
const openJobDetail = (jobId) => {
  currentJobId.value = jobId
  jobDetailRef.value.open(jobId)
}

// ⭐ 页面加载时获取 studentId
onMounted(async () => {
  const res = await axios.get('/api/student/profile', {
    headers: { Authorization: `Bearer ${getToken()}` }
  })
  if (res.data.code === "200") {
    studentId.value = res.data.data.id
  }
})
</script>
