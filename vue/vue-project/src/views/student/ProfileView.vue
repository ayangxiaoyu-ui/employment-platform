<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getToken, getUsernameFromToken } from '@/utils/auth'
import { House } from '@element-plus/icons-vue'

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

const router = useRouter()
const isEditing = ref(false)
const loading = ref(false)

// 从 token 获取用户名，作为默认姓名 fallback
const usernameFromToken = computed(() => getUsernameFromToken(getToken() || '') || '未知用户')

const form = ref<StudentProfile>({
  name: '',
  gender: '',
  phone: '',
  email: '',
  university: '',
  major: '',
  graduationYear: null,
  avatar: '',
})

const formBackup = ref<StudentProfile>({ ...form.value })

// 头像文件 & 预览
const avatarFile = ref<File | null>(null)
const avatarPreview = ref<string>('')

// 默认头像文字（姓氏首字母）
const defaultAvatarText = computed(() => {
  const name = (form.value.name || usernameFromToken.value || '').trim()
  if (!name || name === '未知用户') return '匿'

  // 优先取第一个中文字符
  const chineseMatch = name.match(/^[\u4e00-\u9fa5]/)
  if (chineseMatch) return chineseMatch[0]

  // 英文或其他 → 取首字母大写（支持名字缩写如 John Smith → J）
  const cleaned = name.replace(/\s+/g, '')
  return cleaned[0]?.toUpperCase() || '?'
})

onMounted(() => {
  if (!getToken()) {
    router.push({ name: 'login' })
    return
  }
  fetchStudentProfile()
})

async function fetchStudentProfile() {
  loading.value = true
  try {
    const response = await fetch('/api/student/profile', {
      headers: {
        'Authorization': `Bearer ${getToken()}`,
      },
    })

    if (!response.ok) {
      ElMessage.error('获取学生信息失败')
      form.value.name = usernameFromToken.value
      return
    }

    const result = await response.json()
    console.log('后端完整响应:', result)

    if (result.code === '200' && result.data) {
      const data = result.data
      form.value = {
        id: data.id,
        userId: data.userId,
        name: data.name || usernameFromToken.value || '',
        gender: data.gender || '',
        phone: data.phone || '',
        email: data.email || '',
        university: data.university || '',
        major: data.major || '',
        graduationYear: data.graduationYear || null,
        avatar: data.avatar || '',
      }
      avatarPreview.value = data.avatar ? `http://localhost:9999${data.avatar}` : ''
      formBackup.value = { ...form.value }
    } else {
      form.value.name = usernameFromToken.value
    }
  } catch (error) {
    ElMessage.error('网络错误：' + (error instanceof Error ? error.message : '未知错误'))
    form.value.name = usernameFromToken.value
  } finally {
    loading.value = false
  }
}

// 触发文件选择
function triggerFileInput() {
  const input = document.getElementById('avatar-upload') as HTMLInputElement
  if (input) input.click()
}

// 处理头像上传
async function handleAvatarChange(e: Event) {
  const target = e.target as HTMLInputElement
  const file = target.files?.[0]
  if (!file) return

  if (!file.type.startsWith('image')) {
    ElMessage.error('只允许上传图片文件')
    return
  }
  if (file.size > 5 * 1024 * 1024) {
    ElMessage.error('文件大小不能超过 5MB')
    return
  }

  avatarFile.value = file

  // 本地预览
  const reader = new FileReader()
  reader.onload = (ev) => {
    avatarPreview.value = ev.target?.result as string
  }
  reader.readAsDataURL(file)

  // 上传到服务器
  loading.value = true
  try {
    const formData = new FormData()
    formData.append('file', file)
    formData.append('userId', form.value.userId?.toString() || '1') // ★ 请确保这里有正确的 userId 来源

    const response = await fetch('http://localhost:9999/file/upload/avatar', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${getToken()}`,
      },
      body: formData,
    })

    if (!response.ok) {
      ElMessage.error('头像上传失败')
      return
    }

    const result = await response.json()
    if (result.code === '200') {
      ElMessage.success('头像上传成功')
      form.value.avatar = result.data.replace('http://localhost:9999', '') // 存相对路径
      avatarPreview.value = `http://localhost:9999${form.value.avatar}`
    } else {
      ElMessage.error(result.msg || '上传失败')
    }
  } catch (error) {
    ElMessage.error('上传出错：' + (error instanceof Error ? error.message : '未知错误'))
  } finally {
    loading.value = false
    target.value = ''
  }
}

function startEdit() {
  isEditing.value = true
  formBackup.value = { ...form.value }
}

function cancelEdit() {
  form.value = { ...formBackup.value }
  avatarPreview.value = form.value.avatar ? `http://localhost:9999${form.value.avatar}` : ''
  isEditing.value = false
}

async function saveProfile() {
  loading.value = true
  try {
    const response = await fetch('/api/student/profile', {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${getToken()}`,
      },
      body: JSON.stringify(form.value),
    })

    if (!response.ok) {
      ElMessage.error('保存失败')
      return
    }

    const result = await response.json()
    if (result.code === '200') {
      ElMessage.success('保存成功')
      isEditing.value = false
      formBackup.value = { ...form.value }
      avatarPreview.value = form.value.avatar ? `http://localhost:9999${form.value.avatar}` : ''
    } else {
      ElMessage.error(result.msg || '保存失败')
    }
  } catch (error) {
    ElMessage.error('网络错误：' + (error instanceof Error ? error.message : '未知错误'))
  } finally {
    loading.value = false
  }
}

function goToHome() {
  router.push({ name: 'student' }) // 或写死路径：router.push('/')
}
</script>

<template>
  <div class="student-profile">
    <div class="container">
      <h1 class="title">学生个人中心</h1>

      <div v-loading="loading" class="profile-card">
        <div class="header">
          <h2>个人信息</h2>
          <div class="actions">
            <el-button type="info" plain :icon="House" @click="goToHome">
              返回主页
            </el-button>
            <el-button v-if="!isEditing" type="primary" @click="startEdit">编辑</el-button>
            <template v-else>
              <el-button type="primary" @click="saveProfile">保存</el-button>
              <el-button @click="cancelEdit">取消</el-button>
            </template>
          </div>
        </div>

        <div class="form-container">
          <!-- 头像 -->
          <div class="form-item avatar-item">
            <div class="avatar-preview">
              <img v-if="avatarPreview" :src="avatarPreview" alt="头像" class="avatar-img" />
              <div v-else class="avatar-default">
                {{ defaultAvatarText }}
              </div>
            </div>

            <input id="avatar-upload" type="file" accept="image/*" style="display: none" @change="handleAvatarChange" />

            <el-button v-if="isEditing" type="primary" plain size="small" @click="triggerFileInput">
              上传新头像
            </el-button>
            <span class="label">头像</span>

          </div>

          <!-- 其他字段 -->
          <div class="form-item">
            <span class="label">姓名</span>
            <input v-model="form.name" :disabled="!isEditing" class="input" :class="{ 'input-edit': isEditing }"
              placeholder="请输入姓名" />
          </div>

          <div class="form-item">
            <span class="label">性别</span>
            <select v-model="form.gender" :disabled="!isEditing" class="input select"
              :class="{ 'input-edit': isEditing }">
              <option value="">请选择性别</option>
              <option value="男">男</option>
              <option value="女">女</option>
              <option value="其他">其他</option>
            </select>
          </div>

          <div class="form-item">
            <span class="label">联系电话</span>
            <input v-model="form.phone" :disabled="!isEditing" type="tel" class="input"
              :class="{ 'input-edit': isEditing }" placeholder="请输入联系电话" />
          </div>

          <div class="form-item">
            <span class="label">邮箱</span>
            <input v-model="form.email" :disabled="!isEditing" type="email" class="input"
              :class="{ 'input-edit': isEditing }" placeholder="请输入邮箱" />
          </div>

          <div class="form-item">
            <span class="label">毕业院校</span>
            <input v-model="form.university" :disabled="!isEditing" class="input" :class="{ 'input-edit': isEditing }"
              placeholder="请输入毕业院校" />
          </div>

          <div class="form-item">
            <span class="label">专业</span>
            <input v-model="form.major" :disabled="!isEditing" class="input" :class="{ 'input-edit': isEditing }"
              placeholder="请输入专业" />
          </div>

          <div class="form-item">
            <span class="label">毕业年份</span>
            <input v-model.number="form.graduationYear" :disabled="!isEditing" type="number" class="input"
              :class="{ 'input-edit': isEditing }" placeholder="请输入毕业年份" />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.student-profile {
  min-height: calc(100vh - 80px);
  padding: 32px 16px;
  background: linear-gradient(135deg, #f0f4ff 0%, #e6f0ff 100%);
  display: flex;
  justify-content: center;
}

.container {
  width: 100%;
  max-width: 600px;
}

.title {
  margin: 0 0 32px;
  font-size: 28px;
  font-weight: 700;
  color: #0168d1;
  text-align: center;
}

.profile-card {
  background: white;
  border-radius: 16px;
  padding: 32px 24px;
  box-shadow: 0 10px 30px rgba(1, 104, 209, 0.12);
  border: 1px solid rgba(1, 104, 209, 0.06);
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 32px;
}

.header h2 {
  margin: 0;
  font-size: 24px;
  color: #2c3e50;
}

.actions {
  display: flex;
  gap: 12px;
}

.form-container {
  display: flex;
  flex-direction: column;
  gap: 28px;
}

.form-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.avatar-item {
  align-items: center;
}

.avatar-preview {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  overflow: hidden;
  background: #e6f0ff;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 12px;
  border: 2px solid #a3d0ff;
  position: relative;
}

.avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-default {
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 52px;
  font-weight: 500;
  color: #409eff;
  background: linear-gradient(135deg, #a3d0ff 0%, #e6f0ff 100%);
  user-select: none;
}

.label {
  font-size: 15px;
  font-weight: 500;
  color: #34495e;
}

.input,
.select {
  height: 50px;
  padding: 0 16px;
  border-radius: 10px;
  border: 1px solid #d1d9e6;
  background: #f9fcff;
  color: #2c3e50;
  font-size: 15px;
  transition: all 0.3s ease;
}

.input:focus,
.select:focus {
  border-color: #0168d1;
  box-shadow: 0 0 0 3px rgba(1, 104, 209, 0.12);
  outline: none;
  background: white;
}

.input-edit {
  background: white;
  border-color: #0168d1;
}

.select {
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%230168d1' d='M6 9L2 5h8z'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 16px center;
  padding-right: 40px;
}
</style>