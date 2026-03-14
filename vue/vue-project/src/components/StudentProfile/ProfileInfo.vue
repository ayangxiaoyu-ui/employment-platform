<template>
    <section class="content-card">
        <div class="card-header">
            <h3>基本信息</h3>
            <div class="btns">
                <el-button v-if="!isEditing" type="primary" @click="startEdit">编辑资料</el-button>
                <template v-else>
                    <el-button type="success" @click="handleSave">保存</el-button>
                    <el-button @click="cancelEdit">取消</el-button>
                </template>
            </div>
        </div>

        <div class="info-form">
            <div class="avatar-upload-section">
                <div class="avatar-preview-big">
                    <img v-if="avatarPreview" :src="avatarPreview" />
                    <div v-else class="avatar-default-big">{{ defaultAvatarText }}</div>
                    <div v-if="isEditing" class="upload-mask" @click="triggerFileInput">
                        <el-icon>
                            <Camera />
                        </el-icon>
                        <span>更换头像</span>
                    </div>
                </div>
                <input id="avatar-upload" type="file" accept="image/*" hidden @change="handleAvatarChange" />
            </div>

            <div class="form-grid">
                <div class="form-group">
                    <label>姓名</label>
                    <el-input v-model="formData.name" :disabled="!isEditing" placeholder="请填写姓名" />
                </div>
                <div class="form-group">
                    <label>性别</label>
                    <el-select v-model="formData.gender" :disabled="!isEditing" placeholder="选择性别">
                        <el-option label="男" value="男" />
                        <el-option label="女" value="女" />
                    </el-select>
                </div>
                <div class="form-group">
                    <label>电话</label>
                    <el-input v-model="formData.phone" :disabled="!isEditing" />
                </div>
                <div class="form-group">
                    <label>邮箱</label>
                    <el-input v-model="formData.email" :disabled="!isEditing" />
                </div>
                <div class="form-group">
                    <label>学校</label>
                    <el-input v-model="formData.university" :disabled="!isEditing" />
                </div>
                <div class="form-group">
                    <label>专业</label>
                    <el-input v-model="formData.major" :disabled="!isEditing" />
                </div>
            </div>
        </div>
    </section>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { Camera } from '@element-plus/icons-vue'
import { getToken, getUsernameFromToken } from '@/utils/auth'

interface StudentProfile {
    id?: number
    userId?: number
    name: string
    gender: string
    phone: string
    email: string
    university: string
    major: string
    graduationYear: number | null
    avatar: string
}

interface Props {
    form: StudentProfile
    avatarPreview: string
    usernameFromToken: string
    loading?: boolean
}

const props = defineProps<Props>()

const emit = defineEmits<{
    'update:form': [value: StudentProfile]
    'update:avatarPreview': [value: string]
    'update:loading': [value: boolean]
}>()

const isEditing = ref(false)
const formBackup = ref<StudentProfile>({ ...props.form })
const formData = ref<StudentProfile>({ ...props.form })

const defaultAvatarText = computed(() => {
  const name = (formData.value?.name || props.usernameFromToken || '匿').trim()
  if (!name || name.length === 0) return '匿'
  const isChineseChar = /^[\u4e00-\u9fa5]/.test(name)
  return isChineseChar ? name[0] : name[0].toUpperCase()
})

const startEdit = () => {
  isEditing.value = true
  formBackup.value = { ...formData.value }
}

const cancelEdit = () => {
    isEditing.value = false
    formData.value = { ...formBackup.value }
}

const triggerFileInput = () => {
    document.getElementById('avatar-upload')?.click()
}

const handleAvatarChange = async (e: Event) => {
    const file = (e.target as HTMLInputElement).files?.[0]
    if (!file) return

    const uploadFormData = new FormData()
    uploadFormData.append('file', file)
    uploadFormData.append('userId', formData.value.userId?.toString() || '')

    try {
        emit('update:loading', true)
        const res = await fetch('http://localhost:9999/file/upload/avatar', {
            method: 'POST',
            headers: { 'Authorization': `Bearer ${getToken()}` },
            body: uploadFormData
        })
        const result = await res.json()
        if (result.code === '200') {
            formData.value.avatar = result.data.replace('http://localhost:9999', '')
            emit('update:avatarPreview', `http://localhost:9999${formData.value.avatar}`)
            ElMessage.success('头像上传成功')
        }
    } catch (e) {
        ElMessage.error('上传失败')
    } finally {
        emit('update:loading', false)
    }
}

const handleSave = async () => {
    emit('update:loading', true)
    try {
        const res = await fetch('/api/student/profile', {
            method: 'PUT',
            headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${getToken()}` },
            body: JSON.stringify(formData.value),
        })
        const result = await res.json()
        if (result.code === '200') {
            ElMessage.success('保存成功')
            isEditing.value = false
            emit('update:form', formData.value)
        }
    } finally {
        emit('update:loading', false)
    }
}

// 在 ProfileInfo.vue 的 <script setup> 中添加
watch(() => props.form, (newVal) => {
    // 只有在非编辑状态下才自动同步，避免覆盖用户正在输入的修改
    if (!isEditing.value) {
        formData.value = { ...newVal };
        formBackup.value = { ...newVal };
    }
}, { deep: true, immediate: true });
</script>

<style scoped>
.content-card {
    background: white;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
}

.card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 24px;
}

.form-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
}

.form-group label {
    display: block;
    margin-bottom: 8px;
    font-size: 14px;
    color: #666;
}

.avatar-upload-section {
    display: flex;
    justify-content: center;
    margin-bottom: 30px;
}

.avatar-preview-big {
    width: 120px;
    height: 120px;
    border-radius: 50%;
    position: relative;
    overflow: hidden;
    border: 3px solid #eee;
}

.avatar-preview-big img,
.avatar-default-big {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.avatar-default-big {
    background: #f0f2f5;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 48px;
    color: #999;
}

.upload-mask {
    position: absolute;
    inset: 0;
    background: rgba(0, 0, 0, 0.5);
    color: white;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    opacity: 0;
    transition: 0.3s;
}

.avatar-preview-big:hover .upload-mask {
    opacity: 1;
}
</style>
