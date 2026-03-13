<template>
    <div class="w-full flex justify-center py-8 bg-gray-50 min-h-screen">
        <div class="w-full max-w-5xl bg-white shadow-xl rounded-2xl p-8">

            <div class="flex gap-8 items-start">
                <div class="relative group">
                    <el-image :src="company.logo ? `http://localhost:9999${company.logo}` : defaultLogo"
                        class="w-44 h-44 object-cover rounded-2xl shadow-md border-4 border-white transition-transform group-hover:scale-105"
                        fit="cover" />
                </div>

                <div class="flex-1 pt-2">
                    <h2 class="text-4xl font-extrabold text-gray-800 mb-4">{{ company.name }}</h2>
                    <div class="grid grid-cols-2 gap-y-3">
                        <p class="text-gray-500 flex items-center text-base">
                            <el-icon class="mr-2 text-blue-500">
                                <OfficeBuilding />
                            </el-icon>
                            行业：{{ company.industry || "未填写" }}
                        </p>
                        <p class="text-gray-500 flex items-center text-base">
                            <el-icon class="mr-2 text-blue-500">
                                <UserFilled />
                            </el-icon>
                            规模：{{ company.scale || "未填写" }}
                        </p>
                        <p class="text-gray-500 flex items-center text-base col-span-2">
                            <el-icon class="mr-2 text-blue-500">
                                <Location />
                            </el-icon>
                            地址：{{ company.address || "未填写" }}
                        </p>
                    </div>
                </div>
            </div>

            <el-divider class="my-8" />

            <div class="mb-10">
                <h3 class="text-2xl font-bold mb-4 flex items-center">
                    <span class="w-2 h-7 bg-blue-600 rounded-full mr-3"></span>企业简介
                </h3>
                <p class="text-gray-600 leading-relaxed text-lg bg-gray-50 p-6 rounded-xl">
                    {{ company.description || "这家企业很神秘，暂无简介。" }}
                </p>
            </div>

            <div>
                <h3 class="text-2xl font-bold mb-6 flex items-center">
                    <span class="w-2 h-7 bg-blue-600 rounded-full mr-3"></span>在招岗位
                </h3>

                <el-empty v-if="jobs.length === 0" description="该企业暂未发布岗位" />

                <div v-for="job in jobs" :key="job.id"
                    class="p-6 mb-5 border-2 border-gray-100 rounded-2xl hover:border-blue-400 hover:shadow-lg transition-all bg-white">
                    <div class="flex justify-between items-center">
                        <div class="flex-1">
                            <div class="flex items-center gap-3 mb-2">
                                <h4 class="text-xl font-bold text-gray-800">{{ job.title }}</h4>
                                <el-tag size="small" effect="plain" type="success">热招</el-tag>
                            </div>
                            <div class="flex gap-6 text-gray-500 mb-3">
                                <span class="flex items-center"><el-icon class="mr-1">
                                        <Location />
                                    </el-icon>{{ job.location }}</span>
                                <span class="flex items-center font-bold text-orange-500 text-lg">
                                    {{ job.salaryMin }}k - {{ job.salaryMax }}k
                                </span>
                            </div>
                            <p class="text-gray-400 text-sm line-clamp-2">{{ job.description }}</p>
                        </div>
                        <el-button type="primary" size="large" round class="px-8 shadow-lg shadow-blue-200"
                            @click="handleApplyClick(job.id)">
                            申请职位
                        </el-button>
                    </div>
                </div>
            </div>
        </div>

        <el-dialog v-model="resumeDialogVisible" title="选择投递简历" width="480px" class="custom-dialog" align-center>
            <div v-if="resumes.length > 0" class="px-2">
                <p class="text-gray-500 text-sm mb-5">系统检测到您有多份简历，请选择最合适的一份：</p>

                <el-radio-group v-model="selectedResumeId" class="resume-radio-group">
                    <el-radio v-for="res in resumes" :key="res.id" :label="res.id" border class="resume-card-item">
                        <div class="flex items-center gap-4 py-1">
                            <div class="bg-blue-50 p-3 rounded-lg">
                                <el-icon class="text-blue-500 text-xl">
                                    <Document />
                                </el-icon>
                            </div>
                            <div class="flex flex-col">
                                <span class="font-bold text-gray-700 text-base mb-1">{{ res.title || '附件简历' }}</span>
                                <span class="text-xs text-gray-400">最后更新：{{ formatDateTime(res.updateTime) }}</span>
                            </div>
                        </div>
                    </el-radio>
                </el-radio-group>
            </div>

            <div v-else class="py-10 text-center">
                <el-empty description="简历库空空如也" :image-size="120" />
                <el-button type="primary" plain round @click="$router.push('/student/profile')">前往上传简历</el-button>
            </div>

            <template #footer>
                <div class="flex justify-center gap-4 pb-4">
                    <el-button @click="resumeDialogVisible = false" round class="px-6">取消</el-button>
                    <el-button type="primary" :disabled="!selectedResumeId" @click="submitApplication"
                        :loading="submitting" round class="px-8 shadow-md">
                        确认投递
                    </el-button>
                </div>
            </template>
        </el-dialog>
    </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import axios from "axios";
import { useRoute, useRouter } from "vue-router";
import { ElMessage } from "element-plus";
import { getToken } from '@/utils/auth';

const route = useRoute();
const router = useRouter();

// 基础数据
const company = ref({});
const jobs = ref([]);
const resumes = ref([]);
const studentId = ref(null);
const defaultLogo = "/images/default-logo.png";

// 交互状态
const resumeDialogVisible = ref(false);
const selectedResumeId = ref(null);
const currentJobId = ref(null);
const submitting = ref(false);

/**
 * 核心逻辑：格式化 ISO 时间字符串
 * 将 2026-03-12T16:49:26.000+00:00 转换为 2026-03-12 16:49
 */
const formatDateTime = (isoStr) => {
    if (!isoStr) return '—';
    const date = new Date(isoStr);
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    const hh = String(date.getHours()).padStart(2, '0');
    const mm = String(date.getMinutes()).padStart(2, '0');
    return `${y}-${m}-${d} ${hh}:${mm}`;
};

// 加载企业详情
const loadDetail = () => {
    axios.get(`/api/company/${route.params.id}`).then((res) => {
        if (res.data.code === "200") company.value = res.data.data;
    });
};

// 加载岗位列表
const loadJobs = () => {
    axios.get(`/api/job/company/${route.params.id}`).then((res) => {
        if (res.data.code === "200") jobs.value = res.data.data;
    });
};

// 加载动态学生 ID 与简历库
const loadStudentData = async () => {
    const token = getToken();
    if (!token) return;
    try {
        const profileRes = await axios.get('/api/student/profile', {
            headers: { 'Authorization': `Bearer ${token}` }
        });
        if (profileRes.data.code === "200") {
            studentId.value = profileRes.data.data.id;
            const resumeRes = await axios.get(`/api/resume/student/${studentId.value}`, {
                headers: { 'Authorization': `Bearer ${token}` }
            });
            if (resumeRes.data.code === "200") resumes.value = resumeRes.data.data;
        }
    } catch (err) {
        console.error("学生数据加载异常");
    }
};

const handleApplyClick = (jobId) => {
    if (!getToken()) {
        ElMessage.warning("请登录学生账号后操作");
        router.push('/login');
        return;
    }
    currentJobId.value = jobId;
    if (resumes.value.length > 0) {
        selectedResumeId.value = resumes.value[0].id;
        resumeDialogVisible.value = true;
    } else {
        ElMessage.warning("简历库为空，请先上传简历");
        router.push('/student/profile');
    }
};

const submitApplication = async () => {
    submitting.value = true;
    try {
        const res = await axios.post("/api/application/apply", {
            jobId: currentJobId.value,
            studentId: studentId.value,
            resumeId: selectedResumeId.value
        }, {
            headers: { 'Authorization': `Bearer ${getToken()}` }
        });

        if (res.data.code === "200") {
            ElMessage.success("投递成功！HR 将尽快查看您的简历");
            resumeDialogVisible.value = false;
        } else {
            ElMessage.error(res.data.msg || "投递失败");
        }
    } finally {
        submitting.value = false;
    }
};

onMounted(() => {
    loadDetail();
    loadJobs();
    loadStudentData();
});
</script>

<style scoped>
/* 简历列表单选框深度美化 */
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
    transition: all 0.2s ease;
    border-width: 1.5px !important;
}

.resume-card-item:hover {
    background-color: #f0f7ff;
    border-color: #409eff !important;
}

.resume-card-item.is-checked {
    background-color: #f0f7ff;
    border-color: #409eff !important;
    box-shadow: 0 4px 12px rgba(64, 158, 255, 0.15);
}

/* 隐藏原本的 el-radio 圈圈（可选，如果想用整块点击感） */
:deep(.el-radio__input) {
    display: flex;
    align-items: center;
}

:deep(.el-radio__label) {
    padding-left: 12px;
    flex: 1;
}

/* 调整 Dialog 圆角 */
:deep(.el-dialog) {
    border-radius: 16px !important;
    overflow: hidden;
}

:deep(.el-dialog__header) {
    padding-bottom: 20px;
    margin-right: 0;
    border-bottom: 1px solid #f0f0f0;
}

:deep(.el-dialog__title) {
    font-weight: bold;
    color: #303133;
}
</style>