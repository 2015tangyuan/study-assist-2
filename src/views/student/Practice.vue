<template>
  <div class="practice-container">
    <div class="practice-header">
      <div class="progress-bar">
        <div class="progress-info">
          <span>进度</span>
          <span class="progress-text">{{ currentIndex + 1 }}/{{ questions.length }}</span>
        </div>
        <div class="progress-track">
          <div class="progress-fill" :style="{ width: progressPercent + '%' }"></div>
        </div>
      </div>
    </div>

    <div class="practice-content">
      <div class="audio-player">
        <van-button
          round
          type="primary"
          size="large"
          icon="play-circle-o"
          @click="playAudio"
        >
          播放发音
        </van-button>
        <div class="audio-hint">点击按钮听发音，选择正确的图片</div>
      </div>

      <div class="options-grid">
        <div
          v-for="(option, index) in currentQuestion.options"
          :key="index"
          class="option-item"
          :class="{ 'selected': selectedOption === index, 'correct': showResult && index === correctOption, 'wrong': showResult && selectedOption === index && index !== correctOption }"
          @click="selectOption(index)"
        >
          <div class="option-label">{{ ['A', 'B', 'C', 'D'][index] }}</div>
          <div class="option-image">
            <img :src="option.image" :alt="option.text">
          </div>
          <div class="option-text">{{ option.text }}</div>
        </div>
      </div>
    </div>

    <div class="practice-footer">
      <van-button
        v-if="currentIndex > 0"
        @click="prevQuestion"
      >
        上一题
      </van-button>
      <van-button
        type="primary"
        :disabled="!selectedOption || showResult"
        @click="submitAnswer"
      >
        提交答案
      </van-button>
      <van-button
        v-if="currentIndex < questions.length - 1"
        :disabled="!showResult"
        @click="nextQuestion"
      >
        下一题
      </van-button>
    </div>

    <van-dialog
      v-model:show="showFeedback"
      :title="feedbackTitle"
      :message="feedbackMessage"
      :show-confirm-button="false"
    >
      <template #footer>
        <van-button
          type="primary"
          block
          @click="closeFeedback"
        >
          {{ currentIndex < questions.length - 1 ? '下一题' : '查看结果' }}
        </van-button>
      </template>
    </van-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { supabase } from '@/config/supabase'

const router = useRouter()
const route = useRoute()

const assignmentId = route.params.id
const questions = ref([])
const currentIndex = ref(0)
const selectedOption = ref(null)
const showResult = ref(false)
const showFeedback = ref(false)
const feedbackTitle = ref('')
const feedbackMessage = ref('')
const answers = ref([])
const startTime = ref(null)

const currentQuestion = computed(() => questions.value[currentIndex.value])
const progressPercent = computed(() => ((currentIndex.value + 1) / questions.value.length) * 100)
const correctOption = computed(() => currentQuestion.value?.correct_answer)

onMounted(async () => {
  await loadQuestions()
  startTime.value = Date.now()
})

onUnmounted(() => {
  if (audio) {
    audio.pause()
  }
})

let audio = null

async function loadQuestions() {
  try {
    const { data, error } = await supabase
      .from('assignment_questions')
      .select('*, questions(*)')
      .eq('assignment_id', assignmentId)
      .order('order', { ascending: true })
    
    if (error) throw error
    
    questions.value = data.map(item => ({
      id: item.questions.id,
      word: item.questions.word,
      audio_url: item.questions.audio_url,
      options: JSON.parse(item.questions.options),
      correct_answer: item.questions.correct_answer
    }))
  } catch (error) {
    console.error('加载题目失败:', error)
  }
}

function playAudio() {
  if (!currentQuestion.value?.audio_url) return
  
  if (audio) {
    audio.pause()
  }
  
  audio = new Audio(currentQuestion.value.audio_url)
  audio.play()
}

function selectOption(index) {
  if (showResult.value) return
  selectedOption.value = index
}

async function submitAnswer() {
  if (selectedOption.value === null) return
  
  const isCorrect = selectedOption.value === correctOption.value
  
  answers.value.push({
    question_id: currentQuestion.value.id,
    selected_option: selectedOption.value,
    is_correct: isCorrect,
    time_spent: Date.now() - startTime.value
  })
  
  showResult.value = true
  
  if (isCorrect) {
    feedbackTitle.value = '🎉 太棒了！'
    feedbackMessage.value = '回答正确，继续加油！'
  } else {
    feedbackTitle.value = '😊 再想想'
    feedbackMessage.value = `正确答案是 ${['A', 'B', 'C', 'D'][correctOption.value]}`
  }
  
  showFeedback.value = true
  
  startTime.value = Date.now()
}

function closeFeedback() {
  showFeedback.value = false
  
  if (currentIndex.value < questions.value.length - 1) {
    nextQuestion()
  } else {
    submitResults()
  }
}

function nextQuestion() {
  currentIndex.value++
  selectedOption.value = null
  showResult.value = false
}

function prevQuestion() {
  if (currentIndex.value > 0) {
    currentIndex.value--
    selectedOption.value = null
    showResult.value = false
  }
}

async function submitResults() {
  try {
    const correctCount = answers.value.filter(a => a.is_correct).length
    const score = Math.round((correctCount / questions.value.length) * 100)
    
    const { data, error } = await supabase
      .from('assignment_results')
      .insert({
        assignment_id: assignmentId,
        student_id: userStore.student?.id,
        score: score,
        correct_count: correctCount,
        total_count: questions.value.length,
        answers: answers.value,
        completed_at: new Date().toISOString()
      })
      .select()
      .single()
    
    if (error) throw error
    
    router.push(`/student/result/${data.id}`)
  } catch (error) {
    console.error('提交结果失败:', error)
  }
}
</script>

<style scoped>
.practice-container {
  min-height: 100vh;
  background: #f5f5f5;
  display: flex;
  flex-direction: column;
}

.practice-header {
  background: white;
  padding: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
}

.progress-bar {
  width: 100%;
}

.progress-info {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-size: 14px;
  color: #666;
}

.progress-text {
  font-weight: bold;
  color: #667eea;
}

.progress-track {
  height: 8px;
  background: #e8e8e8;
  border-radius: 4px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: linear-gradient(90deg, #667eea 0%, #764ba2 100%);
  transition: width 0.3s ease;
}

.practice-content {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
}

.audio-player {
  text-align: center;
  margin-bottom: 30px;
}

.audio-player .van-button {
  width: 120px;
  height: 120px;
  font-size: 16px;
  margin-bottom: 12px;
}

.audio-hint {
  font-size: 14px;
  color: #999;
}

.options-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
}

.option-item {
  background: white;
  border-radius: 12px;
  padding: 12px;
  text-align: center;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 2px solid transparent;
}

.option-item.selected {
  border-color: #667eea;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

.option-item.correct {
  border-color: #07c160;
  background: #f0f9ff;
}

.option-item.wrong {
  border-color: #ee0a24;
  background: #fff0f0;
}

.option-label {
  width: 32px;
  height: 32px;
  background: #667eea;
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 8px;
  font-weight: bold;
}

.option-image {
  width: 100%;
  height: 120px;
  margin-bottom: 8px;
  border-radius: 8px;
  overflow: hidden;
}

.option-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.option-text {
  font-size: 14px;
  color: #333;
}

.practice-footer {
  background: white;
  padding: 16px;
  display: flex;
  justify-content: space-between;
  gap: 12px;
  box-shadow: 0 -2px 8px rgba(0, 0, 0, 0.05);
}

.practice-footer .van-button {
  flex: 1;
}
</style>
