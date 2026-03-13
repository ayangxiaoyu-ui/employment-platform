<template>
    <section class="content-card">
        <div class="flex justify-between items-center mb-6">
            <h3 class="text-xl font-bold">我的收藏</h3>
            <el-tag type="info" round>共 {{ favoriteList.length }} 个岗位</el-tag>
        </div>

        <div v-if="favoriteList.length > 0" class="favorite-list">
            <div v-for="job in favoriteList" :key="job.id"
                class="job-item flex justify-between items-center p-4 mb-4 border border-gray-100 rounded-xl hover:shadow-md transition-all">
                <div class="flex-1">
                    <div class="flex items-center gap-2 mb-2">
                        <span class="font-bold text-lg text-gray-800 cursor-pointer hover:text-blue-600"
                            @click="goToCompanyDetail(job.companyId)">
                            {{ job.title }}
                        </span>
                        <el-tag size="small" type="danger" plain>已收藏</el-tag>
                    </div>
                    <div class="text-sm text-gray-500 space-x-4">
                        <span>📍 {{ job.location }}</span>
                        <span class="text-orange-500 font-bold">{{ job.salaryMin }}k - {{ job.salaryMax }}k</span>
                    </div>
                </div>

                <div class="flex gap-3">
                    <el-button size="small" plain @click="cancelFavorite(job.id)">取消收藏</el-button>
                    <el-button size="small" type="primary" @click="goToCompanyDetail(job.companyId)">查看详情</el-button>
                </div>
            </div>
        </div>

        <el-empty v-else description="暂无收藏内容" :image-size="100" />
    </section>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue';
import axios from 'axios';
import { ElMessage, ElMessageBox } from 'element-plus';
import { useRouter } from 'vue-router';

// 1. 定义 Props 接收父组件传来的 studentId
const props = defineProps<{
    studentId: number | null
}>();

const router = useRouter();
const favoriteList = ref([]);

// 2. 加载收藏数据的方法
const loadFavorites = async () => {
    if (!props.studentId) return;

    try {
        const res = await axios.get(`/api/favorite/my/${props.studentId}`);
        if (res.data.code === "200") {
            favoriteList.value = res.data.data;
        }
    } catch (error) {
        console.error("加载收藏失败", error);
    }
};

// 3. 取消收藏逻辑
const cancelFavorite = (jobId: number) => {
    ElMessageBox.confirm('确定要移出收藏夹吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
    }).then(async () => {
        const res = await axios.post('/api/favorite/toggle', {
            studentId: props.studentId,
            jobId: jobId
        });
        if (res.data.code === "200") {
            ElMessage.success("已取消收藏");
            loadFavorites(); // 重新加载列表
        }
    });
};

// 跳转到企业详情页
const goToCompanyDetail = (companyId: number) => {
    router.push(`/company/${companyId}`);
};

// 4. 生命周期勾子
onMounted(() => {
    loadFavorites();
});

// 5. 监听 studentId 变化（防止父组件异步加载延迟）
watch(() => props.studentId, (newId) => {
    if (newId) loadFavorites();
});
</script>

<style scoped>
.content-card {
    background: white;
    border-radius: 12px;
    padding: 24px;
}

.job-item:hover {
    border-color: #409eff;
}
</style>