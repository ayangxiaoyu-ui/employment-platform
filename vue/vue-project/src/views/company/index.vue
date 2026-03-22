<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import { ElMessage } from 'element-plus'
import { getToken } from '@/utils/auth'
import {
  DataAnalysis,
  Document,
  Briefcase,
  Calendar,
  View,
  ChatDotRound,
  CircleClose,
  SuccessFilled,
  Right,
  Reading,
  School,
} from '@element-plus/icons-vue'

const router = useRouter()
const loading = ref(true)

interface RecentRow {
  applicationId: number
  jobId: number
  studentId: number
  resumeId?: number | null
  jobTitle: string
  studentName: string
  status: number
  createTime: string
}

interface DashboardData {
  totalApplications: number
  last7DaysApplications: number
  pendingViewCount: number
  viewedCount: number
  interviewCount: number
  rejectedCount: number
  hiredCount: number
  openJobCount: number
  recentApplications: RecentRow[]
}

const stats = ref<DashboardData>({
  totalApplications: 0,
  last7DaysApplications: 0,
  pendingViewCount: 0,
  viewedCount: 0,
  interviewCount: 0,
  rejectedCount: 0,
  hiredCount: 0,
  openJobCount: 0,
  recentApplications: [],
})

const loadDashboard = async () => {
  if (!getToken()) {
    router.push({ name: 'login' })
    return
  }
  loading.value = true
  try {
    const res = await axios.get('/api/application/company/dashboard', {
      headers: { Authorization: `Bearer ${getToken()}` },
    })
    if (res.data.code === '200' && res.data.data) {
      const d = res.data.data
      stats.value = {
        totalApplications: Number(d.totalApplications) || 0,
        last7DaysApplications: Number(d.last7DaysApplications) || 0,
        pendingViewCount: Number(d.pendingViewCount) || 0,
        viewedCount: Number(d.viewedCount) || 0,
        interviewCount: Number(d.interviewCount) || 0,
        rejectedCount: Number(d.rejectedCount) || 0,
        hiredCount: Number(d.hiredCount) || 0,
        openJobCount: Number(d.openJobCount) || 0,
        recentApplications: d.recentApplications || [],
      }
    } else {
      ElMessage.error(res.data.msg || '加载看板失败')
    }
  } catch {
    ElMessage.error('加载看板失败')
  } finally {
    loading.value = false
  }
}

const statusText = (s: number) =>
  (
    {
      0: '待查看',
      1: '已查看',
      2: '面试邀请',
      3: '不合适',
      4: '已录用',
    } as Record<number, string>
  )[s] || '未知'

const statusTagType = (s: number) => {
  switch (s) {
    case 2:
      return 'warning'
    case 4:
      return 'success'
    case 3:
      return 'danger'
    case 1:
      return 'primary'
    default:
      return 'info'
  }
}

const formatTime = (t: string) => {
  if (!t) return '—'
  return String(t).replace('T', ' ').slice(0, 16)
}

const goInbox = () => router.push('/company/resumes')
const goJobs = () => router.push('/company/jobs')
const goProfile = () => router.push('/company/profile')
const goMessages = () => router.push('/company/messages')
const goGuide = () => router.push('/company/guide')
const goStudents = () => router.push('/company/students')

const openResume = (row: RecentRow) => {
  if (row.resumeId) {
    router.push(`/company/student/${row.studentId}?resumeId=${row.resumeId}`)
  } else {
    router.push(`/company/student/${row.studentId}`)
  }
}

onMounted(() => {
  loadDashboard()
})
</script>

<template>
  <div class="company-home" v-loading="loading">
    <div class="page-head">
      <div>
        <h1 class="page-title">企业工作台</h1>
        <p class="page-sub">投递与岗位数据总览，快捷进入常用功能</p>
      </div>
      <el-button type="primary" :icon="Right" @click="goInbox">简历收件箱</el-button>
    </div>

    <!-- 核心指标 -->
    <el-row :gutter="16" class="stat-row">
      <el-col :xs="24" :sm="12" :lg="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-inner">
            <el-icon class="stat-icon primary"><DataAnalysis /></el-icon>
            <div>
              <div class="stat-value">{{ stats.totalApplications }}</div>
              <div class="stat-label">投递总数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :lg="6">
        <el-card class="stat-card warn" shadow="hover">
          <div class="stat-inner">
            <el-icon class="stat-icon warning"><Document /></el-icon>
            <div>
              <div class="stat-value">{{ stats.pendingViewCount }}</div>
              <div class="stat-label">待查看简历</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :lg="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-inner">
            <el-icon class="stat-icon success"><Briefcase /></el-icon>
            <div>
              <div class="stat-value">{{ stats.openJobCount }}</div>
              <div class="stat-label">在招岗位数</div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="12" :lg="6">
        <el-card class="stat-card" shadow="hover">
          <div class="stat-inner">
            <el-icon class="stat-icon info"><Calendar /></el-icon>
            <div>
              <div class="stat-value">{{ stats.last7DaysApplications }}</div>
              <div class="stat-label">近 7 日新增投递</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 投递状态分布 -->
    <el-card class="section-card" shadow="never">
      <template #header>
        <span class="section-title">投递状态分布</span>
      </template>
      <el-row :gutter="12">
        <el-col :xs="12" :sm="8" :md="4">
          <div class="mini-stat">
            <el-icon class="mini-ic"><View /></el-icon>
            <span class="mini-val">{{ stats.viewedCount }}</span>
            <span class="mini-lab">已查看</span>
          </div>
        </el-col>
        <el-col :xs="12" :sm="8" :md="4">
          <div class="mini-stat">
            <el-icon class="mini-ic warn"><ChatDotRound /></el-icon>
            <span class="mini-val">{{ stats.interviewCount }}</span>
            <span class="mini-lab">面试邀请</span>
          </div>
        </el-col>
        <el-col :xs="12" :sm="8" :md="4">
          <div class="mini-stat">
            <el-icon class="mini-ic danger"><CircleClose /></el-icon>
            <span class="mini-val">{{ stats.rejectedCount }}</span>
            <span class="mini-lab">不合适</span>
          </div>
        </el-col>
        <el-col :xs="12" :sm="8" :md="4">
          <div class="mini-stat">
            <el-icon class="mini-ic ok"><SuccessFilled /></el-icon>
            <span class="mini-val">{{ stats.hiredCount }}</span>
            <span class="mini-lab">已录用</span>
          </div>
        </el-col>
      </el-row>
    </el-card>

    <el-row :gutter="16">
      <el-col :xs="24" :lg="16">
        <el-card class="section-card" shadow="never">
          <template #header>
            <div class="card-head-flex">
              <span class="section-title">最近投递</span>
              <el-button type="primary" link @click="goInbox">查看全部</el-button>
            </div>
          </template>
          <el-table :data="stats.recentApplications" stripe style="width: 100%" empty-text="暂无投递记录">
            <el-table-column prop="studentName" label="学生" min-width="100" />
            <el-table-column prop="jobTitle" label="应聘岗位" min-width="140" show-overflow-tooltip />
            <el-table-column label="状态" width="110">
              <template #default="{ row }">
                <el-tag :type="statusTagType(row.status)" size="small">{{ statusText(row.status) }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="投递时间" width="170">
              <template #default="{ row }">
                {{ formatTime(row.createTime) }}
              </template>
            </el-table-column>
            <el-table-column label="操作" width="100" fixed="right">
              <template #default="{ row }">
                <el-button type="primary" link @click="openResume(row)">查看</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-card>
      </el-col>
      <el-col :xs="24" :lg="8">
        <el-card class="section-card shortcuts" shadow="never">
          <template #header>
            <span class="section-title">快捷入口</span>
          </template>
          <div class="shortcut-list">
            <div class="shortcut-item" @click="goInbox">
              <el-icon><Document /></el-icon>
              <span>简历收件箱</span>
              <el-icon class="arrow"><Right /></el-icon>
            </div>
            <div class="shortcut-item" @click="goStudents">
              <el-icon><School /></el-icon>
              <span>学生库</span>
              <el-icon class="arrow"><Right /></el-icon>
            </div>
            <div class="shortcut-item" @click="goJobs">
              <el-icon><Briefcase /></el-icon>
              <span>发布与管理职位</span>
              <el-icon class="arrow"><Right /></el-icon>
            </div>
            <div class="shortcut-item" @click="goMessages">
              <el-icon><ChatDotRound /></el-icon>
              <span>互动消息</span>
              <el-icon class="arrow"><Right /></el-icon>
            </div>
            <div class="shortcut-item" @click="goProfile">
              <el-icon><View /></el-icon>
              <span>企业资料 / 个人中心</span>
              <el-icon class="arrow"><Right /></el-icon>
            </div>
            <div class="shortcut-item" @click="goGuide">
              <el-icon><Reading /></el-icon>
              <span>就业指导</span>
              <el-icon class="arrow"><Right /></el-icon>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<style scoped>
.company-home {
  width: 100%;
  box-sizing: border-box;
}

.page-head {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 16px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.page-title {
  margin: 0 0 6px;
  font-size: 22px;
  font-weight: 600;
  color: #303133;
}

.page-sub {
  margin: 0;
  font-size: 13px;
  color: #909399;
}

.stat-row {
  margin-bottom: 16px;
}

.stat-card {
  margin-bottom: 16px;
  border-radius: 8px;
}

.stat-inner {
  display: flex;
  align-items: center;
  gap: 16px;
}

.stat-icon {
  font-size: 40px;
  color: #409eff;
}

.stat-icon.warning {
  color: #e6a23c;
}

.stat-icon.success {
  color: #67c23a;
}

.stat-icon.info {
  color: #909399;
}

.stat-value {
  font-size: 26px;
  font-weight: 700;
  color: #303133;
  line-height: 1.2;
}

.stat-label {
  font-size: 13px;
  color: #909399;
  margin-top: 4px;
}

.section-card {
  margin-bottom: 16px;
  border-radius: 8px;
}

.section-title {
  font-weight: 600;
  color: #303133;
}

.card-head-flex {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.mini-stat {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 12px 8px;
  background: #f8f9fc;
  border-radius: 8px;
  margin-bottom: 8px;
}

.mini-ic {
  font-size: 22px;
  color: #409eff;
  margin-bottom: 6px;
}

.mini-ic.warn {
  color: #e6a23c;
}

.mini-ic.danger {
  color: #f56c6c;
}

.mini-ic.ok {
  color: #67c23a;
}

.mini-val {
  font-size: 20px;
  font-weight: 700;
  color: #303133;
}

.mini-lab {
  font-size: 12px;
  color: #909399;
  margin-top: 4px;
}

.shortcut-list {
  display: flex;
  flex-direction: column;
  gap: 0;
}

.shortcut-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 12px;
  border-radius: 8px;
  cursor: pointer;
  transition: background 0.2s;
}

.shortcut-item:hover {
  background: #f0f5ff;
}

.shortcut-item .el-icon:first-child {
  font-size: 20px;
  color: #409eff;
}

.shortcut-item span {
  flex: 1;
  font-size: 14px;
  color: #606266;
}

.shortcut-item .arrow {
  color: #c0c4cc;
}
</style>
