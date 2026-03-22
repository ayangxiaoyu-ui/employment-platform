<template>
    <div class="admin-news-page">
        <el-card class="card" shadow="never">
            <div class="page-head">
                <div>
                    <h1 class="page-title">公告与通知</h1>
                    <p class="page-sub">发布后学生端「公告通知」列表可见，支持删除</p>
                </div>
                <el-button type="primary" @click="openDialog">发布公告</el-button>
            </div>

            <el-table v-loading="loading" :data="list" border stripe style="width: 100%">
                <el-table-column prop="title" label="标题" min-width="200" show-overflow-tooltip />
                <el-table-column prop="viewCount" label="浏览量" width="100" />
                <el-table-column label="发布时间" width="180">
                    <template #default="{ row }">
                        {{ formatTime(row.createTime) }}
                    </template>
                </el-table-column>
                <el-table-column label="操作" width="160" fixed="right">
                    <template #default="{ row }">
                        <el-button type="primary" link @click="preview(row)">前台预览</el-button>
                        <el-button type="danger" link @click="onDelete(row)">删除</el-button>
                    </template>
                </el-table-column>
            </el-table>

            <el-empty v-if="!loading && list.length === 0" description="暂无公告，点击右上角发布" />
        </el-card>

        <el-dialog v-model="dialogVisible" title="发布公告" width="560px" destroy-on-close @closed="resetForm">
            <el-form ref="formRef" :model="form" :rules="rules" label-width="72px">
                <el-form-item label="标题" prop="title">
                    <el-input v-model="form.title" placeholder="请输入公告标题" maxlength="200" show-word-limit />
                </el-form-item>
                <el-form-item label="内容" prop="content">
                    <el-input v-model="form.content" type="textarea" :rows="10" placeholder="请输入正文（支持换行）" />
                </el-form-item>
            </el-form>
            <template #footer>
                <el-button @click="dialogVisible = false">取消</el-button>
                <el-button type="primary" :loading="submitting" @click="submit">发布</el-button>
            </template>
        </el-dialog>
    </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import { ElMessage, ElMessageBox, type FormInstance, type FormRules } from 'element-plus'
import { getToken } from '@/utils/auth'

interface NewsRow {
    id: number
    title: string
    content?: string
    viewCount?: number
    createTime?: string
}

const router = useRouter()
const loading = ref(false)
const list = ref<NewsRow[]>([])
const dialogVisible = ref(false)
const submitting = ref(false)
const formRef = ref<FormInstance>()
const form = ref({ title: '', content: '' })

const rules: FormRules = {
    title: [{ required: true, message: '请输入标题', trigger: 'blur' }],
    content: [{ required: true, message: '请输入内容', trigger: 'blur' }],
}

const authHeaders = () => ({ Authorization: `Bearer ${getToken()}` })

const loadList = async () => {
    loading.value = true
    try {
        const res = await axios.get('/api/news/list')
        if (res.data.code === '200') {
            list.value = res.data.data || []
        } else {
            ElMessage.error(res.data.msg || '加载失败')
        }
    } catch {
        ElMessage.error('加载失败')
    } finally {
        loading.value = false
    }
}

const formatTime = (t: string | undefined) => {
    if (!t) return '—'
    return String(t).replace('T', ' ').slice(0, 16)
}

const openDialog = () => {
    dialogVisible.value = true
}

const resetForm = () => {
    form.value = { title: '', content: '' }
    formRef.value?.resetFields()
}

const submit = async () => {
    await formRef.value?.validate().catch(() => Promise.reject())
    submitting.value = true
    try {
        const res = await axios.post('/api/news/admin', form.value, { headers: authHeaders() })
        if (res.data.code === '200') {
            ElMessage.success('发布成功')
            dialogVisible.value = false
            loadList()
        } else {
            ElMessage.error(res.data.msg || '发布失败')
        }
    } catch {
        /* 校验失败或网络错误 */
    } finally {
        submitting.value = false
    }
}

const preview = (row: NewsRow) => {
    const href = router.resolve({
        name: 'NewsDetail',
        params: { id: String(row.id) },
        query: { from: 'admin' },
    }).href
    window.open(href, '_blank')
}

const onDelete = (row: NewsRow) => {
    ElMessageBox.confirm(`确定删除公告「${row.title}」吗？`, '删除确认', {
        type: 'warning',
        confirmButtonText: '删除',
        cancelButtonText: '取消',
    })
        .then(async () => {
            const res = await axios.delete(`/api/news/admin/${row.id}`, { headers: authHeaders() })
            if (res.data.code === '200') {
                ElMessage.success('已删除')
                loadList()
            } else {
                ElMessage.error(res.data.msg || '删除失败')
            }
        })
        .catch(() => {})
}

onMounted(() => {
    loadList()
})
</script>

<style scoped>
.admin-news-page {
    padding: 20px;
    width: 100%;
    box-sizing: border-box;
}

.card {
    border-radius: 8px;
}

.page-head {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    gap: 16px;
    margin-bottom: 20px;
    flex-wrap: wrap;
}

.page-title {
    margin: 0 0 6px;
    font-size: 22px;
    font-weight: 600;
    color: #303133;
}

.page-sub {
    margin: 0;
    font-size: 13px;
    color: #909399;
}
</style>
