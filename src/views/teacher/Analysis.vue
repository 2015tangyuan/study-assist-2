<template>
  <div class="analysis-container">
    <div class="page-header">
      <h2>学情分析</h2>
      <el-button @click="exportReport">导出报告</el-button>
    </div>

    <el-tabs v-model="activeTab">
      <el-tab-pane label="班级分析" name="class">
        <div class="analysis-content">
          <div class="filter-bar">
            <el-select
              v-model="selectedClass"
              placeholder="选择班级"
              style="width: 200px"
              @change="loadClassAnalysis"
            >
              <el-option
                v-for="cls in classes"
                :key="cls.id"
                :label="cls.name"
                :value="cls.id"
              />
            </el-select>
            <el-date-picker
              v-model="dateRange"
              type="daterange"
              range-separator="至"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
              @change="loadClassAnalysis"
            />
          </div>

          <el-row :gutter="20" class="stats-row">
            <el-col :span="6">
              <el-card>
                <div class="stat-item">
                  <div class="stat-value">{{ classStats.average_score || 0 }}%</div>
                  <div class="stat-label">平均正确率</div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="6">
              <el-card>
                <div class="stat-item">
                  <div class="stat-value">{{ classStats.completion_rate || 0 }}%</div>
                  <div class="stat-label">作业完成率</div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="6">
              <el-card>
                <div class="stat-item">
                  <div class="stat-value">{{ classStats.total_assignments || 0 }}</div>
                  <div class="stat-label">总作业数</div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="6">
              <el-card>
                <div class="stat-item">
                  <div class="stat-value">{{ classStats.active_students || 0 }}</div>
                  <div class="stat-label">活跃学生</div>
                </div>
              </el-card>
            </el-col>
          </el-row>

          <el-card class="chart-card">
            <template #header>
              <span>学习趋势</span>
            </template>
            <div class="chart-placeholder">
              <el-icon :size="48" color="#409eff"><TrendCharts /></el-icon>
              <p>学习趋势图表</p>
            </div>
          </el-card>

          <el-card class="chart-card">
            <template #header>
              <span>知识点掌握情况</span>
            </template>
            <el-table :data="knowledgePoints" style="width: 100%">
              <el-table-column prop="category" label="知识点" />
              <el-table-column prop="mastery_rate" label="掌握率">
                <template #default="{ row }">
                  <el-progress
                    :percentage="row.mastery_rate"
                    :color="getProgressColor(row.mastery_rate)"
                  />
                </template>
              </el-table-column>
              <el-table-column prop="error_count" label="错误次数" />
            </el-table>
          </el-card>
        </div>
      </el-tab-pane>

      <el-tab-pane label="学生分析" name="student">
        <div class="analysis-content">
          <div class="filter-bar">
            <el-select
              v-model="selectedClass"
              placeholder="选择班级"
              style="width: 200px"
              @change="loadStudentAnalysis"
            >
              <el-option
                v-for="cls in classes"
                :key="cls.id"
                :label="cls.name"
                :value="cls.id"
              />
            </el-select>
            <el-input
              v-model="searchKeyword"
              placeholder="搜索学生姓名"
              style="width: 200px"
              clearable
              @input="loadStudentAnalysis"
            />
          </div>

          <el-table :data="students" style="width: 100%">
            <el-table-column prop="name" label="姓名" />
            <el-table-column prop="avatar" label="头像">
              <template #default="{ row }">
                <el-avatar :size="40" :src="row.avatar" />
              </template>
            </el-table-column>
            <el-table-column prop="level" label="等级">
              <template #default="{ row }">
                Lv.{{ row.level || 1 }}
              </template>
            </el-table-column>
            <el-table-column prop="total_assignments" label="完成作业" />
            <el-table-column prop="accuracy" label="正确率">
              <template #default="{ row }">
                {{ row.accuracy }}%
              </template>
            </el-table-column>
            <el-table-column prop="continuous_days" label="连续学习" />
            <el-table-column label="操作">
              <template #default="{ row }">
                <el-button size="small" @click="viewStudentDetail(row)">
                  查看详情
                </el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>

      <el-tab-pane label="作业分析" name="assignment">
        <div class="analysis-content">
          <div class="filter-bar">
            <el-select
              v-model="selectedAssignment"
              placeholder="选择作业"
              style="width: 300px"
              @change="loadAssignmentAnalysis"
            >
              <el-option
                v-for="assignment in assignments"
                :key="assignment.id"
                :label="assignment.title"
                :value="assignment.id"
              />
            </el-select>
          </div>

          <el-row :gutter="20" class="stats-row">
            <el-col :span="8">
              <el-card>
                <div class="stat-item">
                  <div class="stat-value">{{ assignmentStats.average_score || 0 }}分</div>
                  <div class="stat-label">平均分</div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="8">
              <el-card>
                <div class="stat-item">
                  <div class="stat-value">{{ assignmentStats.completion_rate || 0 }}%</div>
                  <div class="stat-label">完成率</div>
                </div>
              </el-card>
            </el-col>
            <el-col :span="8">
              <el-card>
                <div class="stat-item">
                  <div class="stat-value">{{ assignmentStats.highest_score || 0 }}分</div>
                  <div class="stat-label">最高分</div>
                </div>
              </el-card>
            </el-col>
          </el-row>

          <el-card>
            <template #header>
              <span>学生答题详情</span>
            </template>
            <el-table :data="assignmentResults" style="width: 100%">
              <el-table-column prop="student_name" label="学生姓名" />
              <el-table-column prop="score" label="得分" />
              <el-table-column prop="correct_count" label="正确题数" />
              <el-table-column prop="time_spent" label="用时">
                <template #default="{ row }">
                  {{ formatTime(row.time_spent) }}
                </template>
              </el-table-column>
              <el-table-column prop="completed_at" label="完成时间">
                <template #default="{ row }">
                  {{ formatDateTime(row.completed_at) }}
                </template>
              </el-table-column>
              <el-table-column label="操作">
                <template #default="{ row }">
                  <el-button size="small" @click="viewStudentResult(row)">
                    查看详情
                  </el-button>
                  <el-button size="small" type="primary" @click="addComment(row)">
                    添加评语
                  </el-button>
                </template>
              </el-table-column>
            </el-table>
          </el-card>
        </div>
      </el-tab-pane>
    </el-tabs>

    <el-dialog v-model="showCommentDialog" title="添加评语" width="500px">
      <el-form>
        <el-form-item label="评语内容">
          <el-input
            v-model="commentText"
            type="textarea"
            :rows="4"
            placeholder="请输入评语"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showCommentDialog = false">取消</el-button>
        <el-button type="primary" @click="submitComment">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { TrendCharts } from '@element-plus/icons-vue'
import { supabase } from '@/config/supabase'

const router = useRouter()

const activeTab = ref('class')
const classes = ref([])
const assignments = ref([])
const students = ref([])
const knowledgePoints = ref([])
const assignmentResults = ref([])

const selectedClass = ref('')
const selectedAssignment = ref('')
const searchKeyword = ref('')
const dateRange = ref([])

const classStats = reactive({
  average_score: 0,
  completion_rate: 0,
  total_assignments: 0,
  active_students: 0
})

const assignmentStats = reactive({
  average_score: 0,
  completion_rate: 0,
  highest_score: 0
})

const showCommentDialog = ref(false)
const commentText = ref('')
const currentResult = ref(null)

onMounted(async () => {
  await loadClasses()
  await loadAssignments()
  
  if (classes.value.length > 0) {
    selectedClass.value = classes.value[0].id
    await loadClassAnalysis()
  }
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

async function loadAssignments() {
  try {
    const teacherId = userStore.user?.id

    const { data, error } = await supabase
      .from('assignments')
      .select('id, title')
      .eq('teacher_id', teacherId)
      .order('publish_date', { ascending: false })

    if (error) throw error

    assignments.value = data
  } catch (error) {
    console.error('加载作业列表失败:', error)
  }
}

async function loadClassAnalysis() {
  if (!selectedClass.value) return

  try {
    const { data: results, error } = await supabase
      .from('assignment_results')
      .select('score, completed_at')
      .eq('students.class_id', selectedClass.value)

    if (error) throw error

    if (results.length > 0) {
      classStats.average_score = Math.round(
        results.reduce((sum, r) => sum + r.score, 0) / results.length
      )
      classStats.total_assignments = results.length
    }

    classStats.completion_rate = 85
    classStats.active_students = 20

    knowledgePoints.value = [
      { category: '动物', mastery_rate: 85, error_count: 15 },
      { category: '水果', mastery_rate: 78, error_count: 22 },
      { category: '颜色', mastery_rate: 92, error_count: 8 },
      { category: '数字', mastery_rate: 88, error_count: 12 }
    ]
  } catch (error) {
    console.error('加载班级分析失败:', error)
  }
}

async function loadStudentAnalysis() {
  if (!selectedClass.value) return

  try {
    let query = supabase
      .from('students')
      .select('*, student_stats(*)')

    if (searchKeyword.value) {
      query = query.ilike('name', `%${searchKeyword.value}%`)
    }

    const { data, error } = await query
      .eq('class_id', selectedClass.value)
      .order('created_at', { ascending: false })

    if (error) throw error

    students.value = data.map(item => ({
      ...item,
      ...item.student_stats
    }))
  } catch (error) {
    console.error('加载学生分析失败:', error)
  }
}

async function loadAssignmentAnalysis() {
  if (!selectedAssignment.value) return

  try {
    const { data, error } = await supabase
      .from('assignment_results')
      .select('*, students(name)')
      .eq('assignment_id', selectedAssignment.value)

    if (error) throw error

    assignmentResults.value = data.map(item => ({
      ...item,
      student_name: item.students?.name || '未知'
    }))

    if (data.length > 0) {
      assignmentStats.average_score = Math.round(
        data.reduce((sum, r) => sum + r.score, 0) / data.length
      )
      assignmentStats.completion_rate = Math.round((data.length / 30) * 100)
      assignmentStats.highest_score = Math.max(...data.map(r => r.score))
    }
  } catch (error) {
    console.error('加载作业分析失败:', error)
  }
}

function viewStudentDetail(row) {
  router.push(`/teacher/analysis?student_id=${row.id}`)
}

function viewStudentResult(row) {
  router.push(`/student/result/${row.id}`)
}

function addComment(row) {
  currentResult.value = row
  commentText.value = row.comment || ''
  showCommentDialog.value = true
}

async function submitComment() {
  try {
    const { error } = await supabase
      .from('assignment_results')
      .update({ comment: commentText.value })
      .eq('id', currentResult.value.id)

    if (error) throw error

    ElMessage.success('评语添加成功')
    showCommentDialog.value = false
    await loadAssignmentAnalysis()
  } catch (error) {
    console.error('添加评语失败:', error)
    ElMessage.error('添加评语失败，请重试')
  }
}

function exportReport() {
  ElMessage.info('导出报告功能开发中...')
}

function getProgressColor(percentage) {
  if (percentage >= 80) return '#67c23a'
  if (percentage >= 60) return '#e6a23c'
  return '#f56c6c'
}

function formatTime(ms) {
  if (!ms) return '0秒'
  const seconds = Math.floor(ms / 1000)
  if (seconds < 60) return `${seconds}秒`
  const minutes = Math.floor(seconds / 60)
  const remainingSeconds = seconds % 60
  return `${minutes}分${remainingSeconds}秒`
}

function formatDateTime(dateString) {
  const date = new Date(dateString)
  const month = date.getMonth() + 1
  const day = date.getDate()
  const hour = date.getHours()
  const minute = date.getMinutes()
  return `${month}月${day}日 ${hour}:${minute.toString().padStart(2, '0')}`
}
</script>

<style scoped>
.analysis-container {
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

.analysis-content {
  padding: 20px 0;
}

.filter-bar {
  display: flex;
  gap: 12px;
  margin-bottom: 20px;
  flex-wrap: wrap;
}

.stats-row {
  margin-bottom: 20px;
}

.stat-item {
  text-align: center;
}

.stat-value {
  font-size: 32px;
  font-weight: bold;
  color: #409eff;
  margin-bottom: 8px;
}

.stat-label {
  font-size: 14px;
  color: #999;
}

.chart-card {
  margin-bottom: 20px;
}

.chart-placeholder {
  height: 300px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  color: #999;
}

.chart-placeholder p {
  margin-top: 16px;
  font-size: 14px;
}
</style>
