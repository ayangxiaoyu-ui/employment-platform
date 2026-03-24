<template>
    <div class="student-detail-page">
        <div class="back-row">
            <el-button @click="goBack">返回列表</el-button>
        </div>

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

        <!-- ⭐ 在线简历 -->
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

        <!-- ⭐ 附件简历（PDF） -->
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

        <div class="bottom-back-row">
            <el-button @click="goBack">返回列表</el-button>
        </div>
    </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import { useRoute, useRouter } from "vue-router";
import axios from "axios";

const route = useRoute();
const router = useRouter();
const studentId = route.params.id;

const student = ref({});
const onlineResumeData = ref(null);
const pdfResume = ref(null);

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

// 加载学生所有简历，并按 type 分类
const loadResume = async () => {
    const token = localStorage.getItem("token");
    const res = await axios.get(`/api/resume/student/${studentId}`, {
        headers: { Authorization: `Bearer ${token}` },
    });

    if (res.data.code === "200") {
        const list = res.data.data;

        // ⭐ 在线简历（type=1）
        const online = list.find(r => r.type === 1);
        console.log(list);

        if (online && online.content) {
            try {

                onlineResumeData.value = JSON.parse(online.content);
                console.log(onlineResumeData.value);

            } catch {
                onlineResumeData.value = null;
            }
        }

        // ⭐ 附件简历（type=2）
        pdfResume.value = list.find(r => r.type === 2);
    }
};

const openPdf = (url) => {
    const base = "http://localhost:9999";  // ← 你的后端地址
    window.open(base + url, "_blank");
};

const goBack = () => {
    if (typeof window !== "undefined" && window.history.length > 1) {
        router.back();
        return;
    }
    router.push("/company/resumes");
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

.back-row {
    margin-bottom: 12px;
}

.bottom-back-row {
    margin-top: 20px;
    display: flex;
    justify-content: center;
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
