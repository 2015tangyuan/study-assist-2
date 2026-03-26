<template>
  <div class="student-layout">
    <router-view />
    
    <van-tabbar v-if="showTabbar" v-model="active" route>
      <van-tabbar-item to="/student" icon="home-o">首页</van-tabbar-item>
      <van-tabbar-item to="/student/report" icon="chart-trending-o">报告</van-tabbar-item>
      <van-tabbar-item to="/student/profile" icon="user-o">我的</van-tabbar-item>
    </van-tabbar>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const active = ref(0)

const showTabbar = computed(() => {
  const hiddenRoutes = ['StudentLogin', 'StudentPractice', 'StudentResult']
  return !hiddenRoutes.includes(route.name)
})
</script>

<style scoped>
.student-layout {
  min-height: 100vh;
  background: #f5f5f5;
}
</style>
