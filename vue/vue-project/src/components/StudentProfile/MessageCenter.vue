<template>
    <section class="content-card">
        <h3>消息中心</h3>
        <div class="message-list">
            <div v-for="(msg, index) in messages" :key="index" class="msg-item" :class="{ unread: !msg.read }">
                <div class="msg-dot"></div>
                <div class="msg-content">
                    <p><strong>{{ msg.title }}：</strong> {{ msg.content }}</p>
                    <span>{{ msg.time }}</span>
                </div>
            </div>
            <el-empty v-if="messages.length === 0" description="暂无消息" />
        </div>
    </section>
</template>

<script setup lang="ts">
import { ref } from 'vue'

interface Message {
    title: string
    content: string
    time: string
    read: boolean
}

const messages = ref<Message[]>([
    {
        title: '系统通知',
        content: '您的简历已被【字节跳动】HR查看。',
        time: '2小时前',
        read: false
    }
])
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
