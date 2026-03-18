<template>
    <div class="resume-detail-page">
        <el-card class="card">

            <div class="page-title">简历详情</div>

            <!-- 学生基本信息 -->
            <el-descriptions title="学生信息" border :column="2">
                <el-descriptions-item label="姓名">{{ resume.studentName }}</el-descriptions-item>
                <el-descriptions-item label="性别">{{ resume.gender }}</el-descriptions-item>
                <el-descriptions-item label="电话">{{ resume.phone }}</el-descriptions-item>
                <el-descriptions-item label="邮箱">{{ resume.email }}</el-descriptions-item>
                <el-descriptions-item label="学校">{{ resume.university }}</el-descriptions-item>
                <el-descriptions-item label="专业">{{ resume.major }}</el-descriptions-item>
            </el-descriptions>

            <el-divider />

            <!-- 简历内容 -->
            <div v-if="resume.content && resume.content !== '{}'">
                <h3>{{ resume.title }}</h3>
                <div v-html="resume.content" class="resume-content"></div>
            </div>

            <div v-else>
                <el-tag type="info">该学生未填写在线简历内容</el-tag>
            </div>

            <el-divider />

            <!-- 附件简历 -->
            <div v-if="resume.fileUrl">
                <el-button type="primary" @click="openPdf">查看附件简历 PDF</el-button>
            </div>
            <div v-else>
                <el-tag type="info">该学生未上传附件简历</el-tag>
            </div>

        </el-card>
    </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { useRoute } from "vue-router";
import axios from "axios";
import { ElMessage } from "element-plus";

const route = useRoute();
const resumeId = route.params.id;

const resume = ref({});

const loadResume = async () => {
    const token = localStorage.getItem("token");

    const res = await axios.get(`/api/resume/${resumeId}`, {
        headers: {
            Authorization: `Bearer ${token}`,
        },
    });

    if (res.data.code === "200") {
        resume.value = res.data.data;
    } else {
        ElMessage.error(res.data.msg || "加载失败");
    }
};

onMounted(() => {
    loadResume();
});

const openPdf = () => {
    const base = "http://localhost:9999";  // ← 你的后端地址
    window.open(base + resume.value.fileUrl, "_blank");
};

</script>

<style scoped>
.resume-detail-page {
    padding: 20px;
}

.card {
    padding: 20px;
}

.page-title {
    font-size: 22px;
    font-weight: 600;
    margin-bottom: 20px;
}

.resume-content {
    padding: 10px 0;
    line-height: 1.8;
}
</style>
