<template>
    <div class="w-[1000px] mx-auto py-6">

        <el-card>

            <!-- 标题 -->
            <h2 class="text-2xl font-bold mb-2">{{ news.title }}</h2>

            <!-- 时间 + 浏览量 -->
            <div class="text-gray-500 text-sm mb-4">
                发布时间：{{ formatTime(news.createTime) }} ｜ 浏览量：{{ news.viewCount }}
            </div>

            <!-- 内容（支持富文本） -->
            <div class="prose max-w-none leading-relaxed" v-html="news.content"></div>

        </el-card>

    </div>
</template>

<script setup>
import { ref, onMounted } from "vue"
import axios from "axios"
import { useRoute } from "vue-router"

const route = useRoute()
const news = ref({})

const loadDetail = async () => {
    const res = await axios.get(`/api/news/${route.params.id}`)
    if (res.data.code === "200") {
        news.value = res.data.data
    }
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
onMounted(loadDetail)
</script>
