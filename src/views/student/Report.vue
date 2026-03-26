<template>
  <div class="report-container">
    <div class="report-header">
      <div class="user-info">
        <div class="avatar">
          <img :src="student?.avatar || '/default-avatar.png'" alt="头像">
        </div>
        <div class="info">
          <div class="name">{{ student?.name || '小朋友' }}</div>
          <div class="class-info">{{ student?.class_name || '未分配班级' }}</div>
        </div>
      </div>
    </div>

    <div class="report-content">
      <div class="section">
        <div class="section-title">学习趋势</div>
        <div class="chart-container">
          <div class="chart-placeholder">
            <van-icon name="chart-trending-o" size="48" color="#667eea" />
            <p>学习趋势图表</p>
          </div>
        </div>
        <div class="time-tabs">
          <van-button
            :type="timeRange === 7 ? 'primary' : 'default'"
            size="small"
            @click="timeRange = 7"
          >
            近7天
          </van-button>
          <van-button
            :type="timeRange === 30 ? 'primary' : 'default'"
            size="small"
            @click="timeRange = 30"
          >
            近30天
          </van-button>
        </div>
      </div>

      <div class="section">
        <div class="section-title">薄弱知识点</div>
        <div class="weak-points">
          <div
            v-for="point in weakPoints"
            :key="point.word"
            class="weak-point"
            :style="{ fontSize: Math.max(14, point.error_count * 2) + 'px' }"
            @click="practiceWord(point.word)"
          >
            {{ point.word }}
          </div>
          <van-empty v-if="weakPoints.length === 0" description="暂无薄弱知识点" />
        </div>
      </div>

      <div class="section">
        <div class="section-title">班级对比</div>
        <div class="comparison">
          <div class="comparison-item">
            <div class="comparison-label">我的正确率</div>
            <div class="comparison-value">{{ myAccuracy }}%</div>
          </div>
          <div class="comparison-item">
            <div class="comparison-label">班级平均</div>
            <div class="comparison-value">{{ classAverage }}%</div>
          </div>
          <div class="comparison-item">
            <div class="comparison-label">超过同学</div>
            <div class="comparison-value">{{ beatPercent }}%</div>
          </div>
        </div>
      </div>

      <div class="section">
        <div class="section-title">历史作业</div>
        <div class="assignment-list">
          <div
            v-for="item in historyAssignments"
            :key="item.id"
            class="assignment-item"
            @click="viewDetail(item)"
          >
            <div class="assignment-info">
              <div class="assignment-title">{{ item.title }}</div>
              <div class="assignment-meta">
                <span>{{ formatDate(item.completed_at) }}</span>
                <span>{{ item.score }}分</span>
              </div>
            </div>
            <van-icon name="arrow" />
          </div>
          <van-empty v-if="historyAssignments.length === 0" description="暂无作业记录" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { supabase } from '@/config/supabase'

const router = useRouter()
const userStore = useUserStore()

const student = ref(null)
const timeRange = ref(7)
const weakPoints = ref([])
const myAccuracy = ref(0)
const classAverage = ref(0)
const beatPercent = ref(0)
const historyAssignments = ref([])

onMounted(async () => {
  student.value = userStore.student
  await loadReportData()
})

async function loadReportData() {
  await loadWeakPoints()
  await loadComparison()
  await loadHistoryAssignments()
}

async function loadWeakPoints() {
  try {
    const { data, error } = await supabase
      .from('assignment_results')
      .select('answers')
      .eq('student_id', student.value?.id)
    
    if (error) throw error
    
    const wordErrors = {}
    data.forEach(result => {
      (result.answers || []).forEach(answer => {
        if (!answer.is_correct) {
          wordErrors[answer.question_id] = (wordErrors[answer.question_id] || 0) + 1
        }
      })
    })
    
    weakPoints.value = Object.entries(wordErrors)
      .map(([word, count]) => ({ word, error_count: count }))
      .sort((a, b) => b.error_count - a.error_count)
      .slice(0, 10)
  } catch (error) {
    console.error('加载薄弱知识点失败:', error)
  }
}

async function loadComparison() {
  try {
    const { data: myData, error: myError } = await supabase
      .from('assignment_results')
      .select('score')
      .eq('student_id', student.value?.id)
    
    if (myError) throw myError
    
    if (myData.length > 0) {
      myAccuracy.value = Math.round(myData.reduce((sum, item) => sum + item.score, 0) / myData.length)
    }
    
    const { data: classData, error: classError } = await supabase
      .from('assignment_results')
      .select('score, students(class_id)')
      .eq('students.class_id', student.value?.class_id)
    
    if (classError) throw classError
    
    if (classData.length > 0) {
      classAverage.value = Math.round(classData.reduce((sum, item) => sum + item.score, 0) / classData.length)
      
      const betterCount = classData.filter(item => item.score < myAccuracy.value).length
      beatPercent.value = Math.round((betterCount / classData.length) * 100)
    }
  } catch (error) {
    console.error('加载对比数据失败:', error)
  }
}

async function loadHistoryAssignments() {
  try {
    const { data, error } = await supabase
      .from('assignment_results')
      .select('*, assignments(title)')
      .eq('student_id', student.value?.id)
      .order('completed_at', { ascending: false })
      .limit(10)
    
    if (error) throw error
    
    historyAssignments.value = data.map(item => ({
      ...item,
      title: item.assignments?.title || '作业'
    }))
  } catch (error) {
    console.error('加载历史作业失败:', error)
  }
}

function practiceWord(word) {
  router.push('/student')
}

function viewDetail(item) {
  router.push(`/student/result/${item.id}`)
}

function formatDate(dateString) {
  const date = new Date(dateString)
  const month = date.getMonth() + 1
  const day = date.getDate()
  return `${month}月${day}日`
}
</script>

<style scoped>
.report-container {
  min-height: 100vh;
  background: #f5f5f5;
  padding-bottom: 60px;
}

.report-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 20px;
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

.report-content {
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

.chart-container {
  height: 200px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 12px;
}

.chart-placeholder {
  text-align: center;
  color: #999;
}

.chart-placeholder p {
  margin-top: 8px;
  font-size: 14px;
}

.time-tabs {
  display: flex;
  gap: 8px;
  justify-content: center;
}

.weak-points {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  padding: 16px;
  background: #f8f8f8;
  border-radius: 8px;
}

.weak-point {
  padding: 8px 16px;
  background: white;
  border-radius: 20px;
  color: #667eea;
  cursor: pointer;
  transition: all 0.3s ease;
}

.weak-point:hover {
  background: #667eea;
  color: white;
}

.comparison {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
}

.comparison-item {
  text-align: center;
  padding: 16px;
  background: #f8f8f8;
  border-radius: 8px;
}

.comparison-label {
  font-size: 12px;
  color: #999;
  margin-bottom: 8px;
}

.comparison-value {
  font-size: 24px;
  font-weight: bold;
  color: #667eea;
}

.assignment-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.assignment-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px;
  background: #f8f8f8;
  border-radius: 8px;
  cursor: pointer;
}

.assignment-info {
  flex: 1;
}

.assignment-title {
  font-size: 15px;
  color: #333;
  margin-bottom: 4px;
}

.assignment-meta {
  font-size: 12px;
  color: #999;
  display: flex;
  gap: 12px;
}
</style>
