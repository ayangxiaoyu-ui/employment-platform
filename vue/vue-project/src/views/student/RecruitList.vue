<template>
    <div class="min-h-screen bg-gray-50">
        <div class="w-[1000px] mx-auto py-6 flex flex-col gap-[20px]">

            <!-- 筛选卡片 -->
            <div class="bg-white shadow-sm rounded-lg p-5 flex flex-col gap-4 border border-gray-100">
                <div class="flex gap-3">
                    <el-input v-model="keyword" placeholder="搜索职位 / 公司 / 地点" clearable class="w-[300px]"
                        @keyup.enter="loadJobs" />

                    <el-button type="primary" @click="loadJobs">搜索</el-button>
                    <el-button @click="resetSearch">重置</el-button>
                </div>

                <el-cascader v-model="selectedCategory" :options="categoryTree" placeholder="选择职位分类" clearable
                    class="w-[300px]" @change="loadJobs" />
            </div>

            <!-- 标题 -->
            <div class="flex justify-between items-center mt-6 mb-3 border-b pb-2">
                <h2 class="text-xl font-bold text-gray-800">📋 招聘信息</h2>
                <span class="text-gray-500 text-sm">共 {{ jobs.length }} 条岗位</span>
            </div>

            <!-- 岗位列表 -->
            <div v-if="jobs.length > 0" class=" mt-4">
                <JobCardList :jobs="jobs" @open-detail="openDetail" />
            </div>

            <!-- 空状态 -->
            <div v-else class="flex flex-col items-center justify-center py-24">
                <el-empty description="暂无岗位" />
                <p class="text-gray-400 mt-2 text-sm">试试更换分类或关键词</p>
            </div>

            <!-- 岗位详情弹窗 -->
            <JobDetailDialog ref="jobDetailRef" :student-id="studentId" :current-job-id="currentJobId" />
        </div>
    </div>
</template>


<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { getToken } from '@/utils/auth'

import JobCardList from '@/components/StudentProfile/JobCardList.vue'
import JobDetailDialog from '@/components/StudentProfile/JobDetailDialog.vue'

/* -------------------- 数据 -------------------- */
const jobs = ref([])
const studentId = ref(null)
const jobDetailRef = ref(null)
const currentJobId = ref(null)
const keyword = ref("")
const selectedCategory = ref(null)
const categoryTree = ref([])

/* -------------------- 加载分类 -------------------- */
const loadCategories = async () => {
    const res = await axios.get("/api/category/job")
    if (res.data.code === "200") {
        categoryTree.value = buildTree(res.data.data)
    }
}

/* -------------------- 构建分类树 -------------------- */
const buildTree = (list) => {
    const map = {}
    list.forEach(item => {
        map[item.id] = {
            value: item.id,
            label: item.name,
            parentId: Number(item.parentId),
            children: []
        }
    })

    const tree = []
    list.forEach(item => {
        const parentId = Number(item.parentId)
        if (parentId === 0) {
            tree.push(map[item.id])
        } else {
            map[parentId]?.children.push(map[item.id])
        }
    })

    return tree
}

/* -------------------- ⭐ 统一筛选（关键词 + 分类） -------------------- */
const loadJobs = async () => {
    const params = {}

    if (keyword.value.trim() !== "") {
        params.keyword = keyword.value.trim()
    }

    if (selectedCategory.value && selectedCategory.value.length > 0) {
        params.categoryId = selectedCategory.value.at(-1)
    }

    const res = await axios.get("/api/job/filter", { params })
    if (res.data.code === "200") {
        jobs.value = res.data.data
    }
}

/* -------------------- 重置 -------------------- */
const resetSearch = () => {
    keyword.value = ""
    selectedCategory.value = null
    loadJobs()
}

/* -------------------- 打开岗位详情 -------------------- */
const openDetail = (id) => {
    currentJobId.value = id
    jobDetailRef.value.open(id)
}

/* -------------------- 页面加载 -------------------- */
onMounted(async () => {
    const res = await axios.get('/api/student/profile', {
        headers: { Authorization: `Bearer ${getToken()}` }
    })
    if (res.data.code === "200") {
        studentId.value = Number(res.data.data.id)
    }

    loadJobs()        // ⭐ 初次加载全部岗位
    loadCategories()  // ⭐ 加载分类
})
</script>

<style scoped>
.header h2 {
    font-size: 24px;
    font-weight: 700;
    margin-bottom: 10px;
}
</style>
