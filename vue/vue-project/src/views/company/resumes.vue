<template>
    <div class="resume-inbox-page">
        <el-card class="card">
            <div class="page-title">简历收件箱</div>

            <el-table :data="list" border stripe style="width: 100%">
                <el-table-column prop="jobTitle" label="岗位名称" min-width="160" />

                <el-table-column prop="studentName" label="学生姓名" min-width="120" />

                <el-table-column prop="createTime" label="投递时间" min-width="180" />

                <!-- 调试用：显示 resumeId -->
                <el-table-column prop="resumeId" label="简历ID" min-width="120" />

                <el-table-column label="状态" min-width="120">
                    <template #default="{ row }">
                        <el-tag type="info" v-if="row.status === 0">未查看</el-tag>
                        <el-tag type="success" v-else>已查看</el-tag>
                    </template>
                </el-table-column>

                <el-table-column label="操作" min-width="160">
                    <template #default="{ row }">
                        <el-button type="primary" link @click="viewResume(row)">
                            查看简历
                        </el-button>

                        <el-button type="success" link @click="markRead(row)" v-if="row.status === 0">
                            标记已查看
                        </el-button>
                    </template>
                </el-table-column>
            </el-table>

        </el-card>
    </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import axios from "axios";
import { ElMessage } from "element-plus";
import { useRouter } from "vue-router";
const router = useRouter();



const list = ref([]);

// 加载收件箱数据
const loadData = async () => {
    const token = localStorage.getItem("token");

    const res = await axios.get("/api/application/inbox", {
        headers: {
            Authorization: `Bearer ${token}`,
        },
    });

    if (res.data.code === "200") {
        list.value = res.data.data;
    } else {
        ElMessage.error(res.data.msg || "加载失败");
    }
};

onMounted(() => {
    loadData();
});

// 查看简历（打开 PDF）
const viewResume = (row) => {
    console.log(row.resumeId, !row.resumeId);

    if (!row.resumeId) {
        ElMessage.error("该投递记录没有关联简历");
        return;
    }
    router.push(`/company/resumes/${row.resumeId}`);
};
// 标记为已查看
const markRead = async (row) => {
    const token = localStorage.getItem("token");

    const res = await axios.post(
        "/api/application/mark-read",
        { applicationId: row.applicationId },
        {
            headers: {
                Authorization: `Bearer ${token}`,
            },
        }
    );

    if (res.data.code === "200") {
        ElMessage.success("已标记为已查看");
        loadData();
    } else {
        ElMessage.error(res.data.msg || "操作失败");
    }
};
</script>

<style scoped>
.resume-inbox-page {
    padding: 20px;
}

.card {
    padding: 20px;
}

.page-title {
    font-size: 22px;
    font-weight: 600;
    margin-bottom: 20px;
    color: #333;
}
</style>
