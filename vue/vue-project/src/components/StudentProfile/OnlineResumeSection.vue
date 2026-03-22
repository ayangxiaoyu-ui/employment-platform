<template>
  <section class="online-resume-card content-card">
    <div class="card-header">
      <div>
        <h3>在线简历</h3>
        <p class="sub">填写后可在投递时选择，企业可查看结构化内容</p>
      </div>
      <div class="header-meta" v-if="onlineResumeId">
        <span class="muted">最近保存：{{ updateTimeText }}</span>
      </div>
    </div>

    <el-form :model="fields" label-width="96px" class="online-form" v-loading="loading">
      <el-row :gutter="20">
        <el-col :xs="24" :md="12">
          <el-form-item label="简历标题">
            <el-input v-model="resumeTitle" placeholder="默认：在线简历" maxlength="50" show-word-limit />
          </el-form-item>
        </el-col>
        <el-col :xs="24" :md="12">
          <el-form-item label="公开投递">
            <el-switch v-model="isPublicBool" active-text="允许用于投递" inactive-text="仅自己可见" />
          </el-form-item>
        </el-col>
      </el-row>

      <el-divider content-position="left">基本信息</el-divider>
      <el-row :gutter="20">
        <el-col :xs="24" :md="8">
          <el-form-item label="姓名">
            <el-input v-model="fields.name" placeholder="姓名" />
          </el-form-item>
        </el-col>
        <el-col :xs="24" :md="8">
          <el-form-item label="学校">
            <el-input v-model="fields.school" placeholder="学校" />
          </el-form-item>
        </el-col>
        <el-col :xs="24" :md="8">
          <el-form-item label="专业">
            <el-input v-model="fields.major" placeholder="专业" />
          </el-form-item>
        </el-col>
      </el-row>
      <el-row :gutter="20">
        <el-col :xs="24" :md="8">
          <el-form-item label="GPA">
            <el-input v-model="fields.gpa" placeholder="如 3.6" />
          </el-form-item>
        </el-col>
        <el-col :xs="24" :md="8">
          <el-form-item label="排名">
            <el-input v-model="fields.rank" placeholder="如 前 10%" />
          </el-form-item>
        </el-col>
        <el-col :xs="24" :md="8">
          <el-form-item label="技术栈">
            <el-input v-model="fields.tech" placeholder="熟悉的技术与工具" />
          </el-form-item>
        </el-col>
      </el-row>

      <el-divider content-position="left">经历与评价</el-divider>
      <el-form-item label="实习经历">
        <el-input v-model="fields.intern" type="textarea" :rows="3" placeholder="实习公司、岗位、时间与成果" />
      </el-form-item>
      <el-form-item label="项目经历">
        <el-input v-model="fields.project" type="textarea" :rows="4" placeholder="项目名称、职责、技术要点" />
      </el-form-item>
      <el-form-item label="证书">
        <el-input v-model="fields.cert" type="textarea" :rows="2" placeholder="证书、竞赛、语言成绩等" />
      </el-form-item>
      <el-form-item label="自我评价">
        <el-input v-model="fields.eval" type="textarea" :rows="3" placeholder="简要总结优势与求职意向" />
      </el-form-item>

      <div class="form-actions">
        <el-button type="primary" :loading="saving" @click="handleSave">保存在线简历</el-button>
        <el-button @click="loadOnlineResume" :disabled="loading || saving">重新加载</el-button>
      </div>
    </el-form>
  </section>
</template>

<script setup lang="ts">
import { ref, reactive, watch, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { getToken } from '@/utils/auth'

interface Props {
  studentId: number | null
}

const props = defineProps<Props>()

const emptyFields = () => ({
  name: '',
  school: '',
  major: '',
  gpa: '',
  rank: '',
  tech: '',
  intern: '',
  project: '',
  cert: '',
  eval: ''
})

const fields = reactive(emptyFields())
const resumeTitle = ref('在线简历')
const isPublicBool = ref(true)
const onlineResumeId = ref<number | null>(null)
const updateTimeRaw = ref<string | null>(null)
const loading = ref(false)
const saving = ref(false)
const updateTimeText = computed(() => {
  if (!updateTimeRaw.value) return '—'
  return String(updateTimeRaw.value).replace('T', ' ').slice(0, 16)
})

const applyProfileHints = async () => {
  try {
    const res = await fetch('/api/student/profile', {
      headers: { Authorization: `Bearer ${getToken()}` }
    })
    const result = await res.json()
    if (result.code !== '200' || !result.data) return
    const d = result.data
    if (!fields.name) fields.name = d.name || ''
    if (!fields.school) fields.school = d.university || ''
    if (!fields.major) fields.major = d.major || ''
  } catch {
    /* 忽略，仅作预填 */
  }
}

const parseContent = (raw: string | null | undefined) => {
  if (!raw) return
  try {
    const o = JSON.parse(raw) as Record<string, string>
    Object.assign(fields, { ...emptyFields(), ...o })
  } catch {
    ElMessage.warning('在线简历数据格式异常，已重置为空白')
    Object.assign(fields, emptyFields())
  }
}

const loadOnlineResume = async () => {
  if (props.studentId == null) return
  loading.value = true
  try {
    const res = await fetch(`/api/resume/student/${props.studentId}`, {
      headers: { Authorization: `Bearer ${getToken()}` }
    })
    const result = await res.json()
    if (result.code !== '200') {
      ElMessage.error(result.msg || '加载在线简历失败')
      return
    }
    const list = (result.data || []) as any[]
    const onlines = list.filter((r) => r.type === 1)
    const online = onlines.sort(
      (a, b) => new Date(b.updateTime).getTime() - new Date(a.updateTime).getTime()
    )[0]
    if (online) {
      onlineResumeId.value = Number(online.id)
      resumeTitle.value = online.title || '在线简历'
      isPublicBool.value = online.isPublic === 1
      updateTimeRaw.value = online.updateTime ?? null
      parseContent(online.content)
    } else {
      onlineResumeId.value = null
      resumeTitle.value = '在线简历'
      isPublicBool.value = true
      updateTimeRaw.value = null
      Object.assign(fields, emptyFields())
      await applyProfileHints()
    }
  } catch {
    ElMessage.error('加载在线简历失败')
  } finally {
    loading.value = false
  }
}

const handleSave = async () => {
  if (props.studentId == null) {
    ElMessage.warning('请先完成登录与学生信息加载')
    return
  }
  saving.value = true
  try {
    const content = JSON.stringify(fields)
    const body: Record<string, unknown> = {
      studentId: props.studentId,
      title: resumeTitle.value?.trim() || '在线简历',
      content,
      isPublic: isPublicBool.value ? 1 : 0
    }
    if (onlineResumeId.value != null) {
      body.id = onlineResumeId.value
    }
    const res = await fetch('/api/resume/online', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${getToken()}`
      },
      body: JSON.stringify(body)
    })
    const result = await res.json()
    if (result.code === '200') {
      ElMessage.success('在线简历已保存')
      if (result.data?.id != null) {
        onlineResumeId.value = Number(result.data.id)
      }
      await loadOnlineResume()
    } else {
      ElMessage.error(result.msg || '保存失败')
    }
  } catch {
    ElMessage.error('保存失败')
  } finally {
    saving.value = false
  }
}

watch(
  () => props.studentId,
  (id) => {
    if (id != null) loadOnlineResume()
    else {
      onlineResumeId.value = null
      Object.assign(fields, emptyFields())
    }
  },
  { immediate: true }
)

defineExpose({ loadOnlineResume })
</script>

<style scoped>
.online-resume-card {
  margin-bottom: 20px;
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
  align-items: flex-start;
  margin-bottom: 20px;
  gap: 16px;
}

.card-header h3 {
  margin: 0 0 6px;
  font-size: 18px;
}

.sub {
  margin: 0;
  font-size: 13px;
  color: #909399;
}

.header-meta .muted {
  font-size: 12px;
  color: #a8abb2;
}

.online-form :deep(.el-divider__text) {
  font-weight: 600;
  color: #606266;
}

.form-actions {
  margin-top: 8px;
  display: flex;
  gap: 12px;
}
</style>
