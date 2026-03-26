<template>
  <div class="create-assignment-container">
    <div class="page-header">
      <h2>发布作业</h2>
      <el-button @click="router.back()">返回</el-button>
    </div>

    <el-card>
      <el-form :model="assignmentForm" :rules="rules" ref="assignmentFormRef">
        <el-form-item label="作业名称" prop="title">
          <el-input v-model="assignmentForm.title" placeholder="请输入作业名称" />
        </el-form-item>

        <el-form-item label="选择班级" prop="class_id">
          <el-select v-model="assignmentForm.class_id" placeholder="请选择班级">
            <el-option
              v-for="cls in classes"
              :key="cls.id"
              :label="cls.name"
              :value="cls.id"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="发布日期" prop="publish_date">
          <el-date-picker
            v-model="assignmentForm.publish_date"
            type="date"
            placeholder="选择发布日期"
          />
        </el-form-item>

        <el-form-item label="截止日期">
          <el-date-picker
            v-model="assignmentForm.deadline"
            type="date"
            placeholder="选择截止日期（可选）"
          />
        </el-form-item>

        <el-form-item label="预计用时（分钟）">
          <el-input-number
            v-model="assignmentForm.estimated_time"
            :min="1"
            :max="60"
          />
        </el-form-item>

        <el-form-item label="作业说明">
          <el-input
            v-model="assignmentForm.description"
            type="textarea"
            :rows="4"
            placeholder="请输入作业说明（可选）"
          />
        </el-form-item>

        <el-divider />

        <el-form-item label="题目选择方式">
          <el-radio-group v-model="selectionMode">
            <el-radio label="manual">手动选题</el-radio>
            <el-radio label="auto">自动组题</el-radio>
          </el-radio-group>
        </el-form-item>

        <template v-if="selectionMode === 'manual'">
          <el-form-item label="选择题目">
            <div class="question-selector">
              <div class="filter-bar">
                <el-select
                  v-model="filterCategory"
                  placeholder="选择分类"
                  style="width: 150px"
                  clearable
                >
                  <el-option label="动物" value="动物" />
                  <el-option label="水果" value="水果" />
                  <el-option label="颜色" value="颜色" />
                  <el-option label="数字" value="数字" />
                </el-select>
                <el-select
                  v-model="filterDifficulty"
                  placeholder="选择难度"
                  style="width: 150px"
                  clearable
                >
                  <el-option label="简单" value="简单" />
                  <el-option label="中等" value="中等" />
                  <el-option label="困难" value="困难" />
                </el-select>
                <el-button type="primary" @click="loadQuestions">搜索</el-button>
              </div>

              <el-table
                ref="questionTableRef"
                :data="availableQuestions"
                style="width: 100%"
                @selection-change="handleSelectionChange"
              >
                <el-table-column type="selection" width="55" />
                <el-table-column prop="word" label="单词" width="120" />
                <el-table-column prop="category" label="分类" width="100" />
                <el-table-column prop="difficulty" label="难度" width="100" />
                <el-table-column label="操作" width="100">
                  <template #default="{ row }">
                    <el-button size="small" @click="previewQuestion(row)">
                      预览
                    </el-button>
                  </template>
                </el-table-column>
              </el-table>

              <el-pagination
                v-model:current-page="questionPage"
                v-model:page-size="questionPageSize"
                :total="questionTotal"
                :page-sizes="[10, 20, 50]"
                layout="total, sizes, prev, pager, next"
                @size-change="loadQuestions"
                @current-change="loadQuestions"
              />
            </div>
          </el-form-item>
        </template>

        <template v-else>
          <el-form-item label="题目数量">
            <el-input-number
              v-model="autoQuestionCount"
              :min="5"
              :max="50"
            />
          </el-form-item>

          <el-form-item label="题目分类">
            <el-checkbox-group v-model="selectedCategories">
              <el-checkbox label="动物">动物</el-checkbox>
              <el-checkbox label="水果">水果</el-checkbox>
              <el-checkbox label="颜色">颜色</el-checkbox>
              <el-checkbox label="数字">数字</el-checkbox>
              <el-checkbox label="其他">其他</el-checkbox>
            </el-checkbox-group>
          </el-form-item>

          <el-form-item label="题目难度">
            <el-checkbox-group v-model="selectedDifficulties">
              <el-checkbox label="简单">简单</el-checkbox>
              <el-checkbox label="中等">中等</el-checkbox>
              <el-checkbox label="困难">困难</el-checkbox>
            </el-checkbox-group>
          </el-form-item>

          <el-button type="primary" @click="generateQuestions">
            生成题目
          </el-button>

          <el-table v-if="generatedQuestions.length > 0" :data="generatedQuestions" style="width: 100%">
            <el-table-column prop="word" label="单词" />
            <el-table-column prop="category" label="分类" />
            <el-table-column prop="difficulty" label="难度" />
          </el-table>
        </template>

        <el-divider />

        <el-form-item label="已选题目">
          <el-tag
            v-for="(question, index) in selectedQuestions"
            :key="question.id"
            closable
            @close="removeQuestion(index)"
            style="margin-right: 8px; margin-bottom: 8px"
          >
            {{ question.word }}
          </el-tag>
          <span v-if="selectedQuestions.length === 0" style="color: #999">
            尚未选择题目
          </span>
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="previewAssignment">
            预览作业
          </el-button>
          <el-button type="success" @click="submitAssignment">
            发布作业
          </el-button>
          <el-button @click="saveAsTemplate">
            保存为模板
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-dialog v-model="showPreviewDialog" title="预览题目" width="600px">
      <div v-if="previewQuestionData" class="question-preview">
        <h3>{{ previewQuestionData.word }}</h3>
        <audio :src="previewQuestionData.audio_url" controls />
        <div class="options">
          <div
            v-for="(option, index) in previewQuestionData.options"
            :key="index"
            class="option"
          >
            <span class="option-label">{{ ['A', 'B', 'C', 'D'][index] }}</span>
            <span class="option-text">{{ option.text }}</span>
            <img :src="option.image" class="option-image" />
          </div>
        </div>
      </div>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { supabase } from '@/config/supabase'

const router = useRouter()

const assignmentFormRef = ref(null)
const questionTableRef = ref(null)

const classes = ref([])
const availableQuestions = ref([])
const selectedQuestions = ref([])
const generatedQuestions = ref([])
const selectionMode = ref('manual')

const filterCategory = ref('')
const filterDifficulty = ref('')
const questionPage = ref(1)
const questionPageSize = ref(10)
const questionTotal = ref(0)

const autoQuestionCount = ref(10)
const selectedCategories = ref([])
const selectedDifficulties = ref([])

const showPreviewDialog = ref(false)
const previewQuestionData = ref(null)

const assignmentForm = reactive({
  title: '',
  class_id: '',
  publish_date: new Date(),
  deadline: null,
  estimated_time: 10,
  description: ''
})

const rules = {
  title: [
    { required: true, message: '请输入作业名称', trigger: 'blur' }
  ],
  class_id: [
    { required: true, message: '请选择班级', trigger: 'change' }
  ],
  publish_date: [
    { required: true, message: '请选择发布日期', trigger: 'change' }
  ]
}

onMounted(async () => {
  await loadClasses()
  await loadQuestions()
})

async function loadClasses() {
  try {
    const teacherId = userStore.user?.id

    const { data, error } = await supabase
      .from('classes')
      .select('id, name')
      .eq('teacher_id', teacherId)
      .order('created_at', { ascending: false })

    if (error) throw error

    classes.value = data
  } catch (error) {
    console.error('加载班级列表失败:', error)
  }
}

async function loadQuestions() {
  try {
    let query = supabase
      .from('questions')
      .select('*', { count: 'exact' })
      .eq('status', 'approved')

    if (filterCategory.value) {
      query = query.eq('category', filterCategory.value)
    }
    if (filterDifficulty.value) {
      query = query.eq('difficulty', filterDifficulty.value)
    }

    const { data, error, count } = await query
      .range((questionPage.value - 1) * questionPageSize.value, questionPage.value * questionPageSize.value - 1)
      .order('created_at', { ascending: false })

    if (error) throw error

    availableQuestions.value = data.map(item => ({
      ...item,
      options: JSON.parse(item.options)
    }))
    questionTotal.value = count
  } catch (error) {
    console.error('加载题目失败:', error)
    ElMessage.error('加载题目失败')
  }
}

function handleSelectionChange(selection) {
  selectedQuestions.value = selection
}

function removeQuestion(index) {
  selectedQuestions.value.splice(index, 1)
}

async function generateQuestions() {
  if (selectedCategories.value.length === 0) {
    ElMessage.warning('请至少选择一个分类')
    return
  }
  if (selectedDifficulties.value.length === 0) {
    ElMessage.warning('请至少选择一个难度')
    return
  }

  try {
    let query = supabase
      .from('questions')
      .select('*')
      .eq('status', 'approved')
      .in('category', selectedCategories.value)
      .in('difficulty', selectedDifficulties.value)

    const { data, error } = await query

    if (error) throw error

    const shuffled = data.sort(() => Math.random() - 0.5)
    generatedQuestions.value = shuffled.slice(0, autoQuestionCount.value).map(item => ({
      ...item,
      options: JSON.parse(item.options)
    }))

    selectedQuestions.value = generatedQuestions.value

    ElMessage.success(`已生成${generatedQuestions.value.length}道题目`)
  } catch (error) {
    console.error('生成题目失败:', error)
    ElMessage.error('生成题目失败')
  }
}

function previewQuestion(question) {
  previewQuestionData.value = question
  showPreviewDialog.value = true
}

function previewAssignment() {
  if (selectedQuestions.value.length === 0) {
    ElMessage.warning('请先选择题目')
    return
  }
  ElMessage.info('预览功能开发中...')
}

async function submitAssignment() {
  const valid = await assignmentFormRef.value.validate()
  if (!valid) return

  if (selectedQuestions.value.length === 0) {
    ElMessage.warning('请至少选择一道题目')
    return
  }

  try {
    const teacherId = userStore.user?.id

    const { data: assignment, error: assignmentError } = await supabase
      .from('assignments')
      .insert({
        teacher_id: teacherId,
        class_id: assignmentForm.class_id,
        title: assignmentForm.title,
        description: assignmentForm.description,
        question_count: selectedQuestions.value.length,
        estimated_time: assignmentForm.estimated_time,
        publish_date: assignmentForm.publish_date.toISOString().split('T')[0],
        deadline: assignmentForm.deadline ? assignmentForm.deadline.toISOString().split('T')[0] : null,
        status: 'published'
      })
      .select()
      .single()

    if (assignmentError) throw assignmentError

    const assignmentQuestions = selectedQuestions.value.map((question, index) => ({
      assignment_id: assignment.id,
      question_id: question.id,
      order_num: index + 1
    }))

    const { error: questionsError } = await supabase
      .from('assignment_questions')
      .insert(assignmentQuestions)

    if (questionsError) throw questionsError

    ElMessage.success('作业发布成功')
    router.push('/teacher/assignments')
  } catch (error) {
    console.error('发布作业失败:', error)
    ElMessage.error('发布作业失败，请重试')
  }
}

function saveAsTemplate() {
  ElMessage.info('保存模板功能开发中...')
}
</script>

<style scoped>
.create-assignment-container {
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
  margin-bottom: 16px;
}

.question-selector {
  border: 1px solid #e8e8e8;
  border-radius: 4px;
  padding: 16px;
}

.question-preview {
  text-align: center;
}

.question-preview h3 {
  margin-bottom: 16px;
}

.question-preview audio {
  width: 100%;
  margin-bottom: 20px;
}

.options {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 16px;
}

.option {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 12px;
  background: #f8f8f8;
  border-radius: 8px;
}

.option-label {
  width: 32px;
  height: 32px;
  background: #409eff;
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 8px;
}

.option-text {
  margin-bottom: 8px;
}

.option-image {
  width: 100px;
  height: 100px;
  object-fit: cover;
  border-radius: 4px;
}
</style>
