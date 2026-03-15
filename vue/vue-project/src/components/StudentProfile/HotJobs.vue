<template>
    <section class="hot-card">
        <el-table :data="jobs" class="job-table" header-cell-class-name="table-header">
            <!-- 职位 -->
            <el-table-column label="职位" width="320">
                <template #default="scope">
                    <div class="job-title" @click="$emit('open-detail', scope.row.id)">
                        <el-icon>
                            <HotWater />
                        </el-icon>

                        <span>{{ scope.row.title }}</span>
                    </div>
                </template>
            </el-table-column>

            <!-- 浏览量 -->
            <el-table-column label="热度" width="120">
                <template #default="scope">
                    <el-tag type="danger" effect="light">
                        {{ scope.row.viewCount }} 次
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
import { HotWater } from '@element-plus/icons-vue'

const jobs = ref([])

const load = async () => {
    const res = await axios.get('/api/job/hot')
    if (res.data.code === "200") {
        jobs.value = res.data.data
    }
}

const formatTime = t => t.replace("T", " ").substring(0, 19)

onMounted(load)
</script>

<style scoped>
/* 外层卡片 */
.hot-card {
    background: #ffffff;
    border-radius: 14px;
    padding: 0px 26px;
    box-shadow: 0 6px 18px rgba(0, 0, 0, 0.06);
    transition: 0.3s ease;
}

.hot-card:hover {
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

/* 表头 */
.table-header {
    background: #f8fafc !important;
    color: #475569 !important;
    font-weight: 600 !important;
}

/* 表格行 hover */
.job-table :deep(.el-table__row:hover) {
    background-color: #f1f5f9 !important;
}

/* 职位标题 */
.job-title {
    display: flex;
    align-items: center;
    gap: 6px;
    color: #e11d48;
    font-weight: 600;
    cursor: pointer;
    transition: 0.2s;
}

.job-title:hover {
    color: #be123c;
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
