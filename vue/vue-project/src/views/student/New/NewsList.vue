<template>
    <div class="w-[1000px] mx-auto py-6">

        <h2 class="text-2xl font-bold mb-4">📢 公告通知</h2>

        <el-card v-for="item in newsList" :key="item.id" class="mb-4 cursor-pointer hover:shadow-md transition"
            @click="openDetail(item.id)">
            <div class="flex flex-col gap-1">
                <h3 class="text-lg font-semibold text-gray-800">
                    {{ item.title }}
                </h3>

                <div class="text-gray-500 text-sm flex gap-4">
                    <span>发布时间：{{ formatTime(item.createTime) }}</span>
                    <span>浏览量：{{ item.viewCount }}</span>
                </div>
            </div>
        </el-card>

    </div>
</template>

<script setup>
import { ref, onMounted } from "vue"
import axios from "axios"
import { useRouter } from "vue-router"

const router = useRouter()
const newsList = ref([])

const loadNews = async () => {
    const res = await axios.get("/api/news/list")
    if (res.data.code === "200") {
        newsList.value = res.data.data
    }
}

const openDetail = (id) => {
    router.push(`/news/${id}`)
}
const formatTime = (time) => {
    if (!time) return ""
    const date = new Date(time)
    const y = date.getFullYear()
    const m = String(date.getMonth() + 1).padStart(2, "0")
    const d = String(date.getDate()).padStart(2, "0")
    const hh = String(date.getHours()).padStart(2, "0")
    const mm = String(date.getMinutes()).padStart(2, "0")
    return `${y}-${m}-${d} ${hh}:${mm}`
}

onMounted(loadNews)
</script>

<style scoped></style>
