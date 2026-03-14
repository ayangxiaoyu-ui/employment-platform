<template>
    <section class="content-card">
        <div class="card-header">
            <h3>我的简历</h3>
            <el-upload class="upload-box" action="http://localhost:9999/api/resume/upload" name="file"
                :data="{ studentId: studentId }" :headers="{ 'Authorization': `Bearer ${getToken()}` }"
                :on-success="handleSuccess" :show-file-list="false">
                <el-button type="primary">上传简历</el-button>
            </el-upload>
        </div>

        <div class="resume-list">
            <div v-for="res in resumes" :key="res.id" class="resume-card">
                <div class="res-icon">
                    <el-icon>
                        <Document />
                    </el-icon>
                </div>

                <div class="res-info">
                    <h4>{{ res.title || '附件简历' }}</h4>
                    <p>更新时间：{{ res.updateTime }}</p>
                </div>

                <div class="res-actions">
                    <el-button link type="primary" @click="previewResume(res)">预览</el-button>
                    <el-button link type="danger" @click="deleteResume(res)">删除</el-button>
                </div>
            </div>

            <el-empty v-if="resumes.length === 0" description="暂无简历，请先上传" />
        </div>

        <el-dialog v-model="previewVisible" title="简历预览" width="80%" destroy-on-close>
            <iframe v-if="currentPreviewUrl" :src="currentPreviewUrl" width="100%" height="600px" frameborder="0" />
            <div v-else style="text-align: center; padding: 20px;">加载中或无预览内容...</div>
        </el-dialog>
    </section>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Document } from '@element-plus/icons-vue'
import { getToken } from '@/utils/auth'

interface Props {
    studentId: number | null
}

const props = defineProps<Props>()

const resumes = ref<any[]>([])
const previewVisible = ref(false)
const currentPreviewUrl = ref('')

const fetchResumes = async (studentId: number) => {
    try {
        const res = await fetch(`/api/resume/student/${studentId}`, {
            headers: { 'Authorization': `Bearer ${getToken()}` }
        })
        const result = await res.json()

        if (result.code === '200') {
            resumes.value = result.data.filter((r: any) => r.fileUrl)
            console.log(resumes.value, "加载到简历列表")
        }
    } catch (e) {
        ElMessage.error('加载简历列表失败')
    }
}

const previewResume = (res: any) => {
    const path = res.fileUrl

    if (!path) {
        ElMessage.warning('该简历没有文件路径')
        return
    }

    const baseUrl = 'http://localhost:9999'
    currentPreviewUrl.value = path.startsWith('http') ? path : `${baseUrl}${path}`
    previewVisible.value = true
}

const handleSuccess = async (res: any, file: any) => {
    console.log(res.code, "res.code")

    if (res.code === "409") {
        ElMessageBox.confirm(
            '已存在同名简历，是否替换？',
            '提示',
            { confirmButtonText: '替换', cancelButtonText: '取消' }
        ).then(() => {
            uploadAgainWithForce(file)
        }).catch(() => { })
        return
    }

    if (res.code !== "200") {
        ElMessage.error(res.msg || '上传失败')
        return
    }

    const { fileUrl, title } = res.data
    console.log(res, "res")

    await saveResume(fileUrl, title)
}

const uploadAgainWithForce = async (file: any) => {
    const formData = new FormData()
    formData.append("file", file.raw)
    formData.append("studentId", String(props.studentId))
    formData.append("force", "true")

    try {
        const res = await fetch("http://localhost:9999/api/resume/upload", {
            method: "POST",
            body: formData,
            headers: { "Authorization": `Bearer ${getToken()}` }
        })
        const result = await res.json()
        if (result.code === "200") {
            await saveResume(result.data.fileUrl, result.data.title)
            ElMessage.success("替换成功")
            if (props.studentId) fetchResumes(props.studentId)
        }
    } catch (e) {
        ElMessage.error('替换失败')
    }
}

const saveResume = async (fileUrl: string, title: string) => {
    try {
        const saveRes = await fetch('http://localhost:9999/api/resume', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${getToken()}`
            },
            body: JSON.stringify({
                studentId: props.studentId,
                fileUrl,
                title,
                content: '{}',
                isPublic: 1
            })
        })

        const saveResult = await saveRes.json()
        if (saveResult.code === "200") {
            if (props.studentId) fetchResumes(props.studentId)
            ElMessage.success('简历上传成功')
        }
    } catch (e) {
        ElMessage.error('保存简历失败')
    }
}

const deleteResume = async (res: any) => {
    ElMessageBox.confirm(
        `确定要删除简历「${res.title}」吗？`,
        '提示',
        { confirmButtonText: '删除', cancelButtonText: '取消', type: 'warning' }
    ).then(async () => {
        try {
            const response = await fetch(`http://localhost:9999/api/resume/${res.id}`, {
                method: 'DELETE',
                headers: { 'Authorization': `Bearer ${getToken()}` }
            })

            const result = await response.json()

            if (result.code === "200") {
                ElMessage.success('删除成功')
                if (props.studentId) fetchResumes(props.studentId)
            } else {
                ElMessage.error(result.msg || '删除失败')
            }
        } catch (e) {
            ElMessage.error('删除失败')
        }
    }).catch(() => { })
}

defineExpose({
    fetchResumes
})
</script>

<style scoped>
/* .content-card {
    background: white;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

.card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
}

.resume-card {
    display: flex;
    align-items: center;
    padding: 16px;
    border: 1px solid #f0f0f0;
    border-radius: 8px;
    margin-bottom: 12px;
    transition: 0.3s;
}

.resume-card:hover {
    border-color: #409eff;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.res-icon {
    font-size: 32px;
    color: #909399;
    margin-right: 16px;
}

.res-info {
    flex: 1;
}

.res-info h4 {
    margin: 0 0 4px;
}

.res-info p {
    margin: 0;
    font-size: 12px;
    color: #999;
}

.res-actions {
    display: flex;
    gap: 8px;
} */
</style>
