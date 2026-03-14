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
                            @click="handleOpenDetail(job.id)">
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
                    <el-button size="small" type="primary" @click="handleOpenDetail(job.id)">查看详情</el-button>
                </div>
            </div>
        </div>

        <el-empty v-else description="暂无收藏内容" :image-size="100" />

        <JobDetailDialog v-if="props.studentId" ref="jobDetailRef" :student-id="props.studentId"
            :current-job-id="currentJobId" @apply="handleApplyFromDialog" @favorite-change="loadFavorites" />


        <el-dialog v-model="resumeDialogVisible" title="选择投递简历" width="480px" align-center>
            <div v-if="resumes.length > 0" class="px-2">
                <el-radio-group v-model="selectedResumeId" class="resume-radio-group">
                    <el-radio v-for="res in resumes" :key="res.id" :value="res.id" border class="resume-card-item">
                        <div class="flex items-center gap-4">
                            <el-icon class="text-blue-500 text-xl">
                                <Document />
                            </el-icon>
                            <span>{{ res.title || '我的简历' }}</span>
                        </div>
                    </el-radio>
                </el-radio-group>
            </div>
            <template #footer>
                <div class="flex justify-center gap-4 pb-4">
                    <el-button @click="resumeDialogVisible = false" round>取消</el-button>
                    <el-button type="primary" :disabled="!selectedResumeId" @click="submitApplication"
                        :loading="submitting" round>
                        确认投递
                    </el-button>
                </div>
            </template>
        </el-dialog>
    </section>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue';
import axios from 'axios';
import { ElMessage, ElMessageBox } from 'element-plus';
import { Document } from '@element-plus/icons-vue';
import { getToken } from '@/utils/auth';

// 引入子组件
import JobDetailDialog from '@/components/StudentProfile/JobDetailDialog.vue';

const props = defineProps<{
    studentId: number | string | null
}>();

const favoriteList = ref([]);
const jobDetailRef = ref();
const resumes = ref([]);
const resumeDialogVisible = ref(false);
const selectedResumeId = ref(null);
const currentJobId = ref<number | null>(null);
const submitting = ref(false);

// 打开详情
const handleOpenDetail = (id: number) => {
    jobDetailRef.value?.open(id);
};

// 响应弹窗里的投递按钮 (修正了方法名)
const handleApplyFromDialog = async (jobId: number) => {
    currentJobId.value = jobId;
    try {
        const res = await axios.get(`/api/resume/student/${props.studentId}`, {
            headers: { 'Authorization': `Bearer ${getToken()}` }
        });
        if (res.data.code === "200") {
            resumes.value = res.data.data;
            if (resumes.value.length > 0) {
                selectedResumeId.value = resumes.value[0].id;
                resumeDialogVisible.value = true;
            } else {
                ElMessage.warning("请先上传简历");
            }
        }
    } catch (err) {
        ElMessage.error("获取简历失败");
    }
};

// 提交申请
const submitApplication = async () => {
    submitting.value = true;
    try {
        const res = await axios.post("/api/application/apply", {
            jobId: currentJobId.value,
            studentId: props.studentId,
            resumeId: selectedResumeId.value
        }, { headers: { 'Authorization': `Bearer ${getToken()}` } });

        if (res.data.code === "200") {
            ElMessage.success("投递成功！");
            resumeDialogVisible.value = false;
        }
    } finally {
        submitting.value = false;
    }
};

// 加载收藏列表
const loadFavorites = async () => {
    if (!props.studentId) return;
    const res = await axios.get(`/api/favorite/my/${props.studentId}`);
    if (res.data.code === "200") {
        favoriteList.value = res.data.data;
    }
};

// 取消收藏
const cancelFavorite = (jobId: number) => {
    ElMessageBox.confirm('确定取消收藏吗？', '提示', { type: 'warning' }).then(async () => {
        const res = await axios.post('/api/favorite/toggle', {
            studentId: props.studentId,
            jobId
        });
        if (res.data.code === "200") {
            ElMessage.success("已取消");
            loadFavorites();
        }
    });
};

onMounted(() => loadFavorites());
watch(() => props.studentId, (newId) => { if (newId) loadFavorites(); });
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

.resume-radio-group {
    width: 100%;
    display: flex;
    flex-direction: column;
    gap: 10px;
}

.resume-card-item {
    width: 100% !important;
    margin-right: 0 !important;
    height: auto !important;
    padding: 12px !important;
}
</style>