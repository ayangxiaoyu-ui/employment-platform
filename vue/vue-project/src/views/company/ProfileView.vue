<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { getToken } from '@/utils/auth'
import { House } from '@element-plus/icons-vue'

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

// Logo 预览和上传相关
const logoPreview = ref<string>('')

onMounted(() => {
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
      const rawScale = result.data.scale || ''
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
      // 设置 Logo 预览
      logoPreview.value = result.data.logo ? `http://localhost:9999${result.data.logo}` : ''
      formBackup.value = { ...form.value }
      console.log(form.value.scale);
      console.log('原始规模:', rawScale, '→ 标准化后:', form.value.scale)

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
  logoPreview.value = form.value.logo ? `http://localhost:9999${form.value.logo}` : ''
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
      logoPreview.value = form.value.logo ? `http://localhost:9999${form.value.logo}` : ''
    } else {
      ElMessage.error(result.msg || '保存失败')
    }
  } catch (error) {
    ElMessage.error('网络错误：' + (error instanceof Error ? error.message : '未知错误'))
  } finally {
    loading.value = false
  }
}

// 返回主页
function goToHome() {
  router.push('/')
}

// 触发 Logo 文件选择
function triggerLogoInput() {
  const input = document.getElementById('logo-upload') as HTMLInputElement
  if (input) input.click()
}

// 处理 Logo 文件上传
async function handleLogoChange(e: Event) {
  const target = e.target as HTMLInputElement
  const file = target.files?.[0]

  if (!file) return

  // 校验
  if (!file.type.startsWith('image')) {
    ElMessage.error('只允许上传图片文件')
    return
  }
  if (file.size > 3 * 1024 * 1024) {
    ElMessage.error('文件大小不能超过 3MB')
    return
  }

  // 本地预览
  const reader = new FileReader()
  reader.onload = (ev) => {
    logoPreview.value = ev.target?.result as string
  }
  reader.readAsDataURL(file)

  // 立即上传到后端
  loading.value = true
  try {
    const formData = new FormData()
    formData.append('file', file)
    formData.append('userId', form.value.userId?.toString() || '1') // 替换为真实 userId 来源

    const response = await fetch('http://localhost:9999/file/upload/logo', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${getToken()}`,
      },
      body: formData,
    })

    if (!response.ok) {
      throw new Error('上传失败')
    }

    const result = await response.json()
    if (result.code === '200') {
      ElMessage.success('Logo 上传成功')
      // 更新 form.logo 为相对路径（存数据库用）
      form.value.logo = result.data.replace('http://localhost:9999', '')
    } else {
      ElMessage.error(result.msg || '上传失败')
      logoPreview.value = '' // 上传失败，清除预览
    }
  } catch (error) {
    ElMessage.error('上传出错：' + (error instanceof Error ? error.message : '未知错误'))
    logoPreview.value = '' // 出错清除预览
  } finally {
    loading.value = false
    target.value = '' // 清空 input
  }
}
</script>

<template>
  <div class="company-profile-page">
    <el-card class="card" shadow="never">
      <div v-loading="loading" class="card-inner">
        <div class="page-head">
          <div>
            <h1 class="page-title">个人中心</h1>
            <p class="page-sub">维护企业资料，将在学生端企业详情等页面展示</p>
          </div>
          <div class="actions">
            <el-button type="info" plain :icon="House" @click="goToHome">
              返回首页
            </el-button>
            <el-button v-if="!isEditing" type="primary" @click="startEdit">编辑资料</el-button>
            <template v-else>
              <el-button type="primary" @click="saveProfile">保存</el-button>
              <el-button @click="cancelEdit">取消</el-button>
            </template>
          </div>
        </div>

        <h2 class="section-title">企业信息</h2>

        <div class="form-container">
          <!-- Logo 上传区域 -->
          <div class="form-item avatar-item">
            <span class="label">企业 Logo</span>
            <div class="avatar-preview">
              <img v-if="logoPreview" :src="logoPreview" alt="Logo 预览" class="avatar-img" />
              <div v-else class="avatar-placeholder">暂无 Logo</div>
            </div>

            <input id="logo-upload" type="file" accept="image/*" style="display: none" @change="handleLogoChange" />

            <el-button v-if="isEditing" type="primary" plain size="small" @click="triggerLogoInput">
              上传 Logo
            </el-button>
          </div>

          <!-- 企业名称 -->
          <div class="form-item">
            <span class="label">企业名称</span>
            <input v-model="form.name" :disabled="!isEditing" class="input" :class="{ 'input-edit': isEditing }"
              placeholder="请输入企业名称" />
          </div>

          <!-- 企业简介 -->
          <div class="form-item">
            <span class="label">企业简介</span>
            <textarea v-model="form.description" :disabled="!isEditing" class="input textarea"
              :class="{ 'input-edit': isEditing }" placeholder="请输入企业简介" rows="4"></textarea>
          </div>

          <!-- 详细地址 -->
          <div class="form-item">
            <span class="label">详细地址</span>
            <input v-model="form.address" :disabled="!isEditing" class="input" :class="{ 'input-edit': isEditing }"
              placeholder="请输入详细地址" />
          </div>

          <!-- 所属行业 -->
          <div class="form-item">
            <span class="label">所属行业</span>
            <input v-model="form.industry" :disabled="!isEditing" class="input" :class="{ 'input-edit': isEditing }"
              placeholder="请输入所属行业" />
          </div>

          <!-- 人员规模 -->
          <div class="form-item">
            <span class="label">人员规模</span>
            <select v-model="form.scale" :disabled="!isEditing" class="input select"
              :class="{ 'input-edit': isEditing }">
              <option value="">请选择人员规模</option>
              <option value="5000人以下">5000人以下</option>
              <option value="5000-9999人">5000-9999人</option>
              <option value="1-5万人">1-5万人</option>
              <option value="5-10万人">5-10万人</option>
              <option value="10-30万人">10-30万人</option>
              <option value="30-50万人">30-50万人</option>
              <option value="50万人以上">50万人以上</option>
            </select>
          </div>

          <!-- 联系人 -->
          <div class="form-item">
            <span class="label">联系人</span>
            <input v-model="form.contactPerson" :disabled="!isEditing" class="input"
              :class="{ 'input-edit': isEditing }" placeholder="请输入联系人" />
          </div>

          <!-- 联系电话 -->
          <div class="form-item">
            <span class="label">联系电话</span>
            <input v-model="form.contactPhone" :disabled="!isEditing" type="tel" class="input"
              :class="{ 'input-edit': isEditing }" placeholder="请输入联系电话" />
          </div>
        </div>
      </div>
    </el-card>
  </div>
</template>

<style scoped>
.company-profile-page {
  padding: 20px;
  width: 100%;
  box-sizing: border-box;
}

.card {
  border-radius: 8px;
}

.card-inner {
  min-height: 120px;
}

.page-head {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16px;
  margin-bottom: 24px;
  flex-wrap: wrap;
}

.page-title {
  margin: 0 0 8px;
  font-size: 22px;
  font-weight: 600;
  color: #333;
}

.page-sub {
  margin: 0;
  font-size: 13px;
  color: #909399;
  max-width: 420px;
  line-height: 1.5;
}

.section-title {
  margin: 0 0 20px;
  font-size: 16px;
  font-weight: 600;
  color: #303133;
  padding-left: 10px;
  border-left: 4px solid #409eff;
}

.actions {
  display: flex;
  gap: 12px;
  align-items: center;
  flex-shrink: 0;
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
  border-radius: 12px;
  overflow: hidden;
  background: #f0f4ff;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 12px;
  border: 2px dashed #0168d1;
}

.avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.avatar-placeholder {
  color: #a0c4ff;
  font-size: 14px;
  text-align: center;
}

.label {
  font-size: 15px;
  font-weight: 500;
  color: #34495e;
}

.input,
.select,
.textarea {
  padding: 0 16px;
  border-radius: 10px;
  border: 1px solid #d1d9e6;
  background: #f9fcff;
  color: #2c3e50;
  font-size: 15px;
  transition: all 0.3s ease;
  font-family: inherit;
}

.input,
.select {
  height: 50px;
}

.textarea {
  min-height: 100px;
  resize: vertical;
  padding: 12px 16px;
}

.input:focus,
.select:focus,
.textarea:focus {
  border-color: #0168d1;
  box-shadow: 0 0 0 3px rgba(1, 104, 209, 0.12);
  outline: none;
  background: white;
}

.input-edit,
.textarea.input-edit {
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