<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
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

const router = useRouter()
const isEditing = ref(false)
const loading = ref(false)

// 从 token 获取用户名，作为默认姓名
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
      // 如果后端没返回数据，至少把 token 的用户名作为默认姓名
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
        // 优先使用后端返回的 name，如果后端没存 name，则用 token 中的用户名
        name: data.name || usernameFromToken.value || '',
        gender: data.gender || '',
        phone: data.phone || '',
        email: data.email || '',
        university: data.university || '',
        major: data.major || '',
        graduationYear: data.graduationYear || null,
        avatar: data.avatar || '',
      }
      formBackup.value = { ...form.value }
    } else {
      // 后端返回异常时，也至少显示 token 中的用户名
      form.value.name = usernameFromToken.value
    }
  } catch (error) {
    ElMessage.error('网络错误：' + (error instanceof Error ? error.message : '未知错误'))
    // 出错时也显示 token 用户名
    form.value.name = usernameFromToken.value
  } finally {
    loading.value = false
  }
}

function startEdit() {
  isEditing.value = true
  formBackup.value = { ...form.value }
}

function cancelEdit() {
  form.value = { ...formBackup.value }
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
    } else {
      ElMessage.error(result.msg || '保存失败')
    }
  } catch (error) {
    ElMessage.error('网络错误：' + (error instanceof Error ? error.message : '未知错误'))
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="student-profile">
    <div class="container">
      <h1>学生个人中心</h1>

      <div v-loading="loading" class="profile-card">
        <div class="header">
          <h2>个人信息</h2>
          <div>
            <el-button v-if="!isEditing" type="primary" @click="startEdit">编辑</el-button>
            <template v-else>
              <el-button type="primary" @click="saveProfile">保存</el-button>
              <el-button @click="cancelEdit">取消</el-button>
            </template>
          </div>
        </div>

        <div class="form-container">
          <!-- 已移除原来的用户名显示行 -->

          <div class="form-item">
            <span class="label">姓名</span>
            <input
              v-model="form.name"
              :readonly="!isEditing"
              class="input"
              :class="{ 'input-edit': isEditing }"
              placeholder="请输入姓名"
            />
          </div>

          <div class="form-item">
            <span class="label">性别</span>
            <select
              v-model="form.gender"
              :disabled="!isEditing"
              class="input"
              :class="{ 'input-edit': isEditing }"
            >
              <option value="">请选择性别</option>
              <option value="男">男</option>
              <option value="女">女</option>
              <option value="其他">其他</option>
            </select>
          </div>

          <div class="form-item">
            <span class="label">联系电话</span>
            <input
              v-model="form.phone"
              :readonly="!isEditing"
              type="tel"
              class="input"
              :class="{ 'input-edit': isEditing }"
              placeholder="请输入联系电话"
            />
          </div>

          <div class="form-item">
            <span class="label">邮箱</span>
            <input
              v-model="form.email"
              :readonly="!isEditing"
              type="email"
              class="input"
              :class="{ 'input-edit': isEditing }"
              placeholder="请输入邮箱"
            />
          </div>

          <div class="form-item">
            <span class="label">毕业院校</span>
            <input
              v-model="form.university"
              :readonly="!isEditing"
              class="input"
              :class="{ 'input-edit': isEditing }"
              placeholder="请输入毕业院校"
            />
          </div>

          <div class="form-item">
            <span class="label">专业</span>
            <input
              v-model="form.major"
              :readonly="!isEditing"
              class="input"
              :class="{ 'input-edit': isEditing }"
              placeholder="请输入专业"
            />
          </div>

          <div class="form-item">
            <span class="label">毕业年份</span>
            <input
              v-model.number="form.graduationYear"
              :readonly="!isEditing"
              type="number"
              class="input"
              :class="{ 'input-edit': isEditing }"
              placeholder="请输入毕业年份"
            />
          </div>

          <div class="form-item">
            <span class="label">头像URL</span>
            <input
              v-model="form.avatar"
              :readonly="!isEditing"
              type="url"
              class="input"
              :class="{ 'input-edit': isEditing }"
              placeholder="请输入头像URL"
            />
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
  max-width: 600px; /* 手机端更友好，宽度不要太宽 */
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
  gap: 28px; /* 每行之间更大间距，看起来更舒服 */
}

.form-item {
  display: flex;
  flex-direction: column;
  gap: 8px;
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