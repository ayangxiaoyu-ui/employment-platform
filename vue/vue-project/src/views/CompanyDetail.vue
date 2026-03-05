<template>
    <div class="w-full flex justify-center py-6">
        <div class="w-full max-w-5xl bg-white shadow-lg rounded-xl p-6">

            <!-- 企业头部 -->
            <div class="flex gap-6">
                <img :src="company.logo ? `http://localhost:9999${company.logo}` : defaultLogo"
                    class="w-40 h-40 object-cover rounded-xl shadow" />

                <div class="flex-1">
                    <h2 class="text-3xl font-bold mb-2">{{ company.name }}</h2>

                    <p class="text-gray-600 mb-1">所属行业：{{ company.industry || "未填写" }}</p>
                    <p class="text-gray-600 mb-1">人员规模：{{ company.scale || "未填写" }}</p>
                    <p class="text-gray-600 mb-1">地址：{{ company.address || "未填写" }}</p>
                </div>
            </div>

            <el-divider />

            <!-- 企业简介 -->
            <div class="mt-4">
                <h3 class="text-xl font-semibold mb-2">企业简介</h3>
                <p class="text-gray-700 leading-relaxed">
                    {{ company.description || "暂无简介" }}
                </p>
            </div>

            <el-divider />

            <!-- 岗位列表 -->
            <div class="mt-4">
                <h3 class="text-xl font-semibold mb-4">招聘岗位</h3>

                <el-empty v-if="jobs.length === 0" description="该企业暂未发布岗位" />

                <div v-for="job in jobs" :key="job.id"
                    class="p-5 mb-4 border rounded-xl shadow-sm hover:shadow-md transition">

                    <h4 class="text-lg font-bold mb-2">{{ job.title }}</h4>

                    <p class="text-gray-600 mb-1">📍 工作地点：{{ job.location }}</p>
                    <p class="text-gray-600 mb-1">💰 薪资范围：{{ job.salaryMin }}k - {{ job.salaryMax }}k</p>

                    <p class="text-gray-700 mt-2 leading-relaxed">
                        {{ job.description }}
                    </p>
                </div>
            </div>

        </div>
    </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import axios from "axios";
import { useRoute } from "vue-router";

const route = useRoute();
const company = ref({});
const jobs = ref([]);
const defaultLogo = "/images/default-logo.png";

// 加载企业详情
const loadDetail = () => {
    axios.get(`/api/company/${route.params.id}`).then((res) => {
        if (res.data.code === "200") {
            company.value = res.data.data;
        }
    });
};

// 加载岗位列表
const loadJobs = () => {
    axios.get(`/api/job/company/${route.params.id}`).then((res) => {
        if (res.data.code === "200") {
            jobs.value = res.data.data;
        }
    });
};

onMounted(() => {
    loadDetail();
    loadJobs();
});
</script>

<style scoped>
/* 如果你希望 Tailwind + Element Plus 更协调，可以在这里补充一些微调 */
</style>
