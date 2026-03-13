<template>
    <section class="content-card">
        <h3>投递动态</h3>
        <div class="delivery-timeline">
            <el-table :data="deliveryData" style="width: 100%" v-loading="loading">
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
    </section>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import axios from 'axios'
import { getToken } from '@/utils/auth'

// 定义 Props
interface Props {
    studentId: number | null
}
const props = defineProps<Props>()

interface DeliveryRecord {
    companyName: string
    jobTitle: string
    status: number
    createTime: string
}

const deliveryData = ref<DeliveryRecord[]>([])
const loading = ref(false)

/**
 * 加载投递记录
 * @param id 学生ID
 */
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
    } catch (error) {
        console.error("获取投递列表失败:", error)
    } finally {
        loading.value = false
    }
}

/**
 * 监听 studentId 的变化
 * 应对父组件异步获取 profile 导致子组件挂载时 id 还没到的情况
 */
watch(() => props.studentId, (newId) => {
    if (newId) {
        loadDelivery(newId)
    }
}, { immediate: true })

// 格式化日期
const formatDate = (time: string) => {
    if (!time) return '—'
    const date = new Date(time)
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    const hour = String(date.getHours()).padStart(2, '0')
    const minute = String(date.getMinutes()).padStart(2, '0')
    return `${year}-${month}-${day} ${hour}:${minute}`
}

// 状态数字 → 中文
const getStatusText = (status: number) => {
    const statusMap: Record<number, string> = {
        0: "待查看",
        1: "已查看",
        2: "面试邀请",
        3: "不合适",
        4: "已录用"
    }
    return statusMap[status] || "未知"
}

// 状态数字 → Tag 颜色
const getStatusType = (status: number) => {
    switch (status) {
        case 2: return "warning"   // 面试
        case 4: return "success"   // 录用
        case 3: return "danger"    // 拒绝
        case 1: return ""          // 已看
        default: return "info"     // 待看
    }
}

onMounted(() => {
    // 如果挂载时已经有 ID 了，直接加载
    if (props.studentId) {
        loadDelivery(props.studentId)
    }
})
</script>

<style scoped>
.content-card {
    background: white;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

.delivery-timeline {
    margin-top: 20px;
}
</style>