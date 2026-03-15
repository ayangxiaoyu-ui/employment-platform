<template>
    <div class="w-[1000px] mx-auto py-6 flex flex-col gap-[20px]">
        <div class="search-bar flex gap-3 mb-6">
            <el-input v-model="keyword" placeholder="搜索职位 / 公司 / 地点" clearable class="w-[300px]"
                @keyup.enter="searchJobs" />

            <el-button type="primary" @click="searchJobs">搜索</el-button>
            <el-button @click="resetSearch">重置</el-button>
        </div>

        <div class="header">
            <h2>📋 招聘信息</h2>
        </div>

        <JobCardList :jobs="jobs" @open-detail="openDetail" />

        <JobDetailDialog ref="jobDetailRef" :student-id="studentId" :current-job-id="currentJobId" />
    </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { getToken } from '@/utils/auth'

import JobCardList from '@/components/StudentProfile/JobCardList.vue'
import JobDetailDialog from '@/components/StudentProfile/JobDetailDialog.vue'

const jobs = ref([])
const studentId = ref(null)
const jobDetailRef = ref(null)
const currentJobId = ref(null)
const keyword = ref("")

const searchJobs = async () => {
    const res = await axios.get("/api/job/search", {
        params: { keyword: keyword.value }
    })
    if (res.data.code === "200") {
        jobs.value = res.data.data
    }
}

const resetSearch = () => {
    keyword.value = ""
    load()   // 重新加载全部岗位
}


const load = async () => {
    const res = await axios.get('/api/job/all')
    if (res.data.code === "200") {
        jobs.value = res.data.data
    }
}

const openDetail = (id) => {
    currentJobId.value = id
    jobDetailRef.value.open(id)
}

onMounted(async () => {
    const res = await axios.get('/api/student/profile', {
        headers: { Authorization: `Bearer ${getToken()}` }
    })
    if (res.data.code === "200") {
        studentId.value = Number(res.data.data.id)
    }

    load()
})
</script>

<style scoped>
.header h2 {
    font-size: 24px;
    font-weight: 700;
    margin-bottom: 10px;
}
</style>
