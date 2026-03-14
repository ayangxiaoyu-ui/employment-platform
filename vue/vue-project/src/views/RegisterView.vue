<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import { getDefaultRouteLocation, setToken } from '@/utils/auth'

type ApiResult<T> = {
  code: string
  msg: string
  data: T
}

type SysUser = {
  id?: number
  username?: string
  password?: string
  role?: 'ADMIN' | 'COMPANY' | 'STUDENT'
  status?: number
}

const router = useRouter()

const username = ref('')
const password = ref('')
const confirmPassword = ref('')
const role = ref<SysUser['role']>('STUDENT')

const loading = ref(false)
const errorMsg = ref('')

const canSubmit = computed(() => {
  if (loading.value) return false
  if (!username.value.trim()) return false
  if (!password.value) return false
  if (password.value !== confirmPassword.value) return false
  if (!role.value) return false
  return true
})

async function handleRegister() {
  errorMsg.value = ''
  if (!canSubmit.value) {
    errorMsg.value = '请完整填写注册信息'
    return
  }

  loading.value = true
  try {
    const registerResp = await fetch('/auth/register', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        username: username.value.trim(),
        password: password.value,
        role: role.value,
      } satisfies SysUser),
    })

    if (!registerResp.ok) {
      errorMsg.value = `请求失败：${registerResp.status}`
      return
    }

    const registerResult = (await registerResp.json()) as ApiResult<SysUser>
    if (registerResult.code !== '200') {
      errorMsg.value = registerResult.msg || '注册失败'
      return
    }

    const loginResp = await fetch('/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        username: username.value.trim(),
        password: password.value,
      }),
    })

    if (!loginResp.ok) {
      errorMsg.value = `注册成功但登录失败：${loginResp.status}`
      return
    }

    const loginResult = (await loginResp.json()) as ApiResult<string>
    if (loginResult.code !== '200') {
      errorMsg.value = loginResult.msg || '注册成功但登录失败'
      return
    }

    setToken(loginResult.data)
    await router.replace(getDefaultRouteLocation(loginResult.data))
  } catch (e) {
    errorMsg.value = e instanceof Error ? e.message : '网络异常'
  } finally {
    loading.value = false
  }
}

async function goLogin() {
  await router.push({ name: 'login' })
}
</script>

<template>
  <main class="register-page">
    <div class="card">
      <h1 class="title">注册</h1>

      <form class="form" @submit.prevent="handleRegister">
        <label class="field">
          <span class="label">用户名</span>
          <input v-model="username" class="input" autocomplete="username" placeholder="请输入用户名" />
        </label>

        <label class="field">
          <span class="label">密码</span>
          <input v-model="password" class="input" type="password" autocomplete="new-password" placeholder="请输入密码" />
        </label>

        <label class="field">
          <span class="label">确认密码</span>
          <input v-model="confirmPassword" class="input" type="password" autocomplete="new-password"
            placeholder="请再次输入密码" />
        </label>

        <div class="field">
          <span class="label">角色</span>
          <div class="radio-group">
            <label class="radio">
              <input v-model="role" type="radio" value="STUDENT" />
              <span>学生</span>
            </label>
            <label class="radio">
              <input v-model="role" type="radio" value="COMPANY" />
              <span>企业</span>
            </label>
          </div>
        </div>

        <p v-if="errorMsg" class="error">{{ errorMsg }}</p>

        <button class="btn" type="submit" :disabled="!canSubmit">
          {{ loading ? '注册中...' : '注册并登录' }}
        </button>

        <button class="link-btn" type="button" @click="goLogin">已有账号？去登录</button>
      </form>
    </div>
  </main>
</template>

<style scoped>
.register-page {
  min-height: calc(100vh - 80px);
  display: grid;
  place-items: center;
  padding: 24px;
  background: linear-gradient(135deg, #f0f4ff 0%, #e6f0ff 100%);
  /* 与登录页一致的浅蓝渐变背景 */
}

.card {
  width: 100%;
  max-width: 420px;
  /* 与登录页一致，更精致 */
  background: white;
  border-radius: 20px;
  padding: 40px 32px;
  box-shadow: 0 20px 40px rgba(1, 104, 209, 0.15);
  /* 主色阴影 */
  border: 1px solid rgba(1, 104, 209, 0.08);
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

.input {
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

.input:focus {
  border-color: #0168d1;
  box-shadow: 0 0 0 3px rgba(1, 104, 209, 0.15);
  background: white;
}

.radio-group {
  display: flex;
  gap: 24px;
  align-items: center;
  margin-top: 8px;
}

.radio {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 15px;
  color: #2c3e50;
  cursor: pointer;
  user-select: none;
}

.radio input[type="radio"] {
  width: 18px;
  height: 18px;
  accent-color: #0168d1;
  /* 选中时蓝色 */
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
  margin-top: 16px;
}

.link-btn:hover {
  background: rgba(1, 104, 209, 0.08);
  border-color: #4a90e2;
  color: #4a90e2;
  transform: translateY(-1px);
}
</style>