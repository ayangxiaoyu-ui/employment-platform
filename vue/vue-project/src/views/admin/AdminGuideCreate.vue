<template>
    <div class="guide-create-page" v-loading="pageLoading">
        <el-card class="card">
            <div class="head-row">
                <h2 class="page-title">{{ isEdit ? '编辑就业指导' : '发布平台就业指导' }}</h2>
                <el-button @click="goBack">返回列表</el-button>
            </div>

            <el-form :model="form" label-width="100px">
                <el-form-item label="标题">
                    <el-input v-model="form.title" placeholder="请输入标题" />
                </el-form-item>

                <el-form-item label="简介">
                    <el-input type="textarea" v-model="form.description" :rows="3" placeholder="文章摘要" />
                </el-form-item>

                <el-form-item label="封面图">
                    <el-upload
                        action="http://localhost:9999/file/upload/guide"
                        name="file"
                        :show-file-list="false"
                        :headers="uploadHeaders"
                        :on-success="handleUploadSuccess"
                    >
                        <el-button type="primary">上传封面图</el-button>
                    </el-upload>
                    <img v-if="form.cover" :src="`http://localhost:9999${form.cover}`" class="preview" />
                </el-form-item>

                <el-form-item label="内容">
                    <div class="editor-container">
                        <Toolbar :editor="editorRef" />
                        <Editor
                            v-model="form.content"
                            @onCreated="handleCreated"
                            style="height: 400px; border: 1px solid #ddd"
                        />
                    </div>
                </el-form-item>

                <el-form-item>
                    <el-button type="primary" :loading="submitting" @click="submit">
                        {{ isEdit ? '保存修改' : '发布' }}
                    </el-button>
                </el-form-item>
            </el-form>
        </el-card>
    </div>
</template>

<script setup lang="ts">
import { reactive, ref, onBeforeUnmount, computed, onMounted, nextTick } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import axios from 'axios'
import { ElMessage } from 'element-plus'
import { getToken } from '@/utils/auth'
import { Editor, Toolbar } from '@wangeditor/editor-for-vue'
import '@wangeditor/editor/dist/css/style.css'

const router = useRouter()
const route = useRoute()
const editorRef = ref(null)
const submitting = ref(false)
const pageLoading = ref(false)

const isEdit = computed(() => route.name === 'adminGuideEdit')

const uploadHeaders = computed(() => ({
    Authorization: `Bearer ${getToken() || ''}`,
}))

const applyEditorHtml = () => {
    const ed = editorRef.value as any
    if (ed && form.content) {
        ed.setHtml(form.content)
    }
}

const handleCreated = (editor: any) => {
    editorRef.value = editor
    applyEditorHtml()
}

const form = reactive({
    title: '',
    description: '',
    cover: '',
    content: '',
})

const handleUploadSuccess = (res: any) => {
    if (res.code === '200') {
        form.cover = res.data
        ElMessage.success('封面上传成功')
    } else {
        ElMessage.error(res.msg || '上传失败')
    }
}

const goBack = () => {
    router.push('/admin/guide')
}

const loadForEdit = async () => {
    const id = route.params.id
    if (!id) return
    pageLoading.value = true
    try {
        const res = await axios.get(`/api/guide/admin/${id}`, {
            headers: { Authorization: `Bearer ${getToken()}` },
        })
        if (res.data.code === '200' && res.data.data) {
            const d = res.data.data
            form.title = d.title ?? ''
            form.description = d.description ?? ''
            form.cover = d.cover ?? ''
            form.content = d.content ?? ''
            await nextTick()
            applyEditorHtml()
        } else {
            ElMessage.error(res.data.msg || '加载失败')
            router.push('/admin/guide')
        }
    } catch {
        ElMessage.error('加载失败')
        router.push('/admin/guide')
    } finally {
        pageLoading.value = false
    }
}

onMounted(() => {
    if (isEdit.value) {
        loadForEdit()
    }
})

const submit = async () => {
    if (!form.title?.trim() || !form.content?.trim()) {
        ElMessage.error('标题和内容不能为空')
        return
    }
    submitting.value = true
    try {
        if (isEdit.value) {
            const id = route.params.id
            const res = await axios.put(`/api/guide/admin/${id}`, form, {
                headers: { Authorization: `Bearer ${getToken()}` },
            })
            if (res.data.code === '200') {
                ElMessage.success('已保存')
                router.push('/admin/guide')
            } else {
                ElMessage.error(res.data.msg || '保存失败')
            }
        } else {
            const res = await axios.post('/api/guide/admin', form, {
                headers: { Authorization: `Bearer ${getToken()}` },
            })
            if (res.data.code === '200') {
                ElMessage.success('发布成功')
                router.push('/admin/guide')
            } else {
                ElMessage.error(res.data.msg || '发布失败')
            }
        }
    } catch {
        ElMessage.error(isEdit.value ? '保存失败' : '发布失败')
    } finally {
        submitting.value = false
    }
}

onBeforeUnmount(() => {
    const editor = editorRef.value as any
    if (editor) editor.destroy()
})
</script>

<style scoped>
.guide-create-page {
    padding: 20px;
    width: 100%;
    box-sizing: border-box;
}

.card {
    padding: 20px;
}

.head-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
}

.page-title {
    margin: 0;
    font-size: 22px;
    font-weight: 600;
    color: #333;
}

.preview {
    width: 200px;
    height: 120px;
    object-fit: cover;
    border-radius: 6px;
    margin-left: 20px;
    border: 1px solid #ddd;
    vertical-align: middle;
}

.editor-container {
    border: 1px solid #ddd;
}
</style>
