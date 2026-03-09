<template>
    <div
      :class="[
        'relative flex-col h-full border-r-[1px] border-line duration-300 ease-in-out bg-white',
        isCollapsed ? 'w-[80px]' : 'w-[272px]'
      ]"
    >
      <!-- 收起按钮 -->
      <div
        v-if="!isCollapsed"
        class="absolute cursor-pointer z-[10] right-[-1px] top-[20px] py-[8px] px-[4px] rounded-tl-[12px] rounded-bl-[12px] border border-[#E1E4EA]"
        @click="isCollapsed = true"
      >
        <div class="w-[20px] h-[20px]">
          <ArrowLeftSvg />
        </div>
      </div>
  
      <img src="../assets/logo.svg" alt="logo" class="w-[100px] h-[100px]" />
      
      <RouterList 
        :is-collapsed="isCollapsed" 
        @update:is-collapsed="val => isCollapsed = val" 
      />
  
      <div class="px-[20px]">
        <div class="bg-[#E1E4EA] h-[1px]" />
      </div>
  
      <UserProfile :is-collapsed="isCollapsed" />
    </div>
  </template>
  
  <script setup lang="ts">
  import { ref, onMounted, onUnmounted, watch } from 'vue';
  import ArrowLeftSvg from "@/assets/sidebar/arrow-left.svg"; // 注意：Vue中SVG加载方式取决于你的插件配置
  import Logo from "@/assets/logo.svg";
  import RouterList from "./RouterList.vue";
  import UserProfile from "./UserProfile.vue";
  
  // 状态定义
  const isCollapsed = ref(false);
  const isSmallScreen = ref(false);
  
  // 窗口尺寸监听逻辑
  const handleResize = () => {
    isSmallScreen.value = window.innerWidth < 1280;
  };
  
  onMounted(() => {
    handleResize();
    window.addEventListener("resize", handleResize);
  });
  
  onUnmounted(() => {
    window.removeEventListener("resize", handleResize);
  });
  
  // 监听小屏幕变化，自动收起
  watch(isSmallScreen, (newValue) => {
    if (newValue) {
      isCollapsed.value = true;
    }
  });
  </script>
  