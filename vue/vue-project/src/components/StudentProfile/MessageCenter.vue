<template>
    <section class="content-card">
        <h3 class="text-xl font-bold mb-4">互动信息</h3>

        <el-table :data="messages" style="width: 100%">
            <el-table-column prop="content" label="内容" />

            <el-table-column label="类型" width="120">
                <template #default="scope">
                    <el-tag :type="getType(scope.row.type)">
                        {{ getTypeText(scope.row.type) }}
                    </el-tag>
                </template>
            </el-table-column>

            <el-table-column label="状态" width="100">
                <template #default="scope">
                    <el-tag :type="scope.row.is_read ? 'success' : 'danger'">
                        {{ scope.row.is_read ? '已读' : '未读' }}
                    </el-tag>
                </template>
            </el-table-column>

            <el-table-column prop="createTime" label="时间" width="180" />

            <el-table-column label="操作" width="120">
                <template #default="scope">
                    <el-button v-if="!scope.row.is_read" type="primary" size="small" @click="markRead(scope.row.id)">
                        标记已读
                    </el-button>
                </template>
            </el-table-column>
        </el-table>
    </section>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import axios from 'axios'
import { ElMessage } from 'element-plus'

// 1. 修正 Props 定义语法
const props = defineProps<{
    userId: number | string | null
}>();

const messages = ref([])

// 2. 修正 userId 引用方式
const loadMessages = () => {
    if (!props.userId) return;
    axios.get(`/api/message/user/${props.userId}`).then(res => {
        if (res.data.code === "200") {
            messages.value = res.data.data
        }
    }).catch(err => {
        console.error("加载消息失败", err)
    })
}

const markRead = (id: number) => {
    axios.post(`/api/message/read/${id}`).then(res => {
        if (res.data.code === "200") {
            ElMessage.success("已标记已读")
            loadMessages()
        }
    })
}

const getType = (type: number) => {
    const map: any = { 1: 'info', 2: 'warning', 3: 'success' }
    return map[type] || 'info'
}

const getTypeText = (type: number) => {
    const map: any = { 1: '普通消息', 2: '面试通知', 3: '系统通知' }
    return map[type] || '未知消息'
}

onMounted(() => {
    loadMessages()
})

// 监听 userId 变化，防止父组件异步获取 ID 时子组件不加载
watch(() => props.userId, (newId) => {
    if (newId) loadMessages()
})
</script>

<style scoped>
.content-card {
    background: white;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}
</style>