<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import { getDefaultRouteLocation, setToken } from '@/utils/auth'

type ApiResult<T> = {
  code: string
  msg: string
  data: T
}

const router = useRouter()

const username = ref('')
const password = ref('')
const selectedRole = ref<'STUDENT' | 'COMPANY' | 'ADMIN' | ''>('')  // 默认空

const loading = ref(false)
const errorMsg = ref('')

const roles = [
  { value: 'STUDENT', label: '学生' },
  { value: 'COMPANY', label: '企业' },
  { value: 'ADMIN',    label: '管理员' }
]

const canSubmit = computed(() => 
  username.value.trim().length > 0 && 
  password.value.length > 0 && 
  selectedRole.value !== '' && 
  !loading.value
)

async function handleLogin() {
  errorMsg.value = ''

  if (!canSubmit.value) {
    errorMsg.value = '请填写用户名、密码并选择角色'
    return
  }

  loading.value = true
  try {
    const resp = await fetch('/auth/login', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        username: username.value.trim(),
        password: password.value,
        role: selectedRole.value   // 新增：传选择的角色
      }),
    })

    if (!resp.ok) {
      errorMsg.value = `请求失败：${resp.status}`
      return
    }

    const result = (await resp.json()) as ApiResult<string>
    if (result.code !== '200') {
      errorMsg.value = result.msg || '登录失败'
      return
    }

    const token = result.data
    if (!token) {
      errorMsg.value = '登录失败：未收到 token'
      return
    }

    setToken(token)
    await router.replace(getDefaultRouteLocation(token))
  } catch (e) {
    errorMsg.value = e instanceof Error ? e.message : '网络异常'
  } finally {
    loading.value = false
  }
}

async function goRegister() {
  await router.push({ name: 'register' })
}
</script>

<template>
  <main class="login-page">
    <div class="card">
      <h1 class="title">登录</h1>

      <form class="form" @submit.prevent="handleLogin">
        <label class="field">
          <span class="label">用户名</span>
          <input v-model="username" class="input" autocomplete="username" placeholder="请输入用户名" />
        </label>

        <label class="field">
          <span class="label">密码</span>
          <input
            v-model="password"
            class="input"
            type="password"
            autocomplete="current-password"
            placeholder="请输入密码"
          />
        </label>

        <!-- 新增：角色选择 -->
        <label class="field">
          <span class="label">登录角色</span>
          <select v-model="selectedRole" class="input select">
            <option value="" disabled>请选择角色</option>
            <option v-for="role in roles" :key="role.value" :value="role.value">
              {{ role.label }}
            </option>
          </select>
        </label>

        <p v-if="errorMsg" class="error">{{ errorMsg }}</p>

        <button class="btn" type="submit" :disabled="!canSubmit">
          {{ loading ? '登录中...' : '登录' }}
        </button>

        <div class="links">
          <button class="link-btn" type="button" @click="goRegister">没有账号？去注册</button>
          <p class="admin-hint">管理员可直接使用账号密码登录</p>
        </div>
      </form>
    </div>
  </main>
</template>

<style scoped>
.login-page {
  min-height: calc(100vh - 80px);
  display: grid;
  place-items: center;
  padding: 24px;
  background: linear-gradient(135deg, #f0f4ff 0%, #e6f0ff 100%); /* 浅蓝背景渐变 */
}

.card {
  width: 100%;
  max-width: 420px;           /* 稍微窄一点，更精致 */
  background: white;
  border-radius: 20px;
  padding: 40px 32px;
  box-shadow: 0 20px 40px rgba(1, 104, 209, 0.15); /* 主色阴影 */
  border: 1px solid rgba(1, 104, 209, 0.08);
  backdrop-filter: blur(10px); /* 毛玻璃感（可选） */
  transition: all 0.3s ease;
}

.title {
  margin: 0 0 32px;
  font-size: 28px;
  font-weight: 700;
  color: #0168d1;
  text-align: center;
  letter-spacing: 1px;
}

.form {
  display: grid;
  gap: 20px;
}

.field {
  display: grid;
  gap: 8px;
}

.label {
  font-size: 14px;
  font-weight: 500;
  color: #2c3e50;
  opacity: 0.9;
}

.input, .select {
  height: 48px;
  padding: 0 16px;
  border-radius: 12px;
  border: 1px solid #d1d9e6;
  background: #f8faff;
  color: #2c3e50;
  font-size: 15px;
  transition: all 0.3s ease;
  outline: none;
}

.input:focus,
.select:focus {
  border-color: #0168d1;
  box-shadow: 0 0 0 3px rgba(1, 104, 209, 0.15);
  background: white;
}

.select {
  appearance: none;
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='12' viewBox='0 0 12 12'%3E%3Cpath fill='%230168d1' d='M6 9L2 5h8z'/%3E%3C/svg%3E");
  background-repeat: no-repeat;
  background-position: right 16px center;
  padding-right: 40px;
}

.error {
  margin: 0;
  color: #e74c3c;
  font-size: 13px;
  text-align: center;
  padding: 8px 0;
}

.btn {
  height: 48px;
  border: none;
  border-radius: 12px;
  background: linear-gradient(90deg, #0168d1 0%, #4a90e2 100%);
  color: white;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(1, 104, 209, 0.25);
}

.btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(1, 104, 209, 0.35);
  background: linear-gradient(90deg, #0056b3 0%, #3a7bd5 100%);
}

.btn:disabled {
  background: #a0c4ff;
  cursor: not-allowed;
  box-shadow: none;
  transform: none;
}

.links {
  display: flex;
  flex-direction: column;
  gap: 12px;
  align-items: center;
  margin-top: 16px;
}

.link-btn {
  height: 48px;
  width: 100%;
  border-radius: 12px;
  border: 1px solid #0168d1;
  background: transparent;
  color: #0168d1;
  font-size: 15px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.link-btn:hover {
  background: rgba(1, 104, 209, 0.08);
  border-color: #4a90e2;
  color: #4a90e2;
  transform: translateY(-1px);
}

.admin-hint {
  margin: 0;
  font-size: 13px;
  color: #7f8c8d;
  text-align: center;
  opacity: 0.8;
}
</style>