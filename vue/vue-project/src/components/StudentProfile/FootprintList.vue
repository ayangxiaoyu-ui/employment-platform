<template>
    <section class="content-card">
        <h3 class="text-xl font-bold mb-4">我的足迹</h3>

        <el-table :data="list" style="width: 100%">
            <el-table-column label="职位" width="300">
                <template #default="scope">
                    <div class="cursor-pointer text-blue-600" @click="$emit('open-detail', scope.row.job.id)">
                        {{ scope.row.job.title }}
                    </div>
                </template>
            </el-table-column>

            <el-table-column label="公司" prop="companyName" />

            <el-table-column label="浏览次数" width="120">
                <template #default="scope">
                    {{ scope.row.count }} 次
                </template>
            </el-table-column>

            <el-table-column label="最后浏览时间" width="180">
                <template #default="scope">
                    {{ formatTime(scope.row.updateTime) }}
                </template>
            </el-table-column>
        </el-table>
    </section>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

const props = defineProps({
    studentId: Number
})

const list = ref([])

const load = async () => {
    const res = await axios.get(`/api/browsing/${props.studentId}`)
    if (res.data.code === "200") {
        list.value = res.data.data
    }
}

const formatTime = (t) => t.replace("T", " ").substring(0, 19)

onMounted(load)
</script>

<style scoped>
.content-card {
    background: white;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}
</style>
