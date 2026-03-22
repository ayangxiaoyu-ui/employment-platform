<template>
    <div class="guide-manage-page">
        <el-card class="card">
            <div class="page-head">
                <div class="page-title">就业指导</div>
                <el-button type="primary" @click="goCreate">发布新文章</el-button>
            </div>

            <el-table v-loading="loading" :data="list" border stripe style="width: 100%">
                <el-table-column prop="title" label="标题" min-width="200" show-overflow-tooltip />
                <el-table-column prop="description" label="简介" min-width="220" show-overflow-tooltip />
                <el-table-column prop="viewCount" label="浏览量" width="100" />
                <el-table-column label="发布时间" width="180">
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

            <el-empty v-if="!loading && list.length === 0" description="暂无文章，点击右上角发布" />
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
}

const router = useRouter()
const list = ref<GuideRow[]>([])
const loading = ref(false)

const formatTime = (t: string | undefined) => {
    if (!t) return '—'
    return String(t).replace('T', ' ').slice(0, 16)
}

const loadList = async () => {
    loading.value = true
    try {
        const res = await axios.get('/api/guide/company/mine', {
            headers: { Authorization: `Bearer ${getToken()}` }
        })
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
    router.push('/company/guide/create')
}

const goEdit = (id: number) => {
    router.push({ name: 'companyGuideEdit', params: { id: String(id) } })
}

const openPreview = (id: number) => {
    const href = router.resolve({ path: `/guide/${id}` }).href
    window.open(href, '_blank')
}

const onDelete = (row: GuideRow) => {
    ElMessageBox.confirm(`确定删除「${row.title}」吗？`, '删除确认', {
        type: 'warning',
        confirmButtonText: '删除',
        cancelButtonText: '取消'
    })
        .then(async () => {
            const res = await axios.delete(`/api/guide/company/${row.id}`, {
                headers: { Authorization: `Bearer ${getToken()}` }
            })
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
.guide-manage-page {
    padding: 20px;
    width: 100%;
    box-sizing: border-box;
}

.card {
    padding: 20px;
}

.page-head {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
}

.page-title {
    font-size: 22px;
    font-weight: 600;
    color: #333;
    margin: 0;
}
</style>
