<template>
    <div class="w-[1000px] mx-auto py-6 flex flex-col gap-[20px]">

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
