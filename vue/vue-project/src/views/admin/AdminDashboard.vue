<template>
  <div class="admin-dashboard">
    <el-card class="head-card" shadow="never">
      <h1 class="page-title">数据看板</h1>
      <p class="page-sub">平台核心指标一览（需管理员登录）</p>
    </el-card>

    <el-skeleton v-if="loading" :rows="8" animated />

    <template v-else-if="stats">
      <el-row :gutter="16" class="stat-row">
        <el-col :xs="12" :sm="8" :md="6" :lg="4">
          <el-card shadow="hover" class="stat-card">
            <el-statistic title="学生账号" :value="stats.studentUserCount" />
          </el-card>
        </el-col>
        <el-col :xs="12" :sm="8" :md="6" :lg="4">
          <el-card shadow="hover" class="stat-card">
            <el-statistic title="企业账号" :value="stats.companyUserCount" />
          </el-card>
        </el-col>
        <el-col :xs="12" :sm="8" :md="6" :lg="4">
          <el-card shadow="hover" class="stat-card">
            <el-statistic title="学生档案" :value="stats.studentProfileCount" />
          </el-card>
        </el-col>
        <el-col :xs="12" :sm="8" :md="6" :lg="4">
          <el-card shadow="hover" class="stat-card">
            <el-statistic title="企业档案" :value="stats.companyProfileCount" />
          </el-card>
        </el-col>
        <el-col :xs="12" :sm="8" :md="6" :lg="4">
          <el-card shadow="hover" class="stat-card">
            <el-statistic title="在招岗位" :value="stats.openJobCount" />
          </el-card>
        </el-col>
        <el-col :xs="12" :sm="8" :md="6" :lg="4">
          <el-card shadow="hover" class="stat-card">
            <el-statistic title="岗位总数" :value="stats.totalJobCount" />
          </el-card>
        </el-col>
      </el-row>

      <el-row :gutter="16" class="stat-row">
        <el-col :xs="12" :sm="8" :md="6" :lg="4">
          <el-card shadow="hover" class="stat-card highlight">
            <el-statistic title="投递总数" :value="stats.totalApplications" />
          </el-card>
        </el-col>
        <el-col :xs="12" :sm="8" :md="6" :lg="4">
          <el-card shadow="hover" class="stat-card highlight">
            <el-statistic title="近7天投递" :value="stats.applicationsLast7Days" />
          </el-card>
        </el-col>
        <el-col :xs="12" :sm="8" :md="6" :lg="4">
          <el-card shadow="hover" class="stat-card">
            <el-statistic title="公告" :value="stats.newsCount" />
          </el-card>
        </el-col>
        <el-col :xs="12" :sm="8" :md="6" :lg="4">
          <el-card shadow="hover" class="stat-card">
            <el-statistic title="就业指导" :value="stats.guideCount" />
          </el-card>
        </el-col>
        <el-col :xs="12" :sm="8" :md="6" :lg="4">
          <el-card shadow="hover" class="stat-card">
            <el-statistic title="站内消息" :value="stats.messageCount" />
          </el-card>
        </el-col>
        <el-col :xs="12" :sm="8" :md="6" :lg="4">
          <el-card shadow="hover" class="stat-card">
            <el-statistic title="简历数" :value="stats.resumeCount" />
          </el-card>
        </el-col>
      </el-row>

      <el-card class="trend-card" shadow="never">
        <template #header>
          <span class="trend-title">近7日投递趋势</span>
        </template>
        <div class="trend-chart">
          <div
            v-for="(p, idx) in stats.applicationTrend"
            :key="idx"
            class="trend-col"
          >
            <div
              class="trend-bar"
              :style="{ height: barHeight(p.count) + 'px' }"
              :title="String(p.count)"
            />
            <span class="trend-label">{{ p.label }}</span>
          </div>
        </div>
      </el-card>
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { ElMessage } from 'element-plus'
import { getToken } from '@/utils/auth'

interface DailyPoint {
  label: string
  count: number
}

interface DashboardStats {
  studentUserCount: number
  companyUserCount: number
  studentProfileCount: number
  companyProfileCount: number
  openJobCount: number
  totalJobCount: number
  totalApplications: number
  applicationsLast7Days: number
  newsCount: number
  guideCount: number
  messageCount: number
  resumeCount: number
  applicationTrend: DailyPoint[]
}

const loading = ref(true)
const stats = ref<DashboardStats | null>(null)

const maxTrend = computed(() => {
  const t = stats.value?.applicationTrend
  if (!t?.length) return 1
  return Math.max(1, ...t.map((x) => x.count))
})

const barHeight = (count: number) => {
  const max = maxTrend.value
  const h = max <= 0 ? 0 : Math.round((count / max) * 120)
  return Math.max(count > 0 ? 4 : 0, h)
}

const load = async () => {
  loading.value = true
  try {
    const res = await axios.get('/api/admin/dashboard/stats', {
      headers: { Authorization: `Bearer ${getToken()}` },
    })
    if (res.data.code === '200') {
      stats.value = res.data.data
    } else {
      ElMessage.error(res.data.msg || '加载失败')
    }
  } catch {
    ElMessage.error('加载失败')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  load()
})
</script>

<style scoped>
.admin-dashboard {
  padding: 20px;
  width: 100%;
  box-sizing: border-box;
}

.head-card {
  margin-bottom: 16px;
  border-radius: 8px;
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
  border-radius: 8px;
  margin-bottom: 16px;
}

.stat-card.highlight :deep(.el-statistic__head) {
  color: #409eff;
}

.trend-card {
  border-radius: 8px;
  margin-top: 8px;
}

.trend-title {
  font-weight: 600;
  color: #303133;
}

.trend-chart {
  display: flex;
  align-items: flex-end;
  justify-content: space-between;
  gap: 8px;
  min-height: 160px;
  padding: 8px 4px 0;
}

.trend-col {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  min-width: 0;
}

.trend-bar {
  width: 100%;
  max-width: 48px;
  min-height: 0;
  background: linear-gradient(180deg, #79bbff 0%, #409eff 100%);
  border-radius: 4px 4px 0 0;
  transition: height 0.25s ease;
}

.trend-label {
  margin-top: 8px;
  font-size: 12px;
  color: #909399;
  white-space: nowrap;
}
</style>
