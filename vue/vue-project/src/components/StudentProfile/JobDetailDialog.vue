<template>
    <el-dialog v-model="visible" title="岗位详情" width="650px" align-center destroy-on-close class="detail-dialog">
        <div v-if="loading" class="py-10" v-loading="true"></div>
        <div v-else-if="job" class="p-2">
            <div class="flex justify-between items-start mb-6">
                <div>
                    <h3 class="text-2xl font-bold text-gray-800 mb-2 flex items-center gap-3">
                        {{ job.title }}
                        <el-tooltip :content="isFavorited ? '取消收藏' : '加入收藏'" placement="top">
                            <el-icon @click="handleFavoriteToggle" class="cursor-pointer transition-all hover:scale-125"
                                :class="isFavorited ? 'favorited-icon' : 'unfavorited-icon'">
                                <StarFilled v-if="isFavorited" />
                                <Star v-else />
                            </el-icon>
                        </el-tooltip>
                    </h3>
                    <p class="text-blue-600 font-medium">📍 {{ job.location }} | 💰 {{ job.salaryMin }}k - {{
                        job.salaryMax }}k</p>
                </div>
                <el-tag type="info" plain>{{ formatDate(job.createTime) }} 发布</el-tag>
            </div>

            <div class="space-y-6">
                <section>
                    <h4 class="font-bold text-gray-700 mb-2 border-l-4 border-blue-500 pl-2">职位描述</h4>
                    <div class="bg-gray-50 p-4 rounded-lg text-gray-600 leading-relaxed whitespace-pre-line">
                        {{ job.description || '暂无详细描述' }}
                    </div>
                </section>
                <section>
                    <h4 class="font-bold text-gray-700 mb-2 border-l-4 border-blue-500 pl-2">任职要求</h4>
                    <div class="bg-gray-50 p-4 rounded-lg text-gray-600 leading-relaxed whitespace-pre-line">
                        {{ job.requirements || '暂无要求说明' }}
                    </div>
                </section>
            </div>
        </div>

        <template #footer>
            <div class="flex justify-end gap-3 px-2 pb-2">
                <el-button @click="visible = false" round>关闭</el-button>
                <el-button type="primary" round class="px-8" @click="handleApply">立即投递</el-button>
            </div>
        </template>
    </el-dialog>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import axios from 'axios';
import { ElMessage } from 'element-plus';
import { Star, StarFilled } from '@element-plus/icons-vue';
import { getToken } from '@/utils/auth';

const props = defineProps<{
    studentId: number | string | null
}>();

const visible = ref(false);
const job = ref<any>(null);
const loading = ref(false);
const isFavorited = ref(false);

// 暴露给父组件的方法
const open = async (jobId: number) => {
    visible.value = true;
    loading.value = true;
    isFavorited.value = false; // 重置状态

    try {
        // 1. 并发请求：获取详情 + 检查收藏状态
        const [detailRes, statusRes] = await Promise.all([
            axios.get(`/api/job/${jobId}`),
            props.studentId ? axios.get('/api/favorite/status', {
                params: { studentId: props.studentId, jobId: jobId }
            }) : Promise.resolve({ data: { data: false } })
        ]);

        if (detailRes.data.code === "200") {
            job.value = detailRes.data.data;
        }
        if (statusRes.data.code === "200") {
            isFavorited.value = statusRes.data.data;
        }
    } catch (err) {
        ElMessage.error("获取数据失败");
    } finally {
        loading.value = false;
    }
};

// 切换收藏
const handleFavoriteToggle = async () => {
    if (!getToken()) return ElMessage.warning("请先登录");

    try {
        const res = await axios.post('/api/favorite/toggle', {
            studentId: props.studentId,
            jobId: job.value.id
        });
        if (res.data.code === "200") {
            isFavorited.value = res.data.data;
            isFavorited.value ? ElMessage.success("收藏成功") : ElMessage.info("已取消收藏");
            // 通知父组件（如果是收藏列表页，可能需要刷新列表）
            emit('favorite-change', isFavorited.value);
        }
    } catch (err) {
        ElMessage.error("操作失败");
    }
};

const formatDate = (dateStr: string) => dateStr ? dateStr.split('T')[0] : '';

const emit = defineEmits(['apply', 'favorite-change']);
const handleApply = () => {
    emit('apply', job.value.id);
};

defineExpose({ open });
</script>

<style scoped>
.favorited-icon {
    color: #facc15 !important;
}

.unfavorited-icon {
    color: #d1d5db !important;
}

:deep(.el-dialog) {
    border-radius: 16px !important;
}
</style>