<template>
    <section class="content-card">
        <h3>投递动态</h3>
        <div class="delivery-timeline">
            <el-table :data="deliveryData" style="width: 100%">
                <el-table-column prop="company" label="公司" />
                <el-table-column prop="position" label="岗位" />
                <el-table-column label="当前状态">
                    <template #default="scope">
                        <el-tag :type="getStatusType(scope.row.status)">{{ scope.row.status }}</el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="date" label="投递日期" />
            </el-table>
        </div>
    </section>
</template>

<script setup lang="ts">
import { ref } from 'vue'

interface DeliveryRecord {
    company: string
    position: string
    status: string
    date: string
}

const deliveryData = ref<DeliveryRecord[]>([
    { company: '腾讯', position: '前端开发工程师', status: '面试中', date: '2024-03-01' },
    { company: '阿里巴巴', position: 'Java实习生', status: '简历筛选', date: '2024-03-05' }
])

const getStatusType = (status: string) => {
    if (status === '面试中') return 'warning'
    if (status === '录用') return 'success'
    return 'info'
}
</script>

<style scoped>
.content-card {
    background: white;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}
</style>
