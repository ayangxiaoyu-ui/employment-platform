<template>
    <section class="content-card">
        <h3>投递动态</h3>
        <div class="delivery-timeline">
            <el-table :data="deliveryData" style="width: 100%" v-loading="loading" @row-click="openJobDetail">
                <el-table-column prop="companyName" label="公司" />
                <el-table-column prop="jobTitle" label="岗位" />
                <el-table-column label="当前状态">
                    <template #default="scope">
                        <el-tag :type="getStatusType(scope.row.status)">
                            {{ getStatusText(scope.row.status) }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="createTime" label="投递日期">
                    <template #default="{ row }">
                        {{ formatDate(row.createTime) }}
                    </template>
                </el-table-column>
            </el-table>

            <el-empty v-if="deliveryData.length === 0 && !loading" description="暂无投递记录" />
        </div>

        <!-- 岗位详情弹窗 -->
        <JobDetailDialog ref="jobDetailRef" :studentId="props.studentId" :currentJobId="currentJobId" />
    </section>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import axios from 'axios'
import { getToken } from '@/utils/auth'
import JobDetailDialog from '@/components/StudentProfile/JobDetailDialog.vue'

interface Props {
    studentId: number | null
}
const props = defineProps<Props>()

interface DeliveryRecord {
    jobId: number
    companyName: string
    jobTitle: string
    status: number
    createTime: string
}

const deliveryData = ref<DeliveryRecord[]>([])
const loading = ref(false)

const jobDetailRef = ref()
const currentJobId = ref<number | null>(null)

const openJobDetail = (row: DeliveryRecord) => {
    if (!row.jobId) return
    currentJobId.value = row.jobId
    jobDetailRef.value?.open(row.jobId)
}

const loadDelivery = async (id: number) => {
    if (!id) return
    loading.value = true
    try {
        const res = await axios.get(`/api/application/student/${id}`, {
            headers: { 'Authorization': `Bearer ${getToken()}` }
        })
        if (res.data.code === "200") {
            deliveryData.value = res.data.data || []
        }
    } finally {
        loading.value = false
    }
}

watch(() => props.studentId, (newId) => {
    if (newId) loadDelivery(newId)
}, { immediate: true })

const formatDate = (time: string) => {
    if (!time) return '—'
    const date = new Date(time)
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')} ${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`
}

const getStatusText = (status: number) => ({
    0: "待查看",
    1: "已查看",
    2: "面试邀请",
    3: "不合适",
    4: "已录用"
}[status] || "未知")

const getStatusType = (status: number) => {
    switch (status) {
        case 2: return "warning"
        case 4: return "success"
        case 3: return "danger"
        case 1: return ""
        default: return "info"
    }
}

onMounted(() => {
    if (props.studentId) loadDelivery(props.studentId)
})
</script>
