import { ref } from 'vue'

export type UserRole = 'ADMIN' | 'COMPANY' | 'STUDENT'

// 使用响应式引用存储 token
const tokenRef = ref<string | null>(localStorage.getItem('token'))

export function getToken(): string | null {
  return tokenRef.value
}

export function setToken(token: string) {
  localStorage.setItem('token', token)
  tokenRef.value = token
}

export function clearToken() {
  localStorage.removeItem('token')
  tokenRef.value = null
}

export function getRoleFromToken(token: string): UserRole | null {
  const payload = parseJwtPayload(token)
  const role = payload?.role
  if (role === 'ADMIN' || role === 'COMPANY' || role === 'STUDENT') return role
  return null
}

export function getUsernameFromToken(token: string): string | null {
  const payload = parseJwtPayload(token)
  const username = payload?.username
  return typeof username === 'string' && username.trim() ? username : null
}

export function getDefaultRouteLocation(token: string | null): { name: string } {
  if (!token) return { name: 'login' }
  const role = getRoleFromToken(token)
  if (role === 'ADMIN') return { name: 'adminDashboard' }
  if (role === 'COMPANY') return { name: 'company' }
  if (role === 'STUDENT') return { name: 'student' }
  return { name: 'login' }
}

function parseJwtPayload(token: string): Record<string, unknown> | null {
  const parts = token.split('.')
  if (parts.length < 2) return null

  const payloadPart = parts[1]
  if (!payloadPart) return null
  const json = decodeBase64Url(payloadPart)
  if (!json) return null

  try {
    const parsed = JSON.parse(json) as unknown
    if (parsed && typeof parsed === 'object' && !Array.isArray(parsed)) {
      return parsed as Record<string, unknown>
    }
    return null
  } catch {
    return null
  }
}

function decodeBase64Url(input: string): string | null {
  try {
    const normalized = input.replace(/-/g, '+').replace(/_/g, '/')
    const padded = normalized.padEnd(Math.ceil(normalized.length / 4) * 4, '=')
    const binary = atob(padded)
    const bytes = Uint8Array.from(binary, (c) => c.charCodeAt(0))
    return new TextDecoder().decode(bytes)
  } catch {
    return null
  }
}
