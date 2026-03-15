<template>
    <div class="guide-detail">
        <div class="header">
            <h1 class="title">{{ detail.title }}</h1>
            <p class="meta">发布时间：{{ format(detail.createTime) }} · 阅读 {{ detail.viewCount }}</p>
        </div>

        <el-card class="content-card">
            <div class="content" v-html="detail.content"></div>
        </el-card>
    </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import axios from "axios";
import { useRoute } from "vue-router";

const route = useRoute();
const detail = ref({});

const format = (t) => t?.slice(0, 10);

onMounted(async () => {
    const res = await axios.get(`/api/guide/${route.params.id}`);
    detail.value = res.data.data;
});
</script>

<style scoped>
.guide-detail {
    width: 900px;
    margin: 0 auto;
    padding: 30px 0;
}

/* 标题区域 */
.header {
    margin-bottom: 25px;
    text-align: center;
}

.title {
    font-size: 30px;
    font-weight: 700;
    margin-bottom: 10px;
    line-height: 1.4;
}

.meta {
    color: #888;
    font-size: 14px;
}

/* 内容卡片 */
.content-card {
    padding: 30px;
    border-radius: 14px;
}

/* 富文本内容美化 */
.content :deep(h2) {
    font-size: 22px;
    margin: 25px 0 15px;
    font-weight: 600;
}

.content :deep(h3) {
    font-size: 18px;
    margin: 20px 0 10px;
    font-weight: 600;
}

.content :deep(p) {
    line-height: 1.8;
    margin-bottom: 14px;
    font-size: 16px;
    color: #444;
}

.content :deep(ul),
.content :deep(ol) {
    padding-left: 22px;
    margin-bottom: 14px;
}

.content :deep(li) {
    margin-bottom: 6px;
    line-height: 1.7;
}

.content :deep(table) {
    width: 100%;
    border-collapse: collapse;
    margin: 20px 0;
}

.content :deep(th),
.content :deep(td) {
    border: 1px solid #ddd;
    padding: 10px;
}

.content :deep(th) {
    background: #f7f7f7;
    font-weight: 600;
}

.content :deep(blockquote) {
    border-left: 4px solid #409eff;
    padding-left: 12px;
    color: #555;
    margin: 15px 0;
    font-style: italic;
}
</style>
