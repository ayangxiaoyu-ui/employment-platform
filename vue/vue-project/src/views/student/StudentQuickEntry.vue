<template>
    <div class="quick-entry">
        <h2 class="title">常用入口</h2>

        <el-row :gutter="20">
            <el-col :span="4" v-for="item in entries" :key="item.text">
                <div class="entry-item" @click="go(item)">
                    <div class="icon-wrapper">
                        <component :is="item.icon" class="icon" />
                    </div>
                    <p class="text">{{ item.text }}</p>
                </div>
            </el-col>
        </el-row>
    </div>
</template>

<script setup>
import { useRouter } from "vue-router";
import {
    Document,
    Suitcase,
    StarFilled,
    Timer,
    Reading,
    OfficeBuilding
} from "@element-plus/icons-vue";

const router = useRouter();

const entries = [
    { text: "我的简历", icon: Document, tab: "resume" },
    { text: "我的投递", icon: Suitcase, tab: "apply" },
    { text: "我的收藏", icon: StarFilled, tab: "favorite" },
    { text: "我的足迹", icon: Timer, tab: "footprint" },
    { text: "就业指导", icon: Reading, path: "/guide" },
    { text: "企业列表", icon: OfficeBuilding, path: "/companies" }
];

const go = (item) => {
    if (item.path) {
        router.push(item.path);
    } else {
        router.push({
            path: "/student/profile",
            query: { tab: item.tab }
        });
    }
};
</script>

<style scoped>
.quick-entry {
    background: white;
    padding: 24px;
    border-radius: 12px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

.title {
    font-size: 20px;
    font-weight: bold;
    margin-bottom: 20px;
}

.entry-item {
    text-align: center;
    cursor: pointer;
    transition: transform 0.2s;
}

.entry-item:hover {
    transform: translateY(-4px);
}

.icon-wrapper {
    width: 20px;
    height: 20px;
    background: #f5f7fa;
    border-radius: 50%;
    display: flex;
    justify-content: center;
    align-items: center;
    margin: 0 auto 10px;
}

.icon {
    font-size: 20px;
    color: #409eff;
}



.text {
    font-size: 14px;
    color: #333;
}
</style>
