<template>
  <div class="student-profile-container">
    <div class="main-layout">
      <aside class="sidebar">
        <div class="user-info-brief">
          <div class="avatar-wrapper">
            <img v-if="avatarPreview" :src="avatarPreview" class="side-avatar" />
            <div v-else class="side-avatar-default">{{ defaultAvatarText }}</div>
          </div>
          <p class="nickname">{{ form.name || '未登录用户' }}</p>
        </div>

        <nav class="menu-nav">
          <div v-for="item in menuItems" :key="item.key" class="menu-item" :class="{ active: activeTab === item.key }"
            @click="activeTab = item.key">
            <el-icon>
              <component :is="item.icon" />
            </el-icon>
            <span>{{ item.label }}</span>
          </div>
        </nav>

        <div class="sidebar-footer">
          <el-button type="info" plain :icon="House" @click="goToHome" class="w-full">
            返回主页
          </el-button>
        </div>
      </aside>

      <main class="content-body" v-loading="loading">
        <section v-if="activeTab === 'info'" class="content-card">
          <div class="card-header">
            <h3>基本信息</h3>
            <div class="btns">
              <el-button v-if="!isEditing" type="primary" @click="startEdit">编辑资料</el-button>
              <template v-else>
                <el-button type="success" @click="saveProfile">保存</el-button>
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
                <el-input v-model="form.name" :disabled="!isEditing" placeholder="请填写姓名" />
              </div>
              <div class="form-group">
                <label>性别</label>
                <el-select v-model="form.gender" :disabled="!isEditing" placeholder="选择性别">
                  <el-option label="男" value="男" />
                  <el-option label="女" value="女" />
                </el-select>
              </div>
              <div class="form-group">
                <label>电话</label>
                <el-input v-model="form.phone" :disabled="!isEditing" />
              </div>
              <div class="form-group">
                <label>邮箱</label>
                <el-input v-model="form.email" :disabled="!isEditing" />
              </div>
              <div class="form-group">
                <label>学校</label>
                <el-input v-model="form.university" :disabled="!isEditing" />
              </div>
              <div class="form-group">
                <label>专业</label>
                <el-input v-model="form.major" :disabled="!isEditing" />
              </div>
            </div>
          </div>
        </section>

        <section v-if="activeTab === 'resume'" class="content-card">
          <div class="card-header">
            <h3>我的简历</h3>
            <el-upload class="upload-box" action="http://localhost:9999/api/resume/upload" name="file"
              :data="{ studentId: studentId }" :on-success="handleSuccess" :show-file-list="false">
              <el-button type="primary">上传简历</el-button>
            </el-upload>
          </div>
          <div class="resume-list">
            <div v-for="res in resumes" :key="res.id" class="resume-card">
              <div class="res-icon"><el-icon>
                  <Document />
                </el-icon></div>
              <div class="res-info">
                <h4>{{ res.name || '附件简历' }}</h4>
                <p>更新时间：{{ res.updateTime || '2024-03-10' }}</p>
              </div>
              <div class="res-actions">
                <el-button link type="primary" @click="previewResume(res)">预览</el-button>
                <el-button link type="danger">删除</el-button>
              </div>
            </div>
            <el-empty v-if="resumes.length === 0" description="暂无简历，请先上传" />
          </div>
        </section>

        <section v-if="activeTab === 'apply'" class="content-card">
          <h3>投递动态</h3>
          <div class="delivery-timeline">
            <el-table :data="deliveryData" style="width: 100%">
              <el-table-column prop="company" label="公司" />
              <el-table-column prop="position" label="岗位" />
              <el-table-column label="当前状态">
                <template #default="scope">
                  <el-tag :type="getStatusType(scope.row.status)">{{ scope.row.status }}</el-tag>
                </template>
              </el-table-column>
              <el-table-column prop="date" label="投递日期" />
            </el-table>
          </div>
        </section>

        <section v-if="activeTab === 'message'" class="content-card">
          <h3>消息中心</h3>
          <div class="message-list">
            <div class="msg-item unread">
              <div class="msg-dot"></div>
              <div class="msg-content">
                <p><strong>系统通知：</strong> 您的简历已被【字节跳动】HR查看。</p>
                <span>2小时前</span>
              </div>
            </div>
          </div>
        </section>
      </main>
      <el-dialog v-model="previewVisible" title="简历预览" width="80%" destroy-on-close>
        <iframe v-if="currentPreviewUrl" :src="currentPreviewUrl" width="100%" height="600px" frameborder="0">
        </iframe>
        <div v-else style="text-align: center; padding: 20px;">加载中或无预览内容...</div>
      </el-dialog>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { House, User, Document, Promotion, Star, ChatDotRound, Setting, Plus, Camera } from '@element-plus/icons-vue'
import { getToken, getUsernameFromToken } from '@/utils/auth'
// 预览相关的响应式变量
const previewVisible = ref(false)
const currentPreviewUrl = ref('')


// 类型定义
interface StudentProfile {
  id?: number; userId?: number; name: string; gender: string; phone: string;
  email: string; university: string; major: string; graduationYear: number | null; avatar: string;
}

const router = useRouter()
const activeTab = ref('info')
const loading = ref(false)
const isEditing = ref(false)

// 菜单配置
const menuItems = [
  { key: 'info', label: '个人信息', icon: User },
  { key: 'resume', label: '简历管理', icon: Document },
  { key: 'apply', label: '我的投递', icon: Promotion },
  { key: 'favorite', label: '我的收藏', icon: Star },
  { key: 'message', label: '互动消息', icon: ChatDotRound },
  // { key: 'setting', label: '账号设置', icon: Setting },
]

// 数据
const form = ref<StudentProfile>({ name: '', gender: '', phone: '', email: '', university: '', major: '', graduationYear: null, avatar: '' })
const studentId = ref<number | null>(null)
const formBackup = ref<StudentProfile>({ ...form.value })
const resumes = ref<any[]>([])
const avatarPreview = ref('')
const deliveryData = ref([
  { company: '腾讯', position: '前端开发工程师', status: '面试中', date: '2024-03-01' },
  { company: '阿里巴巴', position: 'Java实习生', status: '简历筛选', date: '2024-03-05' }
])

// 计算属性
const usernameFromToken = computed(() => getUsernameFromToken(getToken() || '') || '未知用户')
const defaultAvatarText = computed(() => {
  const name = (form.value.name || usernameFromToken.value || '匿').trim()
  return name.match(/^[\u4e00-\u9fa5]/) ? name[0] : name[0].toUpperCase()
})

// 方法
const fetchProfile = async () => {
  loading.value = true
  try {
    const res = await fetch('/api/student/profile', {
      headers: { 'Authorization': `Bearer ${getToken()}` }
    })
    const result = await res.json()
    if (result.code === '200' && result.data) {
      form.value = { ...result.data, name: result.data.name || usernameFromToken.value }
      avatarPreview.value = result.data.avatar ? `http://localhost:9999${result.data.avatar}` : ''

      // ⭐⭐ 关键：这里同步 studentId ⭐⭐
      studentId.value = result.data.id
      console.log("加载到 studentId =", studentId.value)
    }
  } finally {
    loading.value = false
  }
}


const fetchResumes = async () => {
  if (!form.value.id) return
  const res = await fetch(`/api/resume/student/${form.value.id}`, { headers: { 'Authorization': `Bearer ${getToken()}` } })
  const result = await res.json()
  console.log(form.value.id);

  if (result.code === '200') {
    resumes.value = result.data
    console.log(resumes.value);

  }
}

/**
 * 预览简历逻辑
 * @param res 这里的 res 是从 v-for="res in resumes" 传进来的单条简历对象
 */
function previewResume(res: any) {
  // 1. 获取文件路径字段（根据你的后端字段名修改，可能是 res.url 或 res.filePath）
  const path = res.url || res.path || res.fileUrl;

  if (!path) {
    ElMessage.warning('该简历没有关联的文件路径')
    return
  }

  // 2. 拼接完整的后端访问地址
  // 如果后端存的是绝对路径则不需拼接，如果是相对路径则需要拼接 http://localhost:9999
  const baseUrl = 'http://localhost:9999'
  currentPreviewUrl.value = path.startsWith('http') ? path : `${baseUrl}${path}`
  console.log(currentPreviewUrl.value);

  // 3. 打开弹窗
  previewVisible.value = true
}
const handleSuccess = async (res: any) => {
  if (res.code !== 200) {
    ElMessage.error(res.msg || '上传失败')
    return
  }

  // 后端返回的访问路径，例如：/uploads/resume/resume_12_史奕辰.pdf
  const fileUrl = res.data

  // 你需要把 fileUrl 存入数据库（新增简历记录）
  const saveRes = await fetch('/api/resume', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${getToken()}`
    },
    body: JSON.stringify({
      studentId: form.value.id,
      fileUrl: fileUrl,
      title: '我的简历',
      isPublic: 1
    })
  })

  const saveResult = await saveRes.json()

  if (saveResult.code === 200) {
    ElMessage.success('上传成功')
    fetchResumes()   // 刷新简历列表
  } else {
    ElMessage.error('保存简历记录失败')
  }
}


// 监听 Tab 切换
watch(activeTab, (newTab) => {
  if (newTab === 'resume') fetchResumes()
})

onMounted(() => {
  if (!getToken()) return router.push({ name: 'login' })
  fetchProfile()
})

// 基础功能函数
const startEdit = () => { isEditing.value = true; formBackup.value = { ...form.value } }
const cancelEdit = () => { isEditing.value = false; form.value = { ...formBackup.value } }
const triggerFileInput = () => document.getElementById('avatar-upload')?.click()
const goToHome = () => router.push({ name: 'student' })
const getStatusType = (status: string) => {
  if (status === '面试中') return 'warning'
  if (status === '录用') return 'success'
  return 'info'
}

// 保存个人资料
async function saveProfile() {
  loading.value = true
  try {
    const res = await fetch('/api/student/profile', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${getToken()}` },
      body: JSON.stringify(form.value),
    })
    const result = await res.json()
    if (result.code === '200') {
      ElMessage.success('保存成功')
      isEditing.value = false
    }
  } finally { loading.value = false }
}

// 处理头像上传
async function handleAvatarChange(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0]
  if (!file) return
  const formData = new FormData()
  formData.append('file', file)
  formData.append('userId', form.value.userId?.toString() || '')

  try {
    const res = await fetch('http://localhost:9999/file/upload/avatar', {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${getToken()}` },
      body: formData
    })
    const result = await res.json()
    if (result.code === '200') {
      form.value.avatar = result.data.replace('http://localhost:9999', '')
      avatarPreview.value = `http://localhost:9999${form.value.avatar}`
      ElMessage.success('头像上传成功')
    }
  } catch (e) { ElMessage.error('上传失败') }
}
</script>

<style scoped>
.student-profile-container {
  min-height: 100vh;
  background-color: #f5f7fa;
  padding: 20px;
}

.main-layout {
  max-width: 1100px;
  margin: 0 auto;
  display: flex;
  gap: 20px;
}

/* 侧边栏样式 */
.sidebar {
  width: 240px;
  background: white;
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  padding: 24px 0;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  height: fit-content;
}

.user-info-brief {
  text-align: center;
  padding-bottom: 24px;
  border-bottom: 1px solid #f0f0f0;
  margin-bottom: 12px;
}

.avatar-wrapper {
  width: 80px;
  height: 80px;
  margin: 0 auto 12px;
  border-radius: 50%;
  overflow: hidden;
  border: 2px solid #409eff;
}

.side-avatar,
.side-avatar-default {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #e6f0ff;
  color: #409eff;
  font-size: 32px;
}

.nickname {
  font-weight: bold;
  color: #333;
}

.menu-nav {
  flex: 1;
}

.menu-item {
  display: flex;
  align-items: center;
  padding: 14px 24px;
  gap: 12px;
  cursor: pointer;
  color: #606266;
  transition: all 0.3s;
}

.menu-item:hover {
  background-color: #f0f7ff;
  color: #409eff;
}

.menu-item.active {
  background-color: #ecf5ff;
  color: #409eff;
  border-right: 3px solid #409eff;
}

.sidebar-footer {
  padding: 12px 24px;
}

/* 内容区样式 */
.content-body {
  flex: 1;
}

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

/* 头像上传特化 */
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

/* 简历列表样式 */
.resume-card {
  display: flex;
  align-items: center;
  padding: 16px;
  border: 1px solid #f0f0f0;
  border-radius: 8px;
  margin-bottom: 12px;
  transition: 0.3s;
}

.resume-card:hover {
  border-color: #409eff;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.res-icon {
  font-size: 32px;
  color: #909399;
  margin-right: 16px;
}

.res-info {
  flex: 1;
}

.res-info h4 {
  margin: 0 0 4px;
}

.res-info p {
  margin: 0;
  font-size: 12px;
  color: #999;
}

/* 消息样式 */
.msg-item {
  display: flex;
  padding: 16px;
  border-bottom: 1px solid #f5f5f5;
  align-items: flex-start;
  gap: 12px;
}

.msg-dot {
  width: 8px;
  height: 8px;
  background: #f56c6c;
  border-radius: 50%;
  margin-top: 6px;
}
</style>