<template>
    <el-card class="latest-guide-card">
        <div class="header">
            <span class="icon">🎓</span>
            <h2 class="title">最新就业指导</h2>
        </div>

        <ul class="guide-list">
            <li v-for="item in guides" :key="item.id" class="guide-item" @click="openDetail(item.id)">
                <img :src="item.cover ? `http://localhost:9999${item.cover}` : defaultCover" class="cover" alt="封面" />

                <div class="info">
                    <h3 class="guide-title">{{ item.title }}</h3>
                    <p class="guide-desc">{{ item.description }}</p>

                    <span class="guide-time">{{ formatTime(item.createTime) }}</span>
                </div>
            </li>
        </ul>
    </el-card>
</template>

<script setup>
import { ref, onMounted } from "vue"
import axios from "axios"
import { useRouter } from "vue-router"

const router = useRouter()
const guides = ref([])

// 加载最新 5 条就业指导
const loadLatest = async () => {
    const res = await axios.get("/api/guide/latest")
    if (res.data.code === "200") {
        guides.value = res.data.data
    }
}

// 时间格式化
const formatTime = (time) => {
    const date = new Date(time)
    const y = date.getFullYear()
    const m = String(date.getMonth() + 1).padStart(2, "0")
    const d = String(date.getDate()).padStart(2, "0")
    return `${y}-${m}-${d}`
}

const openDetail = (id) => {
    router.push(`/guide/${id}`)
}

onMounted(loadLatest)
</script>

<style scoped>
.latest-guide-card {
    background-color: #ffffff !important;

    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
    padding: 20px 22px;
    border-radius: 12px;
}

.header {
    display: flex;
    align-items: center;
    margin-bottom: 14px;
}

.icon {
    font-size: 22px;
    margin-right: 6px;
}

.title {
    font-size: 20px;
    font-weight: 700;
    color: #333;
}

.guide-list {
    display: flex;
    flex-direction: column;
    gap: 14px;
}

.guide-item {
    display: flex;
    gap: 12px;
    cursor: pointer;
    padding: 8px;
    border-radius: 8px;
    transition: background-color 0.15s;
}

.guide-item:hover {
    background-color: #eef2f7;
}

.cover {
    width: 90px;
    height: 60px;
    border-radius: 6px;
    object-fit: cover;
}

.info {
    flex: 1;
    display: flex;
    flex-direction: column;
}

.guide-title {
    font-size: 16px;
    font-weight: 600;
    color: #1f6feb;
    margin-bottom: 4px;
}

.guide-desc {
    font-size: 13px;
    color: #666;
    margin-bottom: 6px;
}

.guide-time {
    font-size: 12px;
    color: #999;
}
</style>
