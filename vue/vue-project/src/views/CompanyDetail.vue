<template>
    <div class="detail-page">
        <el-card class="detail-card">
            <div class="header">
                <img :src="company.logo ? `http://localhost:9999${company.logo}` : defaultLogo" class="logo" />
                <div class="info">
                    <h2 class="name">{{ company.name }}</h2>
                    <p class="sub">所属行业：{{ company.industry || '未填写' }}</p>
                    <p class="sub">人员规模：{{ company.scale || '未填写' }}</p>
                    <p class="sub">地址：{{ company.address || '未填写' }}</p>
                </div>
            </div>

            <el-divider />

            <div class="desc">
                <h3>企业简介</h3>
                <p>{{ company.description || '暂无简介' }}</p>
            </div>
        </el-card>
    </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import axios from "axios";
import { useRoute } from "vue-router";

const route = useRoute();
const company = ref({});
const defaultLogo = "/images/default-logo.png";

const loadDetail = () => {
    axios.get(`/api/company/${route.params.id}`).then((res) => {
        if (res.data.code === "200") {
            company.value = res.data.data;
            l
        }
    });
};

onMounted(() => {
    loadDetail();
});
</script>

<style scoped>
.detail-page {
    padding: 20px;
    display: flex;
    justify-content: center;
}

.detail-card {
    width: 800px;
    padding: 20px;
    border-radius: 12px;
}

.header {
    display: flex;
    gap: 20px;
}

.logo {
    width: 160px;
    height: 160px;
    object-fit: cover;
    border-radius: 12px;
}

.info {
    flex: 1;
}

.name {
    font-size: 28px;
    font-weight: bold;
    margin-bottom: 10px;
}

.sub {
    font-size: 16px;
    color: #666;
    margin: 4px 0;
}

.desc {
    margin-top: 20px;
}

.desc h3 {
    margin-bottom: 10px;
}
</style>
