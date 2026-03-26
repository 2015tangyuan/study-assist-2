<template>
  <div class="result-container">
    <div class="result-header">
      <div class="score-circle">
        <div class="score-value">{{ result?.score || 0 }}</div>
        <div class="score-label">得分</div>
      </div>
      <div class="result-stats">
        <div class="stat-item">
          <div class="stat-value">{{ result?.correct_count || 0 }}/{{ result?.total_count || 0 }}</div>
          <div class="stat-label">正确题数</div>
        </div>
        <div class="stat-item">
          <div class="stat-value">{{ accuracy }}%</div>
          <div class="stat-label">正确率</div>
        </div>
        <div class="stat-item">
          <div class="stat-value">{{ formatTime(result?.time_spent) }}</div>
          <div class="stat-label">用时</div>
        </div>
      </div>
    </div>

    <div class="result-content">
      <div class="section">
        <div class="section-title">答题详情</div>
        
        <div class="answer-list">
          <div
            v-for="(answer, index) in answers"
            :key="index"
            class="answer-item"
            :class="{ 'correct': answer.is_correct, 'wrong': !answer.is_correct }"
          >
            <div class="answer-number">第{{ index + 1 }}题</div>
            <div class="answer-status">
              <van-icon v-if="answer.is_correct" name="success" color="#07c160" />
              <van-icon v-else name="cross" color="#ee0a24" />
            </div>
            <div class="answer-detail">
              <div class="answer-word">{{ getQuestionWord(answer.question_id) }}</div>
              <div class="answer-time">{{ formatTime(answer.time_spent) }}</div>
            </div>
          </div>
        </div>
      </div>

      <div class="section" v-if="result?.comment">
        <div class="section-title">老师评语</div>
        <div class="teacher-comment">
          <div class="comment-avatar">
            <img :src="teacher?.avatar || '/default-avatar.png'" alt="老师头像">
          </div>
          <div class="comment-content">
            <div class="comment-name">{{ teacher?.name || '老师' }}</div>
            <div class="comment-text">{{ result.comment }}</div>
          </div>
        </div>
      </div>
    </div>

    <div class="result-footer">
      <van-button block @click="viewWrongQuestions">查看错题集</van-button>
      <van-button type="primary" block @click="practiceAgain">再练一次</van-button>
      <van-button block @click="goHome">返回首页</van-button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { supabase } from '@/config/supabase'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()

const resultId = route.params.id
const result = ref(null)
const answers = ref([])
const teacher = ref(null)
const questions = ref([])

const accuracy = computed(() => {
  if (!result.value || result.value.total_count === 0) return 0
  return Math.round((result.value.correct_count / result.value.total_count) * 100)
})

onMounted(async () => {
  await loadResult()
})

async function loadResult() {
  try {
    const { data, error } = await supabase
      .from('assignment_results')
      .select('*, assignments(*, teachers(*))')
      .eq('id', resultId)
      .single()
    
    if (error) throw error
    
    result.value = data
    answers.value = data.answers || []
    teacher.value = data.assignments?.teachers || null
    
    await loadQuestions()
  } catch (error) {
    console.error('加载结果失败:', error)
  }
}

async function loadQuestions() {
  try {
    const { data, error } = await supabase
      .from('assignment_questions')
      .select('questions(*)')
      .eq('assignment_id', result.value?.assignment_id)
      .order('order', { ascending: true })
    
    if (error) throw error
    
    questions.value = data.map(item => item.questions)
  } catch (error) {
    console.error('加载题目失败:', error)
  }
}

function getQuestionWord(questionId) {
  const question = questions.value.find(q => q.id === questionId)
  return question?.word || '未知'
}

function formatTime(ms) {
  if (!ms) return '0秒'
  const seconds = Math.floor(ms / 1000)
  if (seconds < 60) return `${seconds}秒`
  const minutes = Math.floor(seconds / 60)
  const remainingSeconds = seconds % 60
  return `${minutes}分${remainingSeconds}秒`
}

function viewWrongQuestions() {
  const wrongAnswers = answers.value.filter(a => !a.is_correct)
  if (wrongAnswers.length === 0) {
    alert('太棒了！没有错题！')
    return
  }
  router.push('/student/report')
}

function practiceAgain() {
  router.push(`/student/practice/${result.value?.assignment_id}`)
}

function goHome() {
  router.push('/student')
}
</script>

<style scoped>
.result-container {
  min-height: 100vh;
  background: #f5f5f5;
  padding-bottom: 80px;
}

.result-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 40px 20px 30px;
  text-align: center;
  color: white;
}

.score-circle {
  width: 160px;
  height: 160px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.2);
  margin: 0 auto 24px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  border: 4px solid rgba(255, 255, 255, 0.3);
}

.score-value {
  font-size: 56px;
  font-weight: bold;
  margin-bottom: 4px;
}

.score-label {
  font-size: 16px;
  opacity: 0.9;
}

.result-stats {
  display: flex;
  justify-content: center;
  gap: 40px;
}

.stat-item {
  text-align: center;
}

.stat-value {
  font-size: 24px;
  font-weight: bold;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 12px;
  opacity: 0.9;
}

.result-content {
  padding: 20px;
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

.answer-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.answer-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border-radius: 8px;
  background: #f8f8f8;
}

.answer-item.correct {
  background: #f0f9ff;
  border-left: 3px solid #07c160;
}

.answer-item.wrong {
  background: #fff0f0;
  border-left: 3px solid #ee0a24;
}

.answer-number {
  font-size: 14px;
  color: #666;
  min-width: 60px;
}

.answer-status {
  font-size: 20px;
}

.answer-detail {
  flex: 1;
}

.answer-word {
  font-size: 15px;
  color: #333;
  margin-bottom: 4px;
}

.answer-time {
  font-size: 12px;
  color: #999;
}

.teacher-comment {
  display: flex;
  gap: 12px;
}

.comment-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  overflow: hidden;
}

.comment-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.comment-content {
  flex: 1;
}

.comment-name {
  font-size: 14px;
  color: #666;
  margin-bottom: 4px;
}

.comment-text {
  font-size: 15px;
  color: #333;
  line-height: 1.6;
}

.result-footer {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: white;
  padding: 12px 20px;
  display: flex;
  flex-direction: column;
  gap: 8px;
  box-shadow: 0 -2px 8px rgba(0, 0, 0, 0.05);
}

.result-footer .van-button {
  height: 48px;
}
</style>
