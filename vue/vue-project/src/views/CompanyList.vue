<template>
    <div class="company-page">
        <h2 class="title">企业列表</h2>
        <el-row :gutter="20">
            <el-col v-for="item in companies" :key="item.id" :xs="24" :sm="12" :md="8" :lg="6">
                <el-card shadow="hover" class="company-card" @click="$router.push('/company/' + item.id)">
                    <div class="logo">
                        <img :src="item.logo ? `http://localhost:9999${item.logo}` : defaultLogo" class="company-logo"
                            alt="logo" />
                    </div>
                    <div class="company-info">
                        <h3 class="company-name">{{ item.name || "未命名企业" }}</h3>

                        <p class="info-item">
                            <el-icon>
                                <OfficeBuilding />
                            </el-icon>
                            {{ item.industry || "未填写" }}
                        </p>

                        <p class="info-item">
                            <el-icon>
                                <UserFilled />
                            </el-icon>
                            {{ item.scale || "未填写" }}
                        </p>

                        <p class="info-item">
                            <el-icon>
                                <Location />
                            </el-icon>
                            {{ item.address || "未填写" }}
                        </p>
                    </div>
                </el-card>
            </el-col>
        </el-row>
    </div>
</template>

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




<style scoped>
.company-page {
    padding: 20px;
}

.title {
    margin-bottom: 20px;
    font-size: 26px;
    font-weight: bold;
}

.company-card {
    border-radius: 12px;
    overflow: hidden;
    transition: transform 0.2s;
    min-height: 320px;
    display: flex;
    flex-direction: column;
    margin-bottom: 20px;
    cursor: pointer;
}

.company-card:hover {
    transform: translateY(-5px);
}


.logo {
    width: 100%;
    display: flex;
    justify-content: center;
}

.company-logo {
    width: 100px;
    height: 100px;
    object-fit: cover;
    border-radius: 8px;
    border-bottom: 1px solid #f0f0f0;
    display: block;
}

.company-info {
    padding: 12px;
    flex: 1;
    display: flex;
    flex-direction: column;
}

.company-name {
    font-size: 20px;
    font-weight: bold;
    margin-bottom: 10px;

    white-space: nowrap;
    /* 不换行 */
    overflow: hidden;
    /* 超出隐藏 */
    text-overflow: ellipsis;
    /* 超出显示省略号 */
}


.info-item {
    display: flex;
    align-items: center;
    color: #666;
    margin: 4px 0;

    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}


.info-item el-icon {
    margin-right: 6px;
}
</style>
