<template>
    <div class="job-create-page">
        <el-card class="card">
            <div class="page-title">发布职位</div>

            <el-form :model="form" :rules="rules" ref="formRef" label-width="120px" class="form">
                <!-- 分组：基本信息 -->
                <div class="section-title">基本信息</div>

                <el-form-item label="职位名称" prop="title">
                    <el-input v-model="form.title" placeholder="如：Java开发工程师 / 前端实习生" />
                </el-form-item>

                <el-form-item label="职位分类" prop="categoryId">
                    <el-select v-model="form.categoryId" placeholder="请选择分类" style="width: 260px">
                        <el-option v-for="item in categories" :key="item.id" :label="item.name" :value="item.id" />
                    </el-select>
                </el-form-item>

                <el-form-item label="薪资范围" required>
                    <el-input-number v-model="form.salaryMin" :min="0" />
                    <span class="salary-sep">-</span>
                    <el-input-number v-model="form.salaryMax" :min="0" />
                </el-form-item>

                <el-form-item label="工作地点" prop="location">
                    <el-input v-model="form.location" placeholder="如：深圳 / 北京 / 上海" />
                </el-form-item>

                <!-- 分组：职位内容 -->
                <div class="section-title">职位内容</div>

                <!-- 职位描述 -->
                <el-form-item label="职位描述" prop="description">
                    <div class="editor-wrapper">
                        <Toolbar :editor="descEditor" />
                        <Editor v-model="form.description" :defaultConfig="editorConfig"
                            @onCreated="descEditor = $event" />
                    </div>
                </el-form-item>

                <!-- 任职要求 -->
                <el-form-item label="任职要求" prop="requirements">
                    <div class="editor-wrapper">
                        <Toolbar :editor="reqEditor" />
                        <Editor v-model="form.requirements" :defaultConfig="editorConfig"
                            @onCreated="reqEditor = $event" />
                    </div>
                </el-form-item>

                <!-- 提交按钮 -->
                <el-form-item>
                    <el-button type="primary" size="large" @click="submit">发布职位</el-button>
                </el-form-item>
            </el-form>
        </el-card>
    </div>
</template>

<script setup>
import { ref, reactive, onMounted } from "vue";
import axios from "axios";
import { ElMessage } from "element-plus";

// 富文本编辑器
import { Editor, Toolbar } from "@wangeditor/editor-for-vue";
import "@wangeditor/editor/dist/css/style.css";

// 两个编辑器实例
const descEditor = ref(null);
const reqEditor = ref(null);

// 编辑器配置
const editorConfig = {
    placeholder: "请输入内容...",
};

const formRef = ref();

const form = reactive({
    title: "",
    categoryId: null,
    salaryMin: null,
    salaryMax: null,
    location: "",
    description: "",
    requirements: "",
});

const rules = {
    title: [{ required: true, message: "请输入职位名称", trigger: "blur" }],
    categoryId: [{ required: true, message: "请选择分类", trigger: "change" }],
    location: [{ required: true, message: "请输入工作地点", trigger: "blur" }],
    description: [{ required: true, message: "请输入职位描述", trigger: "blur" }],
    requirements: [{ required: true, message: "请输入任职要求", trigger: "blur" }],
};

const categories = ref([]);

onMounted(async () => {
    const res = await axios.get("/api/category/job");
    categories.value = res.data.data;
});
const submit = () => {
    formRef.value.validate(async (valid) => {
        if (!valid) return;

        const token = localStorage.getItem("token");

        const res = await axios.post(
            "/api/job/create",
            form,
            {
                headers: {
                    Authorization: `Bearer ${token}`
                }
            }
        );

        if (res.data.code === "200") {
            ElMessage.success("发布成功");

            // ⭐ 清空表单（Element Plus 官方推荐）
            formRef.value.resetFields();

            // ⭐ 清空富文本内容
            form.description = "";
            form.requirements = "";
        } else {
            ElMessage.error(res.data.msg || "发布失败");
        }
    });
};

</script>

<style scoped>
.job-create-page {
    padding: 20px;
}

.card {
    padding: 20px;
}

.page-title {
    font-size: 22px;
    font-weight: 600;
    margin-bottom: 25px;
    color: #333;
}

.section-title {
    font-size: 16px;
    font-weight: 600;
    margin: 30px 0 15px;
    color: #444;
    border-left: 4px solid #409eff;
    padding-left: 10px;
}

.salary-sep {
    margin: 0 10px;
    font-size: 16px;
    color: #666;
}

.form {
    max-width: 800px;
}

/* 富文本编辑器容器 */
.editor-wrapper {
    border: 1px solid #dcdfe6;
    border-radius: 4px;
}

/* 富文本内容区高度 */
:deep(.w-e-text-container) {
    min-height: 200px;
}
</style>
