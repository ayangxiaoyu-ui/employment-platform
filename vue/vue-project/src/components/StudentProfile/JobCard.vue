<template>
    <div class="job-card" @click="$emit('open-detail', job.id)">
        <!-- 左侧公司 Logo -->

        <img class="logo" :src="job.companyLogo ? `http://localhost:9999${job.companyLogo}` : defaultLogo" alt="logo" />
        <!-- 中间内容 -->
        <div class="content">
            <div class="top-row">
                <h3 class="title">{{ job.title }}</h3>
                <span class="salary">{{ job.salaryMin }}k-{{ job.salaryMax }}k</span>
            </div>

            <div class="company">{{ job.companyName }}</div>

            <div class="tags">
                <span>{{ job.location }}</span>
                <span>{{ job.experience || '经验不限' }}</span>
                <span>{{ job.education || '学历不限' }}</span>
            </div>

            <div class="time">{{ formatTime(job.createTime) }}</div>
        </div>
    </div>
</template>

<script setup>
const props = defineProps({
    job: {
        type: Object,
        required: true
    }
})
// console.log(props.job);

const defaultLogo = "/default-logo.png" // 你可以换成自己的默认图

const formatTime = t => t.replace("T", " ").substring(0, 16)
</script>

<style scoped>
.job-card {
    display: flex;
    gap: 16px;
    padding: 18px;
    background: #fff;
    border-radius: 12px;
    box-shadow: 0 4px 14px rgba(0, 0, 0, 0.06);
    cursor: pointer;
    transition: 0.25s;
    border: 1px solid transparent;
}

.job-card:hover {
    transform: translateY(-3px);
    box-shadow: 0 6px 20px rgba(0, 0, 0, 0.12);
    border-color: #e2e8f0;
}

.logo {
    width: 60px;
    height: 60px;
    border-radius: 10px;
    object-fit: cover;
    background: #f1f5f9;
}

.content {
    flex: 1;
}

.top-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.title {
    font-size: 18px;
    font-weight: 700;
    color: #1e293b;
}

.salary {
    color: #f97316;
    font-weight: 700;
    font-size: 16px;
}

.company {
    margin-top: 4px;
    color: #475569;
    font-size: 14px;
}

.tags {
    margin-top: 8px;
    display: flex;
    gap: 12px;
    color: #64748b;
    font-size: 13px;
}

.time {
    margin-top: 10px;
    color: #94a3b8;
    font-size: 12px;
}
</style>
