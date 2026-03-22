<template>
    <div class="message-page">
        <!-- 左侧会话列表 -->
        <div class="sidebar">
            <div class="sidebar-title">互动消息</div>

            <el-scrollbar class="chat-list">
                <div v-for="item in chatList" :key="item.target.id" class="chat-item"
                    :class="{ active: item.target.id === currentTargetId }" @click="openChat(item.target.id)">
                    <div class="name clickable" @click.stop="viewStudent(item.target.id)">
                        {{ item.target.name }}
                    </div>

                    <div class="preview">{{ item.content }}</div>

                    <el-badge v-if="item.isRead === 0 && item.senderId !== companyId" value=" " class="unread-dot" />
                </div>
            </el-scrollbar>
        </div>

        <!-- 右侧聊天窗口 -->
        <div class="chat-window">
            <div class="chat-header">
                {{ currentTarget?.name || "请选择学生" }}
            </div>

            <el-scrollbar class="chat-body" ref="scrollRef">
                <div v-for="msg in messages" :key="msg.id" class="msg-row"
                    :class="msg.senderId === companyId ? 'me' : 'other'">
                    <div class="msg-bubble">{{ msg.content }}</div>
                </div>
            </el-scrollbar>

            <!-- 输入框 -->
            <div class="chat-input">
                <el-input v-model="text" placeholder="输入消息..." @keyup.enter="sendMessage" />
                <el-button type="primary" @click="sendMessage">发送</el-button>
            </div>
        </div>
    </div>
</template>

<script setup>
import { ref, onMounted, nextTick } from "vue";
import axios from "axios";
import { ElMessage } from "element-plus";
import { useRouter } from "vue-router";
const router = useRouter();

const viewStudent = (studentId) => {
    router.push(`/company/student/${studentId}`);
};


const chatList = ref([]);
const messages = ref([]);
const text = ref("");
const currentTargetId = ref(null);
const currentTarget = ref(null);
const companyId = ref(null);
const scrollRef = ref(null);

// 获取企业 userId → companyId
const loadCompanyId = async () => {
    const token = localStorage.getItem("token");
    const res = await axios.get("/api/user/me", {
        headers: { Authorization: `Bearer ${token}` },
    });
    companyId.value = res.data.data.companyId;
};

// 加载会话列表
const loadChatList = async () => {
    const token = localStorage.getItem("token");
    const res = await axios.get("/api/message/company/inbox", {
        headers: { Authorization: `Bearer ${token}` },
    });

    if (res.data.code === "200") {
        chatList.value = res.data.data;
    }
};

// 打开与某个学生的聊天
const openChat = async (studentId) => {
    currentTargetId.value = studentId;

    const token = localStorage.getItem("token");
    const res = await axios.get("/api/message/company/chat", {
        params: { studentId },
        headers: { Authorization: `Bearer ${token}` },
    });

    if (res.data.code === "200") {
        messages.value = res.data.data;
        currentTarget.value = chatList.value.find(
            (x) => x.target.id === studentId
        )?.target;

        // 滚动到底部
        nextTick(() => {
            scrollRef.value.setScrollTop(999999);
        });

        // 标记为已读
        markAllRead(studentId);
    }
};

// 标记消息为已读
const markAllRead = async (studentId) => {
    const unread = messages.value.filter(
        (m) => m.senderId === studentId && m.isRead === 0
    );

    for (const msg of unread) {
        await axios.post(`/api/message/read/${msg.id}`);
    }

    loadChatList();
};

// 发送消息
const sendMessage = async () => {
    if (!text.value.trim()) return;

    const token = localStorage.getItem("token");

    await axios.post(
        "/api/message/company/send",
        {
            receiverId: currentTargetId.value,
            content: text.value,
        },
        {
            headers: { Authorization: `Bearer ${token}` },
        }
    );

    text.value = "";
    openChat(currentTargetId.value);
};

onMounted(async () => {
    await loadCompanyId();
    await loadChatList();
});
</script>

<style scoped>
.message-page {
    display: flex;
    height: 100%;
    background: #f5f7fa;
}

/* 左侧会话列表 */
.sidebar {
    width: 260px;
    background: #fff;
    border-right: 1px solid #e6e9ef;
    display: flex;
    flex-direction: column;
}

.sidebar-title {
    padding: 16px;
    font-size: 18px;
    font-weight: 600;
    border-bottom: 1px solid #e6e9ef;
}

.chat-list {
    flex: 1;
}

.chat-item {
    padding: 12px 16px;
    border-bottom: 1px solid #f0f0f0;
    cursor: pointer;
    position: relative;
}

.chat-item.active {
    background: #e8f3ff;
}

.chat-item:hover {
    background: #f5faff;
}

.name {
    font-weight: 600;
}

.preview {
    font-size: 13px;
    color: #666;
    margin-top: 4px;
}

.unread-dot {
    position: absolute;
    right: 12px;
    top: 20px;
}

/* 右侧聊天窗口 */
.chat-window {
    flex: 1;
    display: flex;
    flex-direction: column;
}

.chat-header {
    padding: 16px;
    font-size: 18px;
    font-weight: 600;
    border-bottom: 1px solid #e6e9ef;
    background: #fff;
}

.chat-body {
    flex: 1;
    padding: 16px;
}

.msg-row {
    display: flex;
    margin-bottom: 12px;
}

.msg-row.me {
    justify-content: flex-end;
}

.msg-bubble {
    max-width: 60%;
    padding: 10px 14px;
    border-radius: 8px;
    background: #e8f3ff;
}

.msg-row.me .msg-bubble {
    background: #0168d1;
    color: #fff;
}

.chat-input {
    display: flex;
    padding: 12px;
    background: #fff;
    border-top: 1px solid #e6e9ef;
}

.chat-input .el-input {
    flex: 1;
    margin-right: 10px;
}

.clickable {
    cursor: pointer;
    color: #0168d1;
}

.clickable:hover {
    text-decoration: underline;
}
</style>
