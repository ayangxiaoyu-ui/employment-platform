<template>
  <section class="content-card">
    <h3 class="text-xl font-bold mb-4">互动信息</h3>

    <el-table :data="messages" style="width: 100%">

      <!-- 联系人（企业） -->
      <el-table-column label="企业" width="220">
        <template #default="scope">
          <div class="flex items-center gap-3 cursor-pointer" @click="openChat(scope.row.target)">
            <el-avatar :src="scope.row.target?.avatar ? `http://localhost:9999${scope.row.target.avatar}` : ''"
              size="small" />
            <span>{{ scope.row.target?.name || '未知企业' }}</span>
          </div>
        </template>
      </el-table-column>

      <!-- 最新消息内容 -->
      <el-table-column prop="content" label="内容" />

      <!-- 类型 -->
      <el-table-column label="类型" width="120">
        <template #default="scope">
          <el-tag :type="getType(scope.row.type)">
            {{ getTypeText(scope.row.type) }}
          </el-tag>
        </template>
      </el-table-column>

      <!-- 是否已读 -->
      <el-table-column label="状态" width="100">
        <template #default="scope">
          <el-tag :type="scope.row.isRead ? 'success' : 'danger'">
            {{ scope.row.isRead ? '已读' : '未读' }}
          </el-tag>
        </template>
      </el-table-column>

      <!-- 时间 -->
      <el-table-column label="时间" width="180">
        <template #default="scope">
          {{ formatTime(scope.row.createTime) }}
        </template>
      </el-table-column>

      <!-- 操作 -->
      <el-table-column label="操作" width="120">
        <template #default="scope">
          <el-button v-if="!scope.row.isRead" type="primary" size="small" @click="markRead(scope.row.id)">
            标记已读
          </el-button>
        </template>
      </el-table-column>

    </el-table>

    <!-- ⭐ 聊天窗口组件 -->
    <ChatDialog ref="chatRef" />
  </section>
</template>

<script setup lang="ts">
import { ref, onMounted, watch } from 'vue'
import axios from 'axios'
import { ElMessage } from 'element-plus'
import ChatDialog from '@/components/common/ChatDialog.vue'

// Props
const props = defineProps<{
  userId: number | string | null
}>()

const messages = ref([])
const chatRef = ref(null)

// 点击企业 → 打开聊天窗口
const openChat = (target: any) => {
  chatRef.value.open({
    selfId: props.userId,
    selfType: "student",
    targetId: target.id,
    targetName: target.name,
    targetAvatar: target.avatar,
    targetType: "company"
  })
}

// 加载消息（后端已按联系人分组）
const loadMessages = () => {
  if (!props.userId) return
  axios.get(`/api/message/user/${props.userId}`).then(res => {
    if (res.data.code === "200") {
      messages.value = res.data.data
    }
  })
}

// 标记已读
const markRead = (id: number) => {
  axios.post(`/api/message/read/${id}`).then(res => {
    if (res.data.code === "200") {
      ElMessage.success("已标记已读")
      loadMessages()
    }
  })
}

// 类型映射
const getType = (type: number) => {
  const map: any = { 1: 'info', 2: 'warning', 3: 'success' }
  return map[type] || 'info'
}

const getTypeText = (type: number) => {
  const map: any = { 1: '普通消息', 2: '面试通知', 3: '系统通知' }
  return map[type] || '未知消息'
}

// 时间格式化
const formatTime = (time: string) => {
  return time.replace("T", " ").substring(0, 19)
}

onMounted(() => loadMessages())

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

.message-list {
  margin-top: 16px;
}

.msg-item {
  display: flex;
  padding: 16px;
  border-bottom: 1px solid #f5f5f5;
  align-items: flex-start;
  gap: 12px;
}

.msg-item.unread {
  background-color: #f5f7fa;
}

.msg-dot {
  width: 8px;
  height: 8px;
  background: #f56c6c;
  border-radius: 50%;
  margin-top: 6px;
  flex-shrink: 0;
}

.msg-content {
  flex: 1;
}

.msg-content p {
  margin: 0 0 4px;
  font-size: 14px;
}

.msg-content span {
  font-size: 12px;
  color: #999;
}
</style>
