<template>
    <section class="content-card">
        <h3>投递动态</h3>
        <div class="delivery-timeline">
            <el-table :data="pagedData" style="width: 100%" v-loading="loading" @row-click="openJobDetail">
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

            <div v-if="total > 0" class="pager-wrap">
                <el-pagination
                    v-model:current-page="page"
                    v-model:page-size="pageSize"
                    :total="total"
                    :page-sizes="[10, 20, 50]"
                    layout="total, sizes, prev, pager, next, jumper"
                    background
                    @size-change="onPageSizeChange"
                />
            </div>

            <el-empty v-if="total === 0 && !loading" description="暂无投递记录" />
        </div>

        <!-- 岗位详情弹窗 -->
        <JobDetailDialog ref="jobDetailRef" :studentId="props.studentId" :currentJobId="currentJobId" />
    </section>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
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

const allRecords = ref<DeliveryRecord[]>([])
const page = ref(1)
const pageSize = ref(10)
const loading = ref(false)

const total = computed(() => allRecords.value.length)

const pagedData = computed(() => {
    const start = (page.value - 1) * pageSize.value
    return allRecords.value.slice(start, start + pageSize.value)
})

const onPageSizeChange = () => {
    page.value = 1
}

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
            allRecords.value = res.data.data || []
            page.value = 1
        }
    } finally {
        loading.value = false
    }
}

watch(() => props.studentId, (newId) => {
    if (!newId) {
        allRecords.value = []
        page.value = 1
        return
    }
    loadDelivery(newId)
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
        case 1: return "primary"
        default: return "info"
    }
}

</script>

<style scoped>
.pager-wrap {
    display: flex;
    justify-content: flex-end;
    margin-top: 16px;
    padding-top: 8px;
}
.content-card h3 {
    font-size: 20px;
    font-weight: 700;
    color: #333;
    margin-bottom: 16px;
    display: flex;
    align-items: center;
    gap: 8px;
}

.content-card {
    min-height: 100vh;
  background-color: #ffffff;
  padding: 20px;
}
.content-card h3::before {
    content: "";
    width: 4px;
    height: 20px;
    background: linear-gradient(180deg, #409EFF, #66b1ff);
    border-radius: 2px;
    display: inline-block;

}

</style>
