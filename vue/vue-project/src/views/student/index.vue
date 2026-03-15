<template>
  <div class="w-[900px] mx-auto py-6 flex flex-col gap-[20px]">

    <SlideShow />

    <el-tabs v-model="activeTab" class="job-tabs">

      <!-- 最新岗位 -->
      <el-tab-pane name="latest">
        <template #label>
          <span class="flex items-center gap-1 pl-4">
            <el-icon>
              <Clock />
            </el-icon>
            最新岗位
          </span>
        </template>
        <LatestJobs @open-detail="openJobDetail" />
      </el-tab-pane>

      <!-- 最热门岗位 -->
      <el-tab-pane name="hot">
        <template #label>
          <span class="flex items-center gap-1 ">
            <el-icon>
              <HotWater />
            </el-icon>
            最热门岗位
          </span>
        </template>
        <HotJobs @open-detail="openJobDetail" />
      </el-tab-pane>

      <!-- 为你推荐 -->
      <el-tab-pane v-if="studentId" name="recommend">
        <template #label>
          <span class="flex items-center gap-1 ">
            <el-icon>
              <Star />
            </el-icon>
            为你推荐
          </span>
        </template>
        <RecommendJobs :student-id="studentId" @open-detail="openJobDetail" />
      </el-tab-pane>

    </el-tabs>
    <LatestNews />


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
import { Clock, HotWater, Star } from '@element-plus/icons-vue'
import LatestNews from './LatestNews.vue'


const studentId = ref(null)
const jobDetailRef = ref(null)
const currentJobId = ref(null)
const activeTab = ref("latest")   // ⭐ 默认显示最新岗位

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
.job-tabs {
  background: white;
  padding: 10px 0;
  border-radius: 12px;
}
</style>
