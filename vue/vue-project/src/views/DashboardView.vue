<script setup lang="ts">
import { computed } from 'vue'
import { type UserRole } from '@/utils/auth'
import StudentView from './student/index.vue'
import CompanyView from './company/index.vue'
import AdminView from './admin/index.vue'

const props = defineProps<{
  role: UserRole
}>()

const viewComponent = computed(() => {
  if (props.role === 'ADMIN') return AdminView
  if (props.role === 'COMPANY') return CompanyView
  return StudentView
})
</script>

<template>
  <div class=" mx-auto px-4 py-4">
    <component :is="viewComponent" />
  </div>
</template>

<style scoped>

</style>

