<template>
    <el-card class="latest-news-card">
        <div class="header">
            <span class="icon">📢</span>
            <h2 class="title">最新公告</h2>
        </div>

        <ul class="news-list">
            <li v-for="item in latestNews" :key="item.id" class="news-item" @click="openDetail(item.id)">
                <div class="dot"></div>

                <div class="content">
                    <span class="news-title">{{ item.title }}</span>
                    <span class="news-time">{{ formatDate(item.createTime) }}</span>
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
const latestNews = ref([])

const loadLatestNews = async () => {
    const res = await axios.get("/api/news/latest")
    if (res.data.code === "200") {
        latestNews.value = res.data.data
    }
}

const openDetail = (id) => {
    router.push(`/news/${id}`)
}

const formatDate = (time) => {
    const date = new Date(time)
    const y = date.getFullYear()
    const m = String(date.getMonth() + 1).padStart(2, "0")
    const d = String(date.getDate()).padStart(2, "0")
    return `${y}-${m}-${d}`
}

onMounted(loadLatestNews)
</script>

<style scoped>
.latest-news-card {
    background-color: #ffffff !important;

    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
    padding: 20px 22px;
    border-radius: 12px;
}

/* 标题区 */
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

/* 列表 */
.news-list {
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.news-item {
    display: flex;
    align-items: center;
    cursor: pointer;
    padding: 6px 4px;
    border-radius: 6px;
    transition: background-color 0.15s;
}

.news-item:hover {
    background-color: #ffffff;
    /* 柔和 hover */
}

.dot {
    width: 6px;
    height: 6px;
    background-color: #409eff;
    border-radius: 50%;
    margin-right: 10px;
}

.content {
    display: flex;
    justify-content: space-between;
    width: 100%;
}

.news-title {
    color: #1f6feb;
    font-size: 15px;
    font-weight: 500;
}

.news-title:hover {
    text-decoration: underline;
}

.news-time {
    color: #999;
    font-size: 13px;
}
</style>
