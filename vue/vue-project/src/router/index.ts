import { createRouter, createWebHistory } from 'vue-router'
import { getDefaultRouteLocation, getRoleFromToken, getToken } from '@/utils/auth'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'root',
      redirect: '/login',
    },
    {
      path: "/companies",
      name: "companies",
      component: () => import('../views/CompanyList.vue'),
    },
    {
      path: '/company/:id',
      name: 'CompanyDetail',
      component: () => import('@/views/CompanyDetail.vue')
    },
    {
      path: '/company/jobs',
      name: 'companyJobs',
      component: () => import('../views/company/jobs.vue'),
    },
    {
      path: '/company/resumes',
      name: 'companyResumes',
      component: () => import('../views/company/resumes.vue'),
    },
    {
      path: '/admin/users',
      name: 'adminUsers',
      component: () => import('../views/admin/users.vue'),
    },
    {
      path: '/admin/settings',
      name: 'adminSettings',
      component: () => import('../views/admin/settings.vue'),
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('../views/LoginView.vue'),
    },
    {
      path: '/register',
      name: 'register',
      component: () => import('../views/RegisterView.vue'),
    },
    {
      path: '/student',
      name: 'student',
      component: () => import('../views/DashboardView.vue'),
      props: { role: 'STUDENT' },
      meta: { requiresAuth: true, role: 'STUDENT' },
    },
    {
      path: '/student/profile',
      name: 'studentProfile',
      component: () => import('../views/student/ProfileView.vue'),
      meta: { requiresAuth: true, role: 'STUDENT' },
    },
    {
      path: '/company',
      name: 'company',
      component: () => import('../views/DashboardView.vue'),
      props: { role: 'COMPANY' },
      meta: { requiresAuth: true, role: 'COMPANY' },
    },
    {
      path: '/company/profile',
      name: 'companyProfile',
      component: () => import('../views/company/ProfileView.vue'),
      meta: { requiresAuth: true, role: 'COMPANY' },
    },
    {
      path: '/admin',
      name: 'admin',
      component: () => import('../views/DashboardView.vue'),
      props: { role: 'ADMIN' },
      meta: { requiresAuth: true, role: 'ADMIN' },
    },
    {
      path: '/:pathMatch(.*)*',
      redirect: '/login',
    },
    {
      path: '/recruit',
      name: 'RecruitList',
      component: () => import('@/views/student/RecruitList.vue')
    }

  ],
})

router.beforeEach((to, from) => {
  const token = getToken()
  const toMeta = to.meta as { requiresAuth?: boolean; role?: string } | undefined

  if ((to.name === 'login' || to.name === 'register') && token) {
    return getDefaultRouteLocation(token)
  }

  if (toMeta?.requiresAuth && !token) {
    return { name: 'login' }
  }

  if (toMeta?.requiresAuth && token && toMeta?.role) {
    const role = getRoleFromToken(token)
    if (!role || role !== toMeta.role) {
      return getDefaultRouteLocation(token)
    }
  }

  if (to.name === 'root') {
    if (!token) return { name: 'login' }
    return getDefaultRouteLocation(token)
  }

  return true
})

export default router
