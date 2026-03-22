<template>
    <div class="admin-guide-page">
        <el-card class="card" shadow="never">
            <div class="page-head">
                <div>
                    <h1 class="page-title">就业指导管理</h1>
                    <p class="page-sub">发布平台文章，或管理全部就业指导（含企业发布）</p>
                </div>
                <el-button type="primary" @click="goCreate">发布平台文章</el-button>
            </div>

            <el-table v-loading="loading" :data="list" border stripe style="width: 100%">
                <el-table-column prop="title" label="标题" min-width="180" show-overflow-tooltip />
                <el-table-column label="来源" width="100">
                    <template #default="{ row }">
                        <el-tag v-if="row.userId == null" type="success" size="small">平台</el-tag>
                        <el-tag v-else type="info" size="small">企业</el-tag>
                    </template>
                </el-table-column>
                <el-table-column prop="description" label="简介" min-width="200" show-overflow-tooltip />
                <el-table-column prop="viewCount" label="浏览量" width="90" />
                <el-table-column label="发布时间" width="170">
                    <template #default="{ row }">
                        {{ formatTime(row.createTime) }}
                    </template>
                </el-table-column>
                <el-table-column label="操作" width="260" fixed="right">
                    <template #default="{ row }">
                        <el-button type="primary" link @click="goEdit(row.id)">编辑</el-button>
                        <el-button type="primary" link @click="openPreview(row.id)">前台预览</el-button>
                        <el-button type="danger" link @click="onDelete(row)">删除</el-button>
                    </template>
                </el-table-column>
            </el-table>

            <el-empty v-if="!loading && list.length === 0" description="暂无文章" />
        </el-card>
    </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import { ElMessage, ElMessageBox } from 'element-plus'
import { getToken } from '@/utils/auth'

interface GuideRow {
    id: number
    title: string
    description?: string
    viewCount?: number
    createTime?: string
    userId?: number | null
}

const router = useRouter()
const list = ref<GuideRow[]>([])
const loading = ref(false)

const authHeaders = () => ({ Authorization: `Bearer ${getToken()}` })

const formatTime = (t: string | undefined) => {
    if (!t) return '—'
    return String(t).replace('T', ' ').slice(0, 16)
}

const loadList = async () => {
    loading.value = true
    try {
        const res = await axios.get('/api/guide/list')
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

const goCreate = () => {
    router.push('/admin/guide/create')
}

const goEdit = (id: number) => {
    router.push({ name: 'adminGuideEdit', params: { id: String(id) } })
}

const openPreview = (id: number) => {
    const href = router.resolve({ path: `/guide/${id}`, query: { from: 'admin' } }).href
    window.open(href, '_blank')
}

const onDelete = (row: GuideRow) => {
    ElMessageBox.confirm(`确定删除「${row.title}」吗？`, '删除确认', {
        type: 'warning',
        confirmButtonText: '删除',
        cancelButtonText: '取消',
    })
        .then(async () => {
            const res = await axios.delete(`/api/guide/admin/${row.id}`, { headers: authHeaders() })
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
.admin-guide-page {
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
    max-width: 480px;
}
</style>
