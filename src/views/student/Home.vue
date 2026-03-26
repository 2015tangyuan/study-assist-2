<template>
  <div class="home-container">
    <div class="header">
      <div class="user-info">
        <div class="avatar">
          <img :src="student?.avatar || '/default-avatar.png'" alt="头像">
        </div>
        <div class="info">
          <div class="name">{{ student?.name || '小朋友' }}</div>
          <div class="class-info">{{ student?.class_name || '未分配班级' }}</div>
        </div>
      </div>
      <div class="level-badge">
        <van-tag type="primary" size="large">Lv.{{ student?.level || 1 }}</van-tag>
      </div>
    </div>

    <div class="stats-cards">
      <div class="stat-card">
        <div class="stat-value">{{ stats.totalQuestions || 0 }}</div>
        <div class="stat-label">总做题数</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">{{ stats.accuracy || 0 }}%</div>
        <div class="stat-label">正确率</div>
      </div>
      <div class="stat-card">
        <div class="stat-value">{{ stats.continuousDays || 0 }}</div>
        <div class="stat-label">连续学习</div>
      </div>
    </div>

    <div class="section">
      <div class="section-title">
        <span>今日作业</span>
        <span class="more" @click="viewAllAssignments">查看全部</span>
      </div>
      
      <div v-if="todayAssignment" class="assignment-card" @click="startAssignment(todayAssignment)">
        <div class="assignment-info">
          <div class="assignment-name">{{ todayAssignment.title }}</div>
          <div class="assignment-meta">
            <span>{{ todayAssignment.teacher_name }}</span>
            <span>{{ todayAssignment.question_count }}题</span>
            <span>预计{{ todayAssignment.estimated_time }}分钟</span>
          </div>
        </div>
        <van-button type="primary" round size="large">开始作业</van-button>
      </div>
      
      <van-empty v-else description="暂无作业" />
    </div>

    <div class="section">
      <div class="section-title">历史作业</div>
      
      <div class="history-list">
        <div
          v-for="item in historyAssignments"
          :key="item.id"
          class="history-item"
          @click="viewAssignmentDetail(item)"
        >
          <div class="history-info">
            <div class="history-name">{{ item.title }}</div>
            <div class="history-time">{{ formatDate(item.completed_at) }}</div>
          </div>
          <div class="history-score" :class="{ 'excellent': item.score >= 90 }">
            {{ item.score }}分
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { supabase } from '@/config/supabase'

const router = useRouter()
const userStore = useUserStore()

const student = ref(null)
const stats = ref({
  totalQuestions: 0,
  accuracy: 0,
  continuousDays: 0
})
const todayAssignment = ref(null)
const historyAssignments = ref([])

onMounted(async () => {
  await loadData()
})

async function loadData() {
  student.value = userStore.student
  await loadStats()
  await loadTodayAssignment()
  await loadHistoryAssignments()
}

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

async function loadTodayAssignment() {
  try {
    const today = new Date().toISOString().split('T')[0]
    const { data, error } = await supabase
      .from('assignments')
      .select('*, teachers(name)')
      .eq('class_id', student.value?.class_id)
      .eq('publish_date', today)
      .single()
    
    if (data) {
      todayAssignment.value = {
        ...data,
        teacher_name: data.teachers?.name || '老师'
      }
    }
  } catch (error) {
    console.error('加载今日作业失败:', error)
  }
}

async function loadHistoryAssignments() {
  try {
    const { data, error } = await supabase
      .from('assignment_results')
      .select('*, assignments(title)')
      .eq('student_id', student.value?.id)
      .order('completed_at', { ascending: false })
      .limit(5)
    
    if (data) {
      historyAssignments.value = data.map(item => ({
        ...item,
        title: item.assignments?.title || '作业'
      }))
    }
  } catch (error) {
    console.error('加载历史作业失败:', error)
  }
}

function startAssignment(assignment) {
  router.push(`/student/practice/${assignment.id}`)
}

function viewAssignmentDetail(assignment) {
  router.push(`/student/result/${assignment.id}`)
}

function viewAllAssignments() {
  router.push('/student/report')
}

function formatDate(dateString) {
  const date = new Date(dateString)
  const month = date.getMonth() + 1
  const day = date.getDate()
  return `${month}月${day}日`
}
</script>

<style scoped>
.home-container {
  min-height: 100vh;
  background: #f5f5f5;
  padding-bottom: 60px;
}

.header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  color: white;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 12px;
}

.avatar {
  width: 56px;
  height: 56px;
  border-radius: 50%;
  overflow: hidden;
  background: white;
}

.avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.info .name {
  font-size: 18px;
  font-weight: bold;
  margin-bottom: 4px;
}

.info .class-info {
  font-size: 14px;
  opacity: 0.9;
}

.stats-cards {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
  padding: 20px;
  margin-top: -20px;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 20px 10px;
  text-align: center;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: #667eea;
  margin-bottom: 8px;
}

.stat-label {
  font-size: 12px;
  color: #999;
}

.section {
  background: white;
  margin: 16px;
  border-radius: 12px;
  padding: 16px;
}

.section-title {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 16px;
  font-size: 16px;
  font-weight: bold;
  color: #333;
}

.section-title .more {
  font-size: 14px;
  color: #667eea;
  font-weight: normal;
}

.assignment-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-radius: 12px;
  padding: 20px;
  color: white;
}

.assignment-info {
  margin-bottom: 16px;
}

.assignment-name {
  font-size: 18px;
  font-weight: bold;
  margin-bottom: 8px;
}

.assignment-meta {
  display: flex;
  gap: 16px;
  font-size: 14px;
  opacity: 0.9;
}

.history-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.history-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px;
  background: #f8f8f8;
  border-radius: 8px;
}

.history-info {
  flex: 1;
}

.history-name {
  font-size: 15px;
  color: #333;
  margin-bottom: 4px;
}

.history-time {
  font-size: 12px;
  color: #999;
}

.history-score {
  font-size: 20px;
  font-weight: bold;
  color: #667eea;
}

.history-score.excellent {
  color: #07c160;
}
</style>
