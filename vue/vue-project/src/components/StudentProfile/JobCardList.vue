<template>
    <div class="job-list">
        <JobCard v-for="item in jobs" :key="item.id" :job="item" @open-detail="$emit('open-detail', item.id)" />
    </div>
</template>

<script setup>
import JobCard from './JobCard.vue'

const props = defineProps({
    jobs: {
        type: Array,
        required: true
    }
})

</script>

<style scoped>
.job-list {
    display: flex;
    flex-direction: column;
    gap: 16px;
}
</style>
