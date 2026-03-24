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

    <el-dialog v-model="resumeDialogVisible" title="选择投递简历" width="480px" align-center>
        <div v-if="resumes.length > 0" class="px-2">
            <p class="text-gray-500 text-sm mb-5">请选择一份简历完成申请：</p>
            <el-radio-group v-model="selectedResumeId" class="resume-radio-group">
                <el-radio v-for="res in resumes" :key="res.id" :value="res.id" border class="resume-card-item">
                    <div class="flex items-center gap-4 py-1">
                        <div class="bg-blue-50 p-3 rounded-lg">
                            <el-icon class="text-blue-500 text-xl">
                                <Document />
                            </el-icon>
                        </div>
                        <div class="flex flex-col">
                            <span class="font-bold text-gray-700 mb-1">{{ res.title || '我的简历' }}</span>
                            <span class="text-xs text-gray-400">最后更新：{{ formatDateTime(res.updateTime) }}</span>
                        </div>
                    </div>
                </el-radio>
            </el-radio-group>
        </div>
        <div v-else class="py-10 text-center">
            <el-empty description="简历库为空" :image-size="100" />
        </div>
        <template #footer>
            <div class="flex justify-center gap-4 pb-4">
                <el-button @click="resumeDialogVisible = false" round>取消</el-button>
                <el-button type="primary" :disabled="!selectedResumeId" @click="submitApplication" :loading="submitting"
                    round class="px-8">
                    确认投递
                </el-button>
            </div>
        </template>
    </el-dialog>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import axios from 'axios';
import { ElMessage, ElMessageBox } from 'element-plus';
import { Star, StarFilled, Document } from '@element-plus/icons-vue';
import { getToken } from '@/utils/auth';

const props = defineProps<{
    studentId: number | string | null,
    currentJobId: number | string | null
}>();

const visible = ref(false);
const job = ref<any>(null);
const loading = ref(false);
const isFavorited = ref(false);
const resumes = ref<any[]>([]);
const selectedResumeId = ref<number | null>(null);
const resumeDialogVisible = ref(false);
const submitting = ref(false);

// 暴露给父组件的方法
const open = async (jobId: number) => {
    visible.value = true;
    loading.value = true;
    isFavorited.value = false;

    // ⭐ 在这里记录足迹（正确位置）
    if (props.studentId && jobId) {
        axios.post("/api/browsing/record", null, {
            params: {
                studentId: props.studentId,
                jobId: jobId
            }
        })
    }

    try {
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
const formatDateTime = (dateStr?: string) => {
    if (!dateStr) return '';
    return String(dateStr).replace('T', ' ').slice(0, 16);
};

const emit = defineEmits(['apply', 'favorite-change']);
const handleApply = () => {
    if (!getToken()) {
        ElMessage.warning("请先登录学生账号");
        return;
    }
    if (!props.studentId) {
        ElMessage.warning("未获取到学生信息，请重新登录");
        return;
    }
    if (!job.value?.id) {
        ElMessage.warning("岗位信息异常，无法投递");
        return;
    }
    openResumeDialog();
};

const openResumeDialog = async () => {
    try {
        const res = await axios.get(`/api/resume/student/${props.studentId}`, {
            headers: { Authorization: `Bearer ${getToken()}` },
        });
        if (res.data.code !== "200") {
            ElMessage.error(res.data.msg || "获取简历失败");
            return;
        }
        resumes.value = res.data.data || [];
        if (resumes.value.length === 0) {
            ElMessage.warning("请先上传简历");
            return;
        }
        selectedResumeId.value = resumes.value[0].id;
        resumeDialogVisible.value = true;
    } catch {
        ElMessage.error("获取简历失败");
    }
};

const handleApplyResponse = (data: any) => {
    if (data?.msg && String(data.msg).includes("投递过")) {
        ElMessageBox.alert(
            "你已经投递过该职位，请选择其他职位或更换简历后再尝试。",
            "重复投递提示",
            { confirmButtonText: "我知道了", type: "warning" }
        );
        return;
    }
    if (data?.code === "200") {
        ElMessage.success("投递成功！");
        resumeDialogVisible.value = false;
        visible.value = false;
        emit('apply', job.value.id);
        return;
    }
    ElMessage.error(data?.msg || "投递失败，请重试");
};

const submitApplication = async () => {
    if (!selectedResumeId.value) {
        ElMessage.warning("请选择简历");
        return;
    }
    submitting.value = true;
    try {
        const res = await axios.post("/api/application/apply", {
            jobId: job.value.id,
            studentId: props.studentId,
            resumeId: selectedResumeId.value,
        }, {
            headers: { Authorization: `Bearer ${getToken()}` },
        });
        handleApplyResponse(res.data);
    } catch (e: any) {
        handleApplyResponse(e?.response?.data);
    } finally {
        submitting.value = false;
    }
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

.resume-radio-group {
    width: 100%;
    display: flex;
    flex-direction: column;
    gap: 12px;
}

.resume-card-item {
    width: 100% !important;
    height: auto !important;
    margin-right: 0 !important;
    padding: 12px 16px !important;
    border-radius: 12px !important;
}
</style>