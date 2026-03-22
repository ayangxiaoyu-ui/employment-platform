<template>
    <el-dialog v-model="visible" width="500px" title="沟通中" append-to-body destroy-on-close class="chat-dialog">

        <!-- 顶部：头像 + 名称 + 投递简历按钮 -->
        <div class="chat-header flex items-center justify-between pb-4 border-b">
            <div class="flex items-center gap-3">
                <el-avatar :size="40" :src="target.avatar ? `http://localhost:9999${target.avatar}` : ''">
                    {{ target.name?.charAt(0) }}
                </el-avatar>
                <span class="font-bold text-lg">{{ target.name || '加载中...' }}</span>
            </div>

            <el-button v-if="showResumeApply" type="success" size="small" @click="openResumeDialog">
                投递简历
            </el-button>
        </div>

        <!-- 聊天内容 -->
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

        <!-- 输入框 -->
        <div class="chat-input flex gap-2 pt-2">
            <el-input v-model="content" type="textarea" :rows="2" placeholder="请输入消息..." @keyup.enter.ctrl="send" />
            <el-button type="primary" class="h-auto" @click="send">发送</el-button>
        </div>
        <el-dialog v-if="showResumeApply" v-model="resumeVisible" title="投递简历" width="450px">

            <h4 class="font-bold mb-2">选择简历</h4>
            <el-radio-group v-model="selectedResumeId" class="w-full mb-4">
                <div v-for="r in resumes" :key="r.id" class="p-2 border-b flex items-center gap-2">
                    <el-radio :label="r.id">{{ r.title }}</el-radio>
                </div>
            </el-radio-group>

            <h4 class="font-bold mb-2">选择职位</h4>
            <el-select v-model="selectedJobId" placeholder="请选择职位" class="w-full">
                <el-option v-for="job in jobs" :key="job.id" :label="job.title" :value="job.id" />
            </el-select>

            <template #footer>
                <el-button @click="resumeVisible = false">取消</el-button>
                <el-button type="primary" @click="submitResume">确认投递</el-button>
            </template>
        </el-dialog>
    </el-dialog>

    <!-- ⭐ 投递简历弹窗 -->

</template>

<script setup>
import { ref, nextTick } from 'vue'
import axios from 'axios'
import { ElMessage } from 'element-plus'

const props = defineProps({
    /** 学生联系企业时可投递简历；企业主动联系学生时关闭 */
    showResumeApply: { type: Boolean, default: true },
})

const visible = ref(false)
const messages = ref([])
const content = ref("")
const target = ref({ name: "", avatar: "" })
const scrollBox = ref(null)

const selfId = ref(null)
const targetId = ref(null)
const selfType = ref("")
const targetType = ref("")

// ⭐ 投递简历弹窗
const resumeVisible = ref(false)
const resumes = ref([])
const jobs = ref([])
const selectedResumeId = ref(null)
const selectedJobId = ref(null)

// 打开聊天窗口
const open = async (params) => {
    selfId.value = params.selfId
    targetId.value = params.targetId
    selfType.value = params.selfType
    targetType.value = params.targetType

    target.value = {
        name: params.targetName,
        avatar: params.targetAvatar
    }

    visible.value = true
    await loadChat()
}

// 加载聊天记录
const loadChat = async () => {
    const res = await axios.get("/api/message/chat", {
        params: {
            userA: selfId.value,
            userB: targetId.value
        }
    })
    messages.value = res.data.data
    scrollToBottom()
}

// 自动滚动到底部
const scrollToBottom = async () => {
    await nextTick()
    if (scrollBox.value) {
        scrollBox.value.scrollTop = scrollBox.value.scrollHeight
    }
}

// 发送消息
const send = async () => {
    if (!content.value.trim()) return

    const res = await axios.post("/api/message/send", {
        senderId: selfId.value,
        receiverId: targetId.value,
        content: content.value,
        type: 1
    })

    if (res.data.code === "200") {
        content.value = ""
        loadChat()
    }
}

// ⭐ 打开投递简历弹窗
const openResumeDialog = async () => {
    if (!props.showResumeApply) return
    resumeVisible.value = true

    // 加载学生简历
    const res1 = await axios.get(`/api/resume/student/${selfId.value}`)
    if (res1.data.code === "200") {
        resumes.value = res1.data.data
    }

    // 加载企业职位
    const res2 = await axios.get(`/api/job/company/${targetId.value}`)
    if (res2.data.code === "200") {
        jobs.value = res2.data.data
    }
}

// ⭐ 提交投递
const submitResume = async () => {
    if (!selectedResumeId.value) {
        ElMessage.warning("请选择简历")
        return
    }
    if (!selectedJobId.value) {
        ElMessage.warning("请选择职位")
        return
    }

    try {
        const res = await axios.post("/api/application/apply", {
            studentId: selfId.value,
            jobId: selectedJobId.value,
            resumeId: selectedResumeId.value
        })

        if (res.data.code === "200") {
            ElMessage.success("投递成功！")
            resumeVisible.value = false
        } else {
            // ⭐ 处理后端返回的错误
            ElMessage.error(res.data.msg || "投递失败，请重试")
        }

    } catch (e) {
        // ⭐ 捕获后端 500 错误
        if (e.response?.data?.msg === "你已经投递过该职位了") {
            ElMessage.warning("你已经投递过该职位，请重新选择职位或简历")
        } else {
            ElMessage.error("投递失败，请稍后再试")
        }
    }
}


const formatTime = (time) => time ? time.replace("T", " ").substring(0, 16) : ''

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
