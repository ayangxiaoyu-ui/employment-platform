<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getToken, getUsernameFromToken } from '@/utils/auth'

interface CompanyProfile {
  id?: number
  userId?: number
  name: string
  description: string
  logo: string
  address: string
  industry: string
  scale: string
  contactPerson: string
  contactPhone: string
}

const router = useRouter()
const isEditing = ref(false)
const loading = ref(false)
const username = computed(() => getUsernameFromToken(getToken() || '') || '未知用户')

const form = ref<CompanyProfile>({
  name: '',
  description: '',
  logo: '',
  address: '',
  industry: '',
  scale: '',
  contactPerson: '',
  contactPhone: '',
})

const formBackup = ref<CompanyProfile>({ ...form.value })

onMounted(() => {
  // 检查认证状态
  if (!getToken()) {
    router.push({ name: 'login' })
    return
  }
  fetchCompanyProfile()
})

async function fetchCompanyProfile() {
  loading.value = true
  try {
    const response = await fetch('/api/company/profile', {
      headers: {
        'Authorization': `Bearer ${getToken()}`,
      },
    })

    if (!response.ok) {
      ElMessage.error('获取企业信息失败')
      return
    }

    const result = await response.json()
    if (result.code === '200' && result.data) {
      form.value = {
        id: result.data.id,
        userId: result.data.userId,
        name: result.data.name || '',
        description: result.data.description || '',
        logo: result.data.logo || '',
        address: result.data.address || '',
        industry: result.data.industry || '',
        scale: result.data.scale || '',
        contactPerson: result.data.contactPerson || '',
        contactPhone: result.data.contactPhone || '',
      }
      formBackup.value = { ...form.value }
    }
  } catch (error) {
    ElMessage.error('网络错误：' + (error instanceof Error ? error.message : '未知错误'))
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
    const response = await fetch('/api/company/profile', {
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
  <div class="company-profile">
    <div class="container">
      <h1>企业个人中心</h1>

      <div v-loading="loading" class="profile-card">
        <div class="header">
          <h2>企业信息</h2>
          <div>
            <el-button v-if="!isEditing" type="primary" @click="startEdit">编辑</el-button>
            <template v-else>
              <el-button type="primary" @click="saveProfile">保存</el-button>
              <el-button @click="cancelEdit">取消</el-button>
            </template>
          </div>
        </div>

        <div class="form-container">
          <div class="form-item">
            <span class="label">用户名</span>
            <span class="value">{{ username }}</span>
          </div>

          <div class="form-item">
            <span class="label">企业名称</span>
            <input
              v-model="form.name"
              :readonly="!isEditing"
              class="input"
              :class="{ 'input-edit': isEditing }"
              placeholder="请输入企业名称"
            />
          </div>

          <div class="form-item">
            <span class="label">企业简介</span>
            <textarea
              v-model="form.description"
              :readonly="!isEditing"
              class="input textarea"
              :class="{ 'input-edit': isEditing }"
              placeholder="请输入企业简介"
              rows="4"
            ></textarea>
          </div>

          <div class="form-item">
            <span class="label">企业Logo</span>
            <input
              v-model="form.logo"
              :readonly="!isEditing"
              type="url"
              class="input"
              :class="{ 'input-edit': isEditing }"
              placeholder="请输入Logo URL"
            />
          </div>

          <div class="form-item">
            <span class="label">详细地址</span>
            <input
              v-model="form.address"
              :readonly="!isEditing"
              class="input"
              :class="{ 'input-edit': isEditing }"
              placeholder="请输入详细地址"
            />
          </div>

          <div class="form-item">
            <span class="label">所属行业</span>
            <input
              v-model="form.industry"
              :readonly="!isEditing"
              class="input"
              :class="{ 'input-edit': isEditing }"
              placeholder="请输入所属行业"
            />
          </div>

          <div class="form-item">
            <span class="label">人员规模</span>
            <select
              v-model="form.scale"
              :disabled="!isEditing"
              class="input"
              :class="{ 'input-edit': isEditing }"
            >
              <option value="">请选择人员规模</option>
              <option value="50人以下">50人以下</option>
              <option value="50-100人">50-100人</option>
              <option value="100-500人">100-500人</option>
              <option value="500-1000人">500-1000人</option>
              <option value="1000人以上">1000人以上</option>
            </select>
          </div>

          <div class="form-item">
            <span class="label">联系人</span>
            <input
              v-model="form.contactPerson"
              :readonly="!isEditing"
              class="input"
              :class="{ 'input-edit': isEditing }"
              placeholder="请输入联系人"
            />
          </div>

          <div class="form-item">
            <span class="label">联系电话</span>
            <input
              v-model="form.contactPhone"
              :readonly="!isEditing"
              type="tel"
              class="input"
              :class="{ 'input-edit': isEditing }"
              placeholder="请输入联系电话"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.company-profile {
  padding: 40px 20px;
  background: #f5f7fa;
  min-height: 100vh;
}

.container {
  max-width: 600px;
  margin: 0 auto;
}

h1 {
  text-align: center;
  margin-bottom: 30px;
  color: #333;
  font-size: 28px;
}

.profile-card {
  background: white;
  border-radius: 8px;
  padding: 30px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  padding-bottom: 20px;
  border-bottom: 1px solid #e0e0e0;
}

.header h2 {
  margin: 0;
  font-size: 20px;
  color: #333;
}

.form-container {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-item {
  display: flex;
  align-items: flex-start;
  gap: 15px;
}

.label {
  min-width: 100px;
  font-weight: 600;
  color: #333;
  flex-shrink: 0;
  padding-top: 10px;
}

.value {
  flex: 1;
  padding: 10px 12px;
  color: #666;
  background: #f9f9f9;
  border-radius: 4px;
  word-break: break-all;
}

.input {
  flex: 1;
  padding: 10px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  background: white;
  transition: border-color 0.3s;
  font-family: inherit;
}

.textarea {
  resize: vertical;
  min-height: 100px;
}

.input:readonly {
  background: #f9f9f9;
  cursor: not-allowed;
  border-color: transparent;
}

.input:disabled {
  background: #f9f9f9;
  cursor: not-allowed;
  border-color: transparent;
}

.input-edit {
  border-color: #0168d1;
  background: white;
}

.input:not(:readonly):focus,
.input-edit:focus {
  outline: none;
  border-color: #0168d1;
  box-shadow: 0 0 0 2px rgba(1, 104, 209, 0.2);
}

:deep(.el-button) {
  margin-left: 10px;
}

:deep(.el-button:first-child) {
  margin-left: 0;
}
</style>
