<template>
    <div class="guide-list">
        <el-card>
            <h2 class="text-2xl font-bold mb-4"> 就业指导</h2>
            <el-row :gutter="20">
                <el-col :span="8" v-for="item in list" :key="item.id">
                    <el-card class="guide-card" @click="goDetail(item.id)">

                        <!-- 封面图 -->
                        <img :src="`http://localhost:9999${item.cover}`" class="cover" alt="cover" />

                        <h3>{{ item.title }}</h3>

                        <p class="desc">{{ item.description }}</p>

                        <p class="time">发布时间：{{ format(item.createTime) }}</p>
                    </el-card>
                </el-col>
            </el-row>
        </el-card>
    </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import axios from "axios";
import { useRouter } from "vue-router";

const router = useRouter();
const list = ref([]);

const format = (t) => t?.slice(0, 10);

onMounted(async () => {
    const res = await axios.get("/api/guide/list");
    list.value = res.data.data;   // 注意这里是 data.data
});

const goDetail = (id) => {
    router.push(`/guide/${id}`);
};
</script>

<style scoped>
.cover {
    width: 100%;
    height: 150px;
    object-fit: cover;
    border-radius: 6px;
}

.desc {
    color: #666;
    font-size: 14px;
    margin: 6px 0;
}

.time {
    font-size: 12px;
    color: #999;
}

.guide-card {
    cursor: pointer;
    margin-bottom: 20px;
    transition: box-shadow 0.3s;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
    border-radius: 8px;
}

.guide-card:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.guide-list {
    background-color: #f5f7fa;
    /* 浅灰背景，和 Element Plus 默认一致 */
    padding: 30px;
    border-radius: 12px;
}
</style>
