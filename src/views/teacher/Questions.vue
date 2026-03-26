<template>
  <div class="questions-container">
    <div class="page-header">
      <h2>题库管理</h2>
      <el-button type="primary" @click="showCreateDialog = true">
        添加题目
      </el-button>
    </div>

    <div class="filter-bar">
      <el-input
        v-model="searchKeyword"
        placeholder="搜索单词"
        style="width: 200px"
        clearable
      />
      <el-select
        v-model="selectedCategory"
        placeholder="选择分类"
        style="width: 150px"
        clearable
      >
        <el-option label="动物" value="动物" />
        <el-option label="水果" value="水果" />
        <el-option label="颜色" value="颜色" />
        <el-option label="数字" value="数字" />
        <el-option label="其他" value="其他" />
      </el-select>
      <el-select
        v-model="selectedDifficulty"
        placeholder="选择难度"
        style="width: 150px"
        clearable
      >
        <el-option label="简单" value="简单" />
        <el-option label="中等" value="中等" />
        <el-option label="困难" value="困难" />
      </el-select>
      <el-select
        v-model="selectedStatus"
        placeholder="选择状态"
        style="width: 150px"
        clearable
      >
        <el-option label="待审核" value="pending" />
        <el-option label="已通过" value="approved" />
        <el-option label="已驳回" value="rejected" />
      </el-select>
      <el-button type="primary" @click="loadQuestions">搜索</el-button>
      <el-button @click="resetFilter">重置</el-button>
    </div>

    <el-table :data="questions" style="width: 100%">
      <el-table-column prop="word" label="单词" width="120" />
      <el-table-column label="音频" width="100">
        <template #default="{ row }">
          <el-button size="small" @click="playAudio(row.audio_url)">
            播放
          </el-button>
        </template>
      </el-table-column>
      <el-table-column label="选项" width="300">
        <template #default="{ row }">
          <div class="options-preview">
            <span v-for="(opt, idx) in row.options" :key="idx">
              {{ ['A', 'B', 'C', 'D'][idx] }}: {{ opt.text }}
            </span>
          </div>
        </template>
      </el-table-column>
      <el-table-column prop="category" label="分类" width="100" />
      <el-table-column prop="difficulty" label="难度" width="100" />
      <el-table-column prop="status" label="状态" width="100">
        <template #default="{ row }">
          <el-tag :type="getStatusType(row.status)">
            {{ getStatusText(row.status) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="created_at" label="创建时间" width="120">
        <template #default="{ row }">
          {{ formatDate(row.created_at) }}
        </template>
      </el-table-column>
      <el-table-column label="操作" width="250">
        <template #default="{ row }">
          <el-button size="small" @click="viewQuestion(row)">
            查看
          </el-button>
          <el-button size="small" type="primary" @click="editQuestion(row)">
            编辑
          </el-button>
          <el-button
            v-if="row.status === 'pending'"
            size="small"
            type="success"
            @click="approveQuestion(row)"
          >
            通过
          </el-button>
          <el-button
            v-if="row.status === 'pending'"
            size="small"
            type="danger"
            @click="rejectQuestion(row)"
          >
            驳回
          </el-button>
          <el-button size="small" type="danger" @click="deleteQuestion(row)">
            删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      v-model:current-page="currentPage"
      v-model:page-size="pageSize"
      :total="total"
      :page-sizes="[10, 20, 50, 100]"
      layout="total, sizes, prev, pager, next, jumper"
      @size-change="loadQuestions"
      @current-change="loadQuestions"
    />

    <el-dialog
      v-model="showCreateDialog"
      :title="editingQuestion ? '编辑题目' : '添加题目'"
      width="600px"
    >
      <el-form :model="questionForm" :rules="rules" ref="questionFormRef">
        <el-form-item label="单词" prop="word">
          <el-input v-model="questionForm.word" placeholder="请输入英文单词" />
        </el-form-item>
        <el-form-item label="分类" prop="category">
          <el-select v-model="questionForm.category" placeholder="请选择分类">
            <el-option label="动物" value="动物" />
            <el-option label="水果" value="水果" />
            <el-option label="颜色" value="颜色" />
            <el-option label="数字" value="数字" />
            <el-option label="其他" value="其他" />
          </el-select>
        </el-form-item>
        <el-form-item label="难度" prop="difficulty">
          <el-select v-model="questionForm.difficulty" placeholder="请选择难度">
            <el-option label="简单" value="简单" />
            <el-option label="中等" value="中等" />
            <el-option label="困难" value="困难" />
          </el-select>
        </el-form-item>
        <el-form-item label="音频文件" prop="audio_url">
          <el-upload
            class="audio-uploader"
            :show-file-list="false"
            :on-success="handleAudioUpload"
            :before-upload="beforeAudioUpload"
          >
            <el-button type="primary">上传音频</el-button>
            <template #tip>
              <div class="el-upload__tip">
                只能上传MP3文件，且不超过5MB
              </div>
            </template>
          </el-upload>
          <div v-if="questionForm.audio_url" class="audio-preview">
            <audio :src="questionForm.audio_url" controls />
          </div>
        </el-form-item>
        <el-form-item label="选项" prop="options">
          <div class="options-editor">
            <div
              v-for="(option, index) in questionForm.options"
              :key="index"
              class="option-item"
            >
              <span class="option-label">{{ ['A', 'B', 'C', 'D'][index] }}</span>
              <el-input
                v-model="option.text"
                placeholder="中文释义"
                style="width: 150px"
              />
              <el-upload
                class="image-uploader"
                :show-file-list="false"
                :on-success="(res) => handleImageUpload(res, index)"
                :before-upload="beforeImageUpload"
              >
                <el-button size="small">上传图片</el-button>
              </el-upload>
              <img
                v-if="option.image"
                :src="option.image"
                class="option-image"
              />
            </div>
          </div>
        </el-form-item>
        <el-form-item label="正确答案" prop="correct_answer">
          <el-radio-group v-model="questionForm.correct_answer">
            <el-radio :label="0">A</el-radio>
            <el-radio :label="1">B</el-radio>
            <el-radio :label="2">C</el-radio>
            <el-radio :label="3">D</el-radio>
          </el-radio-group>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showCreateDialog = false">取消</el-button>
        <el-button type="primary" @click="submitQuestion">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { supabase } from '@/config/supabase'

const questions = ref([])
const searchKeyword = ref('')
const selectedCategory = ref('')
const selectedDifficulty = ref('')
const selectedStatus = ref('')
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

const showCreateDialog = ref(false)
const editingQuestion = ref(null)

const questionFormRef = ref(null)
const questionForm = reactive({
  word: '',
  category: '',
  difficulty: '',
  audio_url: '',
  options: [
    { text: '', image: '' },
    { text: '', image: '' },
    { text: '', image: '' },
    { text: '', image: '' }
  ],
  correct_answer: 0
})

const rules = {
  word: [
    { required: true, message: '请输入单词', trigger: 'blur' }
  ],
  category: [
    { required: true, message: '请选择分类', trigger: 'change' }
  ],
  difficulty: [
    { required: true, message: '请选择难度', trigger: 'change' }
  ],
  audio_url: [
    { required: true, message: '请上传音频', trigger: 'change' }
  ],
  correct_answer: [
    { required: true, message: '请选择正确答案', trigger: 'change' }
  ]
}

onMounted(async () => {
  await loadQuestions()
})

async function loadQuestions() {
  try {
    let query = supabase
      .from('questions')
      .select('*', { count: 'exact' })

    if (searchKeyword.value) {
      query = query.ilike('word', `%${searchKeyword.value}%`)
    }
    if (selectedCategory.value) {
      query = query.eq('category', selectedCategory.value)
    }
    if (selectedDifficulty.value) {
      query = query.eq('difficulty', selectedDifficulty.value)
    }
    if (selectedStatus.value) {
      query = query.eq('status', selectedStatus.value)
    }

    const { data, error, count } = await query
      .range((currentPage.value - 1) * pageSize.value, currentPage.value * pageSize.value - 1)
      .order('created_at', { ascending: false })

    if (error) throw error

    questions.value = data.map(item => ({
      ...item,
      options: JSON.parse(item.options)
    }))
    total.value = count
  } catch (error) {
    console.error('加载题目失败:', error)
    ElMessage.error('加载题目失败')
  }
}

function resetFilter() {
  searchKeyword.value = ''
  selectedCategory.value = ''
  selectedDifficulty.value = ''
  selectedStatus.value = ''
  currentPage.value = 1
  loadQuestions()
}

function playAudio(url) {
  const audio = new Audio(url)
  audio.play()
}

function getStatusType(status) {
  const types = {
    pending: 'warning',
    approved: 'success',
    rejected: 'danger'
  }
  return types[status] || 'info'
}

function getStatusText(status) {
  const texts = {
    pending: '待审核',
    approved: '已通过',
    rejected: '已驳回'
  }
  return texts[status] || '未知'
}

async function submitQuestion() {
  const valid = await questionFormRef.value.validate()
  if (!valid) return

  try {
    const teacherId = userStore.user?.id

    if (editingQuestion.value) {
      const { error } = await supabase
        .from('questions')
        .update({
          word: questionForm.word,
          category: questionForm.category,
          difficulty: questionForm.difficulty,
          audio_url: questionForm.audio_url,
          options: JSON.stringify(questionForm.options),
          correct_answer: questionForm.correct_answer
        })
        .eq('id', editingQuestion.value.id)

      if (error) throw error

      ElMessage.success('更新成功')
    } else {
      const { error } = await supabase
        .from('questions')
        .insert({
          word: questionForm.word,
          category: questionForm.category,
          difficulty: questionForm.difficulty,
          audio_url: questionForm.audio_url,
          options: JSON.stringify(questionForm.options),
          correct_answer: questionForm.correct_answer,
          status: 'pending',
          created_by: teacherId
        })

      if (error) throw error

      ElMessage.success('添加成功')
    }

    showCreateDialog.value = false
    await loadQuestions()
  } catch (error) {
    console.error('操作失败:', error)
    ElMessage.error('操作失败，请重试')
  }
}

function editQuestion(row) {
  editingQuestion.value = row
  questionForm.word = row.word
  questionForm.category = row.category
  questionForm.difficulty = row.difficulty
  questionForm.audio_url = row.audio_url
  questionForm.options = row.options
  questionForm.correct_answer = row.correct_answer
  showCreateDialog.value = true
}

function viewQuestion(row) {
  editingQuestion.value = row
  questionForm.word = row.word
  questionForm.category = row.category
  questionForm.difficulty = row.difficulty
  questionForm.audio_url = row.audio_url
  questionForm.options = row.options
  questionForm.correct_answer = row.correct_answer
  showCreateDialog.value = true
}

async function approveQuestion(row) {
  try {
    const { error } = await supabase
      .from('questions')
      .update({ status: 'approved' })
      .eq('id', row.id)

    if (error) throw error

    ElMessage.success('审核通过')
    await loadQuestions()
  } catch (error) {
    console.error('审核失败:', error)
    ElMessage.error('审核失败，请重试')
  }
}

async function rejectQuestion(row) {
  try {
    const { value: reason } = await ElMessageBox.prompt(
      '请输入驳回原因',
      '驳回题目',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        inputPattern: /.+/,
        inputErrorMessage: '请输入驳回原因'
      }
    )

    const { error } = await supabase
      .from('questions')
      .update({ status: 'rejected', reject_reason: reason })
      .eq('id', row.id)

    if (error) throw error

    ElMessage.success('已驳回')
    await loadQuestions()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('驳回失败:', error)
      ElMessage.error('驳回失败，请重试')
    }
  }
}

async function deleteQuestion(row) {
  try {
    await ElMessageBox.confirm(
      `确定要删除题目"${row.word}"吗？`,
      '确认删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const { error } = await supabase
      .from('questions')
      .delete()
      .eq('id', row.id)

    if (error) throw error

    ElMessage.success('删除成功')
    await loadQuestions()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除失败:', error)
      ElMessage.error('删除失败，请重试')
    }
  }
}

function beforeAudioUpload(file) {
  const isMP3 = file.type === 'audio/mpeg'
  const isLt5M = file.size / 1024 / 1024 < 5

  if (!isMP3) {
    ElMessage.error('只能上传MP3格式的音频文件')
    return false
  }
  if (!isLt5M) {
    ElMessage.error('音频文件大小不能超过5MB')
    return false
  }
  return true
}

function beforeImageUpload(file) {
  const isImage = file.type.startsWith('image/')
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isImage) {
    ElMessage.error('只能上传图片文件')
    return false
  }
  if (!isLt2M) {
    ElMessage.error('图片大小不能超过2MB')
    return false
  }
  return true
}

function handleAudioUpload(response) {
  questionForm.audio_url = response.url
}

function handleImageUpload(response, index) {
  questionForm.options[index].image = response.url
}

function formatDate(dateString) {
  const date = new Date(dateString)
  const month = date.getMonth() + 1
  const day = date.getDate()
  return `${month}-${day}`
}
</script>

<style scoped>
.questions-container {
  padding: 20px;
}

.page-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.page-header h2 {
  margin: 0;
}

.filter-bar {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.options-preview {
  display: flex;
  flex-direction: column;
  gap: 4px;
  font-size: 12px;
  color: #666;
}

.options-editor {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.option-item {
  display: flex;
  align-items: center;
  gap: 12px;
}

.option-label {
  width: 24px;
  height: 24px;
  background: #409eff;
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: bold;
}

.option-image {
  width: 60px;
  height: 60px;
  object-fit: cover;
  border-radius: 4px;
}

.audio-preview {
  margin-top: 8px;
}

.audio-preview audio {
  width: 100%;
}
</style>
