<script setup>
import { ref, onMounted } from "vue";
import axios from "axios";

const companies = ref([]);
const defaultLogo = "/images/default-logo.png";

const loadCompanies = () => {
    axios.get("/api/company/list").then(res => {
        if (res.data.code == 200) {
            companies.value = res.data.data;
        }
    });
};

onMounted(() => {
    loadCompanies();
});
</script>

<template>
    <div class="company-list">
        <div class="company-container">
            <div class="company-card" v-for="item in companies" :key="item.id">
                <img :src="`http://localhost:9999${item.logo}`" class="logo" width="100%" height="150" />
                <h3>{{ item.name || '未命名企业' }}</h3>
                <p>行业：{{ item.industry || '未填写' }}</p>
                <p>规模：{{ item.scale || '未填写' }}</p>
                <p>地址：{{ item.address || '未填写' }}</p>
            </div>
        </div>
    </div>
</template>



<style>
.company-container {
    display: flex;
    flex-wrap: wrap;
    gap: 20px;
}

.company-card {
    width: 260px;
    padding: 15px;
    border: 1px solid #eee;
    border-radius: 8px;
}

.logo {
    width: 100%;
    height: 150px;
    object-fit: center;
}
</style>
