<template>
    <section class="latest-card">
        <el-table :data="jobs" style="width: 100%" class="job-table" header-cell-class-name="table-header"
            row-class-name="table-row">
            <!-- 职位 -->
            <el-table-column label="职位" width="320">
                <template #default="scope">
                    <div class="job-title" @click="$emit('open-detail', scope.row.id)">
                        <el-icon>
                            <Promotion />
                        </el-icon>
                        <span>{{ scope.row.title }}</span>
                    </div>
                </template>
            </el-table-column>

            <!-- 薪资 -->
            <el-table-column label="薪资" width="160">
                <template #default="scope">
                    <el-tag type="success" effect="light">
                        {{ scope.row.salaryMin }}k - {{ scope.row.salaryMax }}k
                    </el-tag>
                </template>
            </el-table-column>

            <!-- 地点 -->
            <el-table-column label="地点" width="140">
                <template #default="scope">
                    <span class="location">{{ scope.row.location }}</span>
                </template>
            </el-table-column>

            <!-- 发布时间 -->
            <el-table-column label="发布时间" width="200">
                <template #default="scope">
                    <span class="time">{{ formatTime(scope.row.createTime) }}</span>
                </template>
            </el-table-column>
        </el-table>
    </section>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { Promotion } from '@element-plus/icons-vue'

const jobs = ref([])

const load = async () => {
    const res = await axios.get('/api/job/latest')
    if (res.data.code === "200") {
        jobs.value = res.data.data
    }
}

const formatTime = t => t.replace("T", " ").substring(0, 19)

onMounted(load)
</script>

<style scoped>
/* 外层卡片 */
.latest-card {
    background: #ffffff;
    border-radius: 14px;
    padding: 0 26px;
    box-shadow: 0 6px 18px rgba(0, 0, 0, 0.06);
    transition: 0.3s ease;
}

.latest-card:hover {
    box-shadow: 0 8px 22px rgba(0, 0, 0, 0.08);
}

/* 标题 */
.header h3 {
    font-size: 20px;
    font-weight: 700;
    color: #333;
    margin-bottom: 18px;
    display: flex;
    align-items: center;
    gap: 6px;
}

/* 表格头 */
.table-header {
    background: #f8fafc !important;
    color: #475569 !important;
    font-weight: 600 !important;
}

/* 表格行 hover 效果 */
.job-table :deep(.el-table__row:hover) {
    background-color: #f1f5f9 !important;
}

/* 职位标题 */
.job-title {
    display: flex;
    align-items: center;
    gap: 6px;
    color: #2563eb;
    font-weight: 600;
    cursor: pointer;
    transition: 0.2s;
}

.job-title:hover {
    color: #1d4ed8;
    transform: translateX(2px);
}

/* 地点 */
.location {
    color: #475569;
}

/* 发布时间 */
.time {
    color: #94a3b8;
    font-size: 13px;
}
</style>
