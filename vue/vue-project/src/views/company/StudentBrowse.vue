<template>
    <div class="student-browse-page">
        <el-card class="card" shadow="never">
            <div class="page-head">
                <div>
                    <h1 class="page-title">学生库</h1>
                    <p class="page-sub">按姓名、学校、专业搜索，查看简历并在线沟通（与互动消息互通）</p>
                </div>
            </div>

            <div class="toolbar">
                <el-input
                    v-model="keyword"
                    placeholder="搜索姓名、学校或专业"
                    clearable
                    class="search-input"
                    @keyup.enter="loadList"
                />
                <el-button type="primary" @click="loadList">搜索</el-button>
            </div>

            <el-table v-loading="loading" :data="list" border stripe style="width: 100%">
                <el-table-column prop="name" label="姓名" min-width="100" />
                <el-table-column prop="gender" label="性别" width="72" />
                <el-table-column prop="university" label="学校" min-width="140" show-overflow-tooltip />
                <el-table-column prop="major" label="专业" min-width="120" show-overflow-tooltip />
                <el-table-column prop="graduationYear" label="毕业届" width="96" />
                <el-table-column prop="phone" label="手机" min-width="120" show-overflow-tooltip />
                <el-table-column label="操作" width="200" fixed="right">
                    <template #default="{ row }">
                        <el-button type="primary" link @click="goDetail(row)">查看详情</el-button>
                        <el-button type="success" link @click="openChat(row)">在线沟通</el-button>
                    </template>
                </el-table-column>
            </el-table>

            <div class="pager-wrap" v-if="total > 0">
                <el-pagination
                    v-model:current-page="pageNum"
                    v-model:page-size="pageSize"
                    :total="total"
                    :page-sizes="[12, 24, 48]"
                    layout="total, sizes, prev, pager, next"
                    background
                    @size-change="loadList"
                    @current-change="loadList"
                />
            </div>

            <el-empty v-if="!loading && list.length === 0" description="暂无学生数据，可尝试更换关键词" />
        </el-card>

        <ChatDialog ref="chatRef" :show-resume-apply="false" />
    </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import { ElMessage } from 'element-plus'
import { getToken } from '@/utils/auth'
import ChatDialog from '@/components/common/ChatDialog.vue'

interface StudentRow {
    id: number
    name: string
    gender?: string
    university?: string
    major?: string
    graduationYear?: number
    phone?: string
    email?: string
    avatar?: string
}

const router = useRouter()
const loading = ref(false)
const keyword = ref('')
const list = ref<StudentRow[]>([])
const pageNum = ref(1)
const pageSize = ref(12)
const total = ref(0)
const companyId = ref<number | null>(null)
const chatRef = ref(null)

const loadCompany = async () => {
    try {
        const res = await axios.get('/api/company/profile', {
            headers: { Authorization: `Bearer ${getToken()}` },
        })
        if (res.data.code === '200' && res.data.data?.id != null) {
            companyId.value = Number(res.data.data.id)
        }
    } catch {
        /* 忽略 */
    }
}

const loadList = async () => {
    loading.value = true
    try {
        const res = await axios.get('/api/student/company/browse', {
            params: {
                pageNum: pageNum.value,
                pageSize: pageSize.value,
                keyword: keyword.value?.trim() || undefined,
            },
            headers: { Authorization: `Bearer ${getToken()}` },
        })
        if (res.data.code === '200' && res.data.data) {
            const p = res.data.data
            list.value = p.records || []
            total.value = Number(p.total) || 0
        } else {
            ElMessage.error(res.data.msg || '加载失败')
        }
    } catch {
        ElMessage.error('加载失败')
    } finally {
        loading.value = false
    }
}

const goDetail = (row: StudentRow) => {
    router.push(`/company/student/${row.id}`)
}

const openChat = (row: StudentRow) => {
    if (companyId.value == null) {
        ElMessage.warning('请先完善企业资料后再沟通')
        return
    }
    chatRef.value?.open({
        selfId: companyId.value,
        targetId: row.id,
        selfType: 'company',
        targetType: 'student',
        targetName: row.name || '学生',
        targetAvatar: row.avatar || '',
    })
}

onMounted(async () => {
    if (!getToken()) {
        router.push({ name: 'login' })
        return
    }
    await loadCompany()
    await loadList()
})
</script>

<style scoped>
.student-browse-page {
    padding: 20px;
    width: 100%;
    box-sizing: border-box;
}

.card {
    border-radius: 8px;
}

.page-head {
    margin-bottom: 16px;
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
    max-width: 560px;
    line-height: 1.5;
}

.toolbar {
    display: flex;
    gap: 12px;
    margin-bottom: 16px;
    flex-wrap: wrap;
}

.search-input {
    width: 280px;
    max-width: 100%;
}

.pager-wrap {
    display: flex;
    justify-content: flex-end;
    margin-top: 16px;
}
</style>
