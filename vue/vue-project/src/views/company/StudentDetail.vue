<template>
    <div class="student-detail-page">
        <el-card class="card">
            <div class="title">学生信息</div>

            <el-descriptions :column="2" border>
                <el-descriptions-item label="姓名">{{ student.name }}</el-descriptions-item>
                <el-descriptions-item label="性别">{{ student.gender }}</el-descriptions-item>
                <el-descriptions-item label="电话">{{ student.phone }}</el-descriptions-item>
                <el-descriptions-item label="邮箱">{{ student.email }}</el-descriptions-item>
                <el-descriptions-item label="学校">{{ student.university }}</el-descriptions-item>
                <el-descriptions-item label="专业">{{ student.major }}</el-descriptions-item>
            </el-descriptions>
        </el-card>

        <!-- ⭐ 在线简历（含投递为在线时，或学生另有在线简历） -->
        <el-card class="card" style="margin-top: 20px">
            <div class="title">{{ student.name }}的在线简历</div>

            <div v-if="onlineResumeData">
                <div class="resume-json">
                    <div class="item"><strong>姓名：</strong>{{ onlineResumeData.name }}</div>
                    <div class="item"><strong>学校：</strong>{{ onlineResumeData.school }}</div>
                    <div class="item"><strong>专业：</strong>{{ onlineResumeData.major }}</div>
                    <div class="item"><strong>GPA：</strong>{{ onlineResumeData.gpa }}</div>
                    <div class="item"><strong>排名：</strong>{{ onlineResumeData.rank }}</div>
                    <div class="item"><strong>技术栈：</strong>{{ onlineResumeData.tech }}</div>
                    <div class="item"><strong>实习经历：</strong>{{ onlineResumeData.intern }}</div>
                    <div class="item"><strong>项目经历：</strong>{{ onlineResumeData.project }}</div>
                    <div class="item"><strong>证书：</strong>{{ onlineResumeData.cert }}</div>
                    <div class="item"><strong>自我评价：</strong>{{ onlineResumeData.eval }}</div>
                </div>
            </div>

            <div v-else>
                <el-tag type="info">该学生未填写在线简历内容</el-tag>
            </div>
        </el-card>

        <!-- ⭐ 附件简历（投递为附件时，或学生另有 PDF） -->
        <el-card class="card" style="margin-top: 20px">
            <div class="title">{{ student.name }}的附件简历</div>

            <div v-if="pdfResume">
                <el-button type="primary" @click="openPdf(pdfResume.fileUrl)">
                    查看 PDF 简历
                </el-button>
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

const route = useRoute();
const studentId = route.params.id;

const student = ref({});
const onlineResumeData = ref(null);
const pdfResume = ref(null);


const deliveredResumeId = route.query.resumeId;

const parseOnlineContent = (raw) => {
    if (!raw) return null;
    try {
        return JSON.parse(raw);
    } catch {
        return null;
    }
};

// 加载学生信息
const loadStudent = async () => {
    const token = localStorage.getItem("token");
    const res = await axios.get(`/api/student/${studentId}`, {
        headers: { Authorization: `Bearer ${token}` },
    });

    if (res.data.code === "200") {
        student.value = res.data.data;
    }
};

// 加载简历：优先展示本次投递的一份，再合并该学生的另一类型简历（附件 + 在线同时可见）
const loadResume = async () => {
    const token = localStorage.getItem("token");

    const mergeStudentResumes = async () => {
        const res = await axios.get(`/api/resume/student/${studentId}`, {
            headers: { Authorization: `Bearer ${token}` },
        });
        if (res.data.code !== "200") return;
        const list = res.data.data;
        const online = list.find((r) => r.type === 1);
        const pdf = list.find((r) => r.type === 2);
        if (!onlineResumeData.value && online?.content) {
            onlineResumeData.value = parseOnlineContent(online.content);
        }
        if (!pdfResume.value && pdf) {
            pdfResume.value = pdf;
        }
    };

    if (deliveredResumeId) {
        const res = await axios.get(`/api/resume/${deliveredResumeId}`, {
            headers: { Authorization: `Bearer ${token}` },
        });

        if (res.data.code === "200") {
            const resume = res.data.data;
            if (resume.type === 1) {
                onlineResumeData.value = parseOnlineContent(resume.content || "{}");
            } else if (resume.type === 2) {
                pdfResume.value = resume.fileUrl ? resume : null;
            }
        }
        await mergeStudentResumes();
        return;
    }

    const res = await axios.get(`/api/resume/student/${studentId}`, {
        headers: { Authorization: `Bearer ${token}` },
    });

    if (res.data.code === "200") {
        const list = res.data.data;
        const online = list.find((r) => r.type === 1);
        if (online?.content) {
            onlineResumeData.value = parseOnlineContent(online.content);
        }
        pdfResume.value = list.find((r) => r.type === 2);
    }
};


const openPdf = (url) => {
    const base = "http://localhost:9999";  // ← 你的后端地址
    window.open(base + url, "_blank");
};

onMounted(() => {
    loadStudent();
    loadResume();
});
</script>

<style scoped>
.student-detail-page {
    padding: 20px;
}

.card {
    padding: 20px;
}

.title {
    font-size: 20px;
    font-weight: 600;
    margin-bottom: 16px;
}

.resume-json .item {
    margin-bottom: 8px;
}
</style>
