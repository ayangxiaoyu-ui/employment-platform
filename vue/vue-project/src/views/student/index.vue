<template>
  <div class="w-[900px] mx-auto py-6 flex flex-col gap-[20px]">

    <SlideShow />

    <LatestJobs @open-detail="openJobDetail" />

    <HotJobs @open-detail="openJobDetail" />

    <RecommendJobs v-if="studentId" :student-id="studentId" @open-detail="openJobDetail" />

    <JobDetailDialog ref="jobDetailRef" :student-id="studentId" :current-job-id="currentJobId" />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { getToken } from '@/utils/auth'

import SlideShow from './SlideShow.vue'
import LatestJobs from '@/components/StudentProfile/LatestJobs.vue'
import HotJobs from '@/components/StudentProfile/HotJobs.vue'
import RecommendJobs from '@/components/StudentProfile/RecommendJobs.vue'
import JobDetailDialog from '@/components/StudentProfile/JobDetailDialog.vue'

const studentId = ref(null)
const jobDetailRef = ref(null)
const currentJobId = ref(null)

const openJobDetail = (jobId) => {
  currentJobId.value = jobId
  jobDetailRef.value.open(jobId)
}

onMounted(async () => {
  const res = await axios.get('/api/student/profile', {
    headers: { Authorization: `Bearer ${getToken()}` }
  })
  if (res.data.code === "200") {
    studentId.value = Number(res.data.data.id)
  }
})
</script>

<style scoped>
/* 你可以在这里写样式 */
</style>
