<template>
    <div class="resume-inbox-page">
        <el-card class="card">
            <div class="page-title">简历收件箱</div>

            <el-table :data="list" border stripe style="width: 100%">
                <el-table-column prop="jobTitle" label="岗位名称" min-width="160" />

                <el-table-column prop="studentName" label="学生姓名" min-width="120" />

                <el-table-column prop="createTime" label="投递时间" min-width="180" />

                <el-table-column prop="resumeTitle" label="简历名称" min-width="140" show-overflow-tooltip />

                <el-table-column label="投递类型" min-width="100">
                    <template #default="{ row }">
                        <el-tag v-if="row.resumeType === 2" type="warning" size="small">附件</el-tag>
                        <el-tag v-else-if="row.resumeType === 1" type="success" size="small">在线</el-tag>
                        <span v-else class="text-gray-400">—</span>
                    </template>
                </el-table-column>

                <el-table-column label="在线简历" min-width="110">
                    <template #default="{ row }">
                        <el-tag v-if="row.resumeType === 1 && row.resumeContent" type="info" size="small">本次为在线填写</el-tag>
                        <span v-else class="text-gray-400 text-xs">详情页可查看学生在线简历</span>
                    </template>
                </el-table-column>

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
    if (!row.resumeId || !row.studentId) {
        ElMessage.error("该投递记录数据异常");
        return;
    }
    // 跳转到学生详情页，并带上投递的 resumeId
    router.push(`/company/student/${row.studentId}?resumeId=${row.resumeId}`);
};


// 标记为已查看
const markRead = async (row) => {
    const token = localStorage.getItem("token");

    const res = await axios.post(
        "/api/application/mark-read",
        { id: row.applicationId },
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
