<template>
    <div class="guide-create">
        <el-card>
            <h2>发布就业指导文章</h2>

            <el-form :model="form" label-width="100px">

                <el-form-item label="标题">
                    <el-input v-model="form.title" />
                </el-form-item>

                <el-form-item label="简介">
                    <el-input type="textarea" v-model="form.description" :rows="3" />
                </el-form-item>

                <!-- 封面图上传 -->
                <el-form-item label="封面图">
                    <el-upload action="http://localhost:9999/file/upload/guide" name="file" :show-file-list="false"
                        :on-success="handleUploadSuccess">
                        <el-button type="primary">上传封面图</el-button>
                    </el-upload>

                    <!-- 预览 -->
                    <img v-if="form.cover" :src="`http://localhost:9999${form.cover}`" class="preview" />
                </el-form-item>

                <!-- 富文本编辑器 -->
                <el-form-item label="内容">
                    <div class="editor-container">
                        <Toolbar :editor="editorRef" />
                        <Editor v-model="form.content" @onCreated="handleCreated"
                            style="height: 400px; border: 1px solid #ddd" />
                    </div>
                </el-form-item>

                <el-form-item>
                    <el-button type="primary" @click="submit">发布</el-button>
                </el-form-item>

            </el-form>
        </el-card>
    </div>
</template>

<script setup>
import { reactive, ref, onBeforeUnmount } from "vue";
import axios from "axios";
import { ElMessage } from "element-plus";

// 富文本编辑器
import { Editor, Toolbar } from "@wangeditor/editor-for-vue";
import "@wangeditor/editor/dist/css/style.css";

const editorRef = ref(null);
const handleCreated = (editor) => {
    editorRef.value = editor;
};

const form = reactive({
    title: "",
    description: "",
    cover: "",
    content: ""
});

// 上传成功回调
const handleUploadSuccess = (res) => {
    if (res.code === "200") {
        form.cover = res.data;
        ElMessage.success("封面上传成功");
    } else {
        ElMessage.error("上传失败");
    }
};

const submit = async () => {
    if (!form.title || !form.content) {
        ElMessage.error("标题和内容不能为空");
        return;
    }

    const res = await axios.post("/api/guide", form);

    if (res.data.code === "200") {
        ElMessage.success("发布成功");
    } else {
        ElMessage.error("发布失败");
    }
};

// 销毁编辑器
onBeforeUnmount(() => {
    const editor = editorRef.value;
    if (editor) editor.destroy();
});
</script>

<style scoped>
.guide-create {
    max-width: 900px;
    margin: 0 auto;
}

.preview {
    width: 200px;
    height: 120px;
    object-fit: cover;
    border-radius: 6px;
    margin-left: 20px;
    border: 1px solid #ddd;
}

.editor-container {
    border: 1px solid #ddd;
}
</style>
