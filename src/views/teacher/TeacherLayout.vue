<template>
  <div class="teacher-layout">
    <el-container>
      <el-aside width="240px">
        <div class="logo">
          <h2>英语学习助手</h2>
          <p>教师管理后台</p>
        </div>
        
        <el-menu
          :default-active="activeMenu"
          router
          class="sidebar-menu"
        >
          <el-menu-item index="/teacher">
            <el-icon><Odometer /></el-icon>
            <span>控制台</span>
          </el-menu-item>
          <el-menu-item index="/teacher/classes">
            <el-icon><User /></el-icon>
            <span>班级管理</span>
          </el-menu-item>
          <el-menu-item index="/teacher/questions">
            <el-icon><Document /></el-icon>
            <span>题库管理</span>
          </el-menu-item>
          <el-menu-item index="/teacher/assignments">
            <el-icon><Edit /></el-icon>
            <span>作业管理</span>
          </el-menu-item>
          <el-menu-item index="/teacher/analysis">
            <el-icon><TrendCharts /></el-icon>
            <span>学情分析</span>
          </el-menu-item>
        </el-menu>
      </el-aside>
      
      <el-container>
        <el-header>
          <div class="header-content">
            <div class="breadcrumb">
              <el-breadcrumb separator="/">
                <el-breadcrumb-item :to="{ path: '/teacher' }">首页</el-breadcrumb-item>
                <el-breadcrumb-item>{{ currentTitle }}</el-breadcrumb-item>
              </el-breadcrumb>
            </div>
            <div class="user-actions">
              <el-dropdown>
                <span class="user-info">
                  <el-avatar :size="32" :src="teacher?.avatar || '/default-avatar.png'" />
                  <span>{{ teacher?.name || '老师' }}</span>
                </span>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item @click="logout">退出登录</el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
            </div>
          </div>
        </el-header>
        
        <el-main>
          <router-view />
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { Odometer, User, Document, Edit, TrendCharts } from '@element-plus/icons-vue'

const route = useRoute()
const userStore = useUserStore()

const teacher = ref(null)
const activeMenu = computed(() => route.path)
const currentTitle = computed(() => {
  const titles = {
    '/teacher': '控制台',
    '/teacher/classes': '班级管理',
    '/teacher/questions': '题库管理',
    '/teacher/assignments': '作业管理',
    '/teacher/analysis': '学情分析'
  }
  return titles[route.path] || '控制台'
})

onMounted(async () => {
  teacher.value = userStore.user
})

function logout() {
  userStore.logout()
  window.location.href = '/teacher/login'
}
</script>

<style scoped>
.teacher-layout {
  height: 100vh;
}

.el-aside {
  background: #304156;
  color: white;
}

.logo {
  padding: 20px;
  text-align: center;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.logo h2 {
  font-size: 18px;
  margin: 0 0 4px 0;
}

.logo p {
  font-size: 12px;
  margin: 0;
  opacity: 0.7;
}

.sidebar-menu {
  border: none;
  background: transparent;
}

.sidebar-menu .el-menu-item {
  color: rgba(255, 255, 255, 0.7);
}

.sidebar-menu .el-menu-item:hover,
.sidebar-menu .el-menu-item.is-active {
  background: #263445;
  color: white;
}

.el-header {
  background: white;
  border-bottom: 1px solid #e8e8e8;
  padding: 0 20px;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 100%;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.el-main {
  background: #f5f5f5;
  padding: 20px;
}
</style>
