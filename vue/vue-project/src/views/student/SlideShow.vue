<!-- src/components/Slideshow.vue -->
<template>
  <div class="slideshow-container">
    <swiper
      :modules="[Navigation, Pagination, Autoplay]"
      :slides-per-view="1"
      :space-between="0"
      :loop="true"
      :autoplay="{
        delay: 4000,
        disableOnInteraction: false,
      }"
      :pagination="{ clickable: true }"
      :navigation="true"
      @swiper="onSwiper"
      @slideChange="onSlideChange"
      class="my-swiper"
    >
      <swiper-slide v-for="(slide, index) in slides" :key="index">
        <img
          :src="slide"
          alt="輪播圖"
          class="w-full h-full object-cover"
        />
      </swiper-slide>
    </swiper>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { Swiper, SwiperSlide } from 'swiper/vue'
import { Navigation, Pagination, Autoplay } from 'swiper/modules'

import 'swiper/css'
import 'swiper/css/navigation'
import 'swiper/css/pagination'

import slideshow1 from '@/assets/slideshowImage/slideshow1.jpg'
import slideshow2 from '@/assets/slideshowImage/slideshow2.jpg'
import slideshow3 from '@/assets/slideshowImage/slideshow3.png'

const slides = ref([slideshow1, slideshow2, slideshow3])

const onSwiper = (swiper) => {
  console.log('Swiper 初始化完成', swiper)
}
const onSlideChange = () => {
  console.log('slide 切換了')
}
</script>

<style scoped>
.slideshow-container {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  aspect-ratio: 16 / 9;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
}

.my-swiper {
  width: 100%;
  height: 100%;
}

/* ── 分頁點 ── */
:deep(.swiper-pagination-bullet) {
  background: white;
  opacity: 0.7;
  width: 10px;
  height: 10px;
}
:deep(.swiper-pagination-bullet-active) {
  background: #3b82f6; /* blue-500 */
  opacity: 1;
  width: 28px;
}

/* ── 導航箭頭 ── */
:deep(.swiper-button-next),
:deep(.swiper-button-prev) {
  /* 核心尺寸控制 */
  --swiper-navigation-size: 44px !important;   /* 整體按鈕大小（點擊區域） */
  width: var(--swiper-navigation-size) !important;
  height: var(--swiper-navigation-size) !important;
  
  /* 背景與形狀 */
  background: rgba(0, 0, 0, 0.45);
  border-radius: 50%;
  color: white !important;
  
  /* 位置微調（可選） */
  top: 50%;
  transform: translateY(-50%);
  margin-top: 0 !important;
}

/* 箭頭符號本身的大小（← →） */
:deep(.swiper-button-next:after),
:deep(.swiper-button-prev:after) {
  font-size: 28px !important;          /* 改這裡控制箭頭符號大小 */
  font-weight: bold;
}

/* hover 效果 */
:deep(.swiper-button-next:hover),
:deep(.swiper-button-prev:hover) {
  background: rgba(0, 0, 0, 0.7);
  transition: background 0.2s;
}

/* 手機上稍微大一點（可選） */

</style>