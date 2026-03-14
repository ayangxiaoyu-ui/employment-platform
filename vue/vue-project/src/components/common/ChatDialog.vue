<template>
    <el-dialog v-model="visible" width="500px" title="沟通中" append-to-body destroy-on-close class="chat-dialog">
        <div class="chat-header flex items-center gap-3 pb-4 border-b">
            <el-avatar :size="40" :src="target.avatar ? `http://localhost:9999${target.avatar}` : ''">
                {{ target.name?.charAt(0) }}
            </el-avatar>
            <span class="font-bold text-lg">{{ target.name || '加载中...' }}</span>
        </div>

        <div class="chat-box my-4 h-[400px] overflow-y-auto p-2 bg-gray-50 rounded-lg" ref="scrollBox">
            <div v-for="msg in messages" :key="msg.id"
                :class="['flex mb-4', msg.senderId == selfId ? 'justify-end' : 'justify-start']">

                <div
                    :class="['max-w-[80%] p-3 rounded-xl text-sm shadow-sm',
                        msg.senderId == selfId ? 'bg-blue-600 text-white rounded-tr-none' : 'bg-white text-gray-800 rounded-tl-none']">
                    {{ msg.content }}
                    <div class="text-[10px] mt-1 opacity-70 text-right">
                        {{ formatTime(msg.createTime) }}
                    </div>
                </div>
            </div>
        </div>

        <div class="chat-input flex gap-2 pt-2">
            <el-input v-model="content" type="textarea" :rows="2" placeholder="请输入消息..." @keyup.enter.ctrl="send" />
            <el-button type="primary" class="h-auto" @click="send">发送</el-button>
        </div>
    </el-dialog>
</template>

<script setup>
import { ref, nextTick, onUnmounted } from 'vue'
import axios from 'axios'
import { ElMessage } from 'element-plus'

const props = defineProps({
    // 修正类型警告：允许 Number 和 String
    selfId: [Number, String],
    targetId: [Number, String],
    selfType: String,
    targetType: String
})

const visible = ref(false)
const messages = ref([])
const content = ref("")
const target = ref({ name: "", avatar: "" })
const scrollBox = ref(null)
let timer = null // 用于轮询

// 自动滚动到底部
const scrollToBottom = async () => {
    await nextTick()
    if (scrollBox.value) {
        scrollBox.value.scrollTop = scrollBox.value.scrollHeight
    }
}

// 打开聊天窗口
const open = async () => {
    visible.value = true

    // 加载对方信息
    target.value = await loadUserInfo(props.targetId, props.targetType)

    // 加载历史记录
    await loadChat()

    // 自动滚动到底部（可选）
}


// 加载聊天记录
const loadChat = async () => {
    try {
        const res = await axios.get("/api/message/chat", {
            params: {
                userA: props.selfId,
                userB: props.targetId
            }
        })
        if (res.data.code === "200") {
            const newMsgs = res.data.data
            // 只有当消息数量变了才滚动，优化体验
            const shouldScroll = newMsgs.length > messages.value.length
            messages.value = newMsgs
            if (shouldScroll) scrollToBottom()
        }
    } catch (e) {
        console.error("聊天记录加载失败")
    }
}

// 发送消息
const send = async () => {
    if (!content.value.trim()) return

    const res = await axios.post("/api/message/send", {
        senderId: props.selfId,
        receiverId: props.targetId,
        content: content.value,
        type: 1 // 1代表普通私聊
    })

    if (res.data.code === "200") {
        content.value = ""
        loadChat() // 立即刷新
    }
}

const loadUserInfo = async (id, type) => {
    const url = type === "student"
        ? `/api/student/${id}`
        : `/api/company/${id}`

    const res = await axios.get(url)
    const data = res.data.data
    console.log(data.logo);

    return {
        name: data.name,
        avatar: data.avatar || data.logo || ''   // ⭐ 统一头像字段
    }
}


const formatTime = (time) => time ? time.split('T')[1].substring(0, 5) : ''

// 关闭弹窗时清除定时器
onUnmounted(() => {
    if (timer) clearInterval(timer)
})

defineExpose({ open })
</script>

<style scoped>
.chat-box::-webkit-scrollbar {
    width: 4px;
}

.chat-box::-webkit-scrollbar-thumb {
    background: #e5e7eb;
    border-radius: 10px;
}
</style>