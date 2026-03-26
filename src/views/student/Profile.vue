<template>
  <div class="profile-container">
    <div class="profile-header">
      <div class="avatar-section">
        <div class="avatar">
          <img :src="student?.avatar || '/default-avatar.png'" alt="头像">
        </div>
        <div class="name">{{ student?.name || '小朋友' }}</div>
        <div class="class-info">{{ student?.class_name || '未分配班级' }}</div>
      </div>
      
      <div class="level-section">
        <div class="level-badge">Lv.{{ student?.level || 1 }}</div>
        <div class="level-progress">
          <div class="progress-bar">
            <div class="progress-fill" :style="{ width: levelProgress + '%' }"></div>
          </div>
          <div class="progress-text">{{ levelProgress }}%</div>
        </div>
      </div>
    </div>

    <div class="profile-content">
      <div class="section">
        <div class="section-title">学习统计</div>
        <div class="stats-grid">
          <div class="stat-item">
            <div class="stat-icon">📚</div>
            <div class="stat-value">{{ stats.total_assignments || 0 }}</div>
            <div class="stat-label">完成作业</div>
          </div>
          <div class="stat-item">
            <div class="stat-icon">✅</div>
            <div class="stat-value">{{ stats.total_questions || 0 }}</div>
            <div class="stat-label">答题总数</div>
          </div>
          <div class="stat-item">
            <div class="stat-icon">🎯</div>
            <div class="stat-value">{{ stats.accuracy || 0 }}%</div>
            <div class="stat-label">平均正确率</div>
          </div>
          <div class="stat-item">
            <div class="stat-icon">🔥</div>
            <div class="stat-value">{{ stats.continuous_days || 0 }}</div>
            <div class="stat-label">连续学习</div>
          </div>
        </div>
      </div>

      <div class="section">
        <div class="section-title">我的成就</div>
        <div class="badges">
          <div
            v-for="badge in badges"
            :key="badge.id"
            class="badge-item"
            :class="{ 'unlocked': badge.unlocked }"
          >
            <div class="badge-icon">{{ badge.icon }}</div>
            <div class="badge-name">{{ badge.name }}</div>
            <div class="badge-desc">{{ badge.description }}</div>
          </div>
        </div>
      </div>

      <div class="section">
        <div class="section-title">设置</div>
        <van-cell-group>
          <van-cell title="切换账号" is-link @click="switchAccount" />
          <van-cell title="关于我们" is-link @click="showAbout" />
          <van-cell title="退出登录" is-link @click="logout" />
        </van-cell-group>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { supabase } from '@/config/supabase'
import { showConfirmDialog, showToast } from 'vant'

const router = useRouter()
const userStore = useUserStore()

const student = ref(null)
const stats = ref({
  total_assignments: 0,
  total_questions: 0,
  accuracy: 0,
  continuous_days: 0
})
const badges = ref([
  { id: 1, name: '初学者', icon: '🌱', description: '完成第一次作业', unlocked: false },
  { id: 2, name: '勤奋好学', icon: '📖', description: '连续学习7天', unlocked: false },
  { id: 3, name: '答题达人', icon: '🎯', description: '累计答题100题', unlocked: false },
  { id: 4, name: '满分王者', icon: '👑', description: '获得10次满分', unlocked: false },
  { id: 5, name: '英语小能手', icon: '🌟', description: '正确率达到90%', unlocked: false },
  { id: 6, name: '学习之星', icon: '⭐', description: '连续学习30天', unlocked: false }
])

const levelProgress = computed(() => {
  const level = student.value?.level || 1
  const exp = student.value?.experience || 0
  const expNeeded = level * 100
  return Math.round((exp / expNeeded) * 100)
})

onMounted(async () => {
  student.value = userStore.student
  await loadStats()
  await loadBadges()
})

async function loadStats() {
  try {
    const { data, error } = await supabase
      .from('student_stats')
      .select('*')
      .eq('student_id', student.value?.id)
      .single()
    
    if (data) {
      stats.value = data
    }
  } catch (error) {
    console.error('加载统计数据失败:', error)
  }
}

async function loadBadges() {
  try {
    const { data, error } = await supabase
      .from('student_badges')
      .select('badge_id')
      .eq('student_id', student.value?.id)
    
    if (data) {
      const unlockedBadgeIds = data.map(item => item.badge_id)
      badges.value.forEach(badge => {
        badge.unlocked = unlockedBadgeIds.includes(badge.id)
      })
    }
  } catch (error) {
    console.error('加载成就失败:', error)
  }
}

function switchAccount() {
  showConfirmDialog({
    title: '切换账号',
    message: '确定要切换到其他学生账号吗？'
  }).then(() => {
    router.push('/student/login')
  }).catch(() => {})
}

function showAbout() {
  showToast('幼儿园英语学习助手 v1.0.0')
}

function logout() {
  showConfirmDialog({
    title: '退出登录',
    message: '确定要退出登录吗？'
  }).then(async () => {
    await userStore.logout()
    router.push('/student/login')
  }).catch(() => {})
}
</script>

<style scoped>
.profile-container {
  min-height: 100vh;
  background: #f5f5f5;
  padding-bottom: 60px;
}

.profile-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 30px 20px;
  text-align: center;
  color: white;
}

.avatar-section {
  margin-bottom: 24px;
}

.avatar {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  overflow: hidden;
  margin: 0 auto 12px;
  background: white;
  border: 3px solid rgba(255, 255, 255, 0.3);
}

.avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.name {
  font-size: 20px;
  font-weight: bold;
  margin-bottom: 4px;
}

.class-info {
  font-size: 14px;
  opacity: 0.9;
}

.level-section {
  background: rgba(255, 255, 255, 0.2);
  border-radius: 12px;
  padding: 16px;
}

.level-badge {
  font-size: 24px;
  font-weight: bold;
  margin-bottom: 12px;
}

.level-progress {
  display: flex;
  align-items: center;
  gap: 12px;
}

.progress-bar {
  flex: 1;
  height: 8px;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: white;
  transition: width 0.3s ease;
}

.progress-text {
  font-size: 12px;
  min-width: 40px;
}

.profile-content {
  padding: 16px;
}

.section {
  background: white;
  border-radius: 12px;
  padding: 16px;
  margin-bottom: 16px;
}

.section-title {
  font-size: 16px;
  font-weight: bold;
  color: #333;
  margin-bottom: 16px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
}

.stat-item {
  text-align: center;
  padding: 16px;
  background: #f8f8f8;
  border-radius: 8px;
}

.stat-icon {
  font-size: 32px;
  margin-bottom: 8px;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: #667eea;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 12px;
  color: #999;
}

.badges {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 12px;
}

.badge-item {
  text-align: center;
  padding: 16px;
  background: #f8f8f8;
  border-radius: 8px;
  opacity: 0.5;
  transition: all 0.3s ease;
}

.badge-item.unlocked {
  opacity: 1;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.badge-icon {
  font-size: 32px;
  margin-bottom: 8px;
}

.badge-name {
  font-size: 14px;
  font-weight: bold;
  margin-bottom: 4px;
}

.badge-desc {
  font-size: 10px;
  opacity: 0.8;
}
</style>
