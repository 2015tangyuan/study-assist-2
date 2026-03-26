<template>
  <div class="dashboard-container">
    <div class="stats-cards">
      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon" style="background: #409eff">
            <el-icon :size="24"><User /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.total_classes || 0 }}</div>
            <div class="stat-label">班级总数</div>
          </div>
        </div>
      </el-card>

      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon" style="background: #67c23a">
            <el-icon :size="24"><UserFilled /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.total_students || 0 }}</div>
            <div class="stat-label">学生总数</div>
          </div>
        </div>
      </el-card>

      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon" style="background: #e6a23c">
            <el-icon :size="24"><Document /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.total_questions || 0 }}</div>
            <div class="stat-label">题库总数</div>
          </div>
        </div>
      </el-card>

      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon" style="background: #f56c6c">
            <el-icon :size="24"><TrendCharts /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ stats.today_completion || 0 }}%</div>
            <div class="stat-label">今日完成率</div>
          </div>
        </div>
      </el-card>
    </div>

    <div class="content-sections">
      <el-card class="section-card">
        <template #header>
          <div class="card-header">
            <span>近期作业</span>
            <el-button type="primary" size="small" @click="createAssignment">
              发布作业
            </el-button>
          </div>
        </template>

        <el-table :data="recentAssignments" style="width: 100%">
          <el-table-column prop="title" label="作业名称" />
          <el-table-column prop="class_name" label="班级" />
          <el-table-column prop="publish_date" label="发布时间">
            <template #default="{ row }">
              {{ formatDate(row.publish_date) }}
            </template>
          </el-table-column>
          <el-table-column prop="completion_rate" label="完成率">
            <template #default="{ row }">
              {{ row.completion_rate }}%
            </template>
          </el-table-column>
          <el-table-column prop="average_score" label="平均分" />
          <el-table-column label="操作" width="200">
            <template #default="{ row }">
              <el-button size="small" @click="viewDetail(row)">查看详情</el-button>
              <el-button size="small" type="primary" @click="viewResults(row)">
                查看结果
              </el-button>
            </template>
          </el-table-column>
        </el-table>
      </el-card>

      <el-card class="section-card">
        <template #header>
          <div class="card-header">
            <span>待办事项</span>
            <el-badge :value="todoCount" class="todo-badge" />
          </div>
        </template>

        <div class="todo-list">
          <div
            v-for="todo in todos"
            :key="todo.id"
            class="todo-item"
            :class="{ 'urgent': todo.urgent }"
          >
            <div class="todo-icon">
              <el-icon v-if="todo.type === 'comment'"><ChatDotRound /></el-icon>
              <el-icon v-else-if="todo.type === 'assignment'"><Edit /></el-icon>
              <el-icon v-else><Bell /></el-icon>
            </div>
            <div class="todo-content">
              <div class="todo-title">{{ todo.title }}</div>
              <div class="todo-time">{{ todo.time }}</div>
            </div>
            <el-button size="small" type="primary" @click="handleTodo(todo)">
              处理
            </el-button>
          </div>
          <el-empty v-if="todos.length === 0" description="暂无待办事项" />
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '@/config/supabase'
import { User, UserFilled, Document, TrendCharts, ChatDotRound, Edit, Bell } from '@element-plus/icons-vue'

const router = useRouter()

const stats = ref({
  total_classes: 0,
  total_students: 0,
  total_questions: 0,
  today_completion: 0
})
const recentAssignments = ref([])
const todos = ref([])

const todoCount = computed(() => todos.value.length)

onMounted(async () => {
  await loadStats()
  await loadRecentAssignments()
  await loadTodos()
})

async function loadStats() {
  try {
    const teacherId = userStore.user?.id

    const { data: classesData } = await supabase
      .from('classes')
      .select('id')
      .eq('teacher_id', teacherId)

    const classIds = classesData?.map(c => c.id) || []

    const { data: studentsData } = await supabase
      .from('students')
      .select('id')
      .in('class_id', classIds)

    const { data: questionsData } = await supabase
      .from('questions')
      .select('id')

    const today = new Date().toISOString().split('T')[0]
    const { data: assignmentsData } = await supabase
      .from('assignments')
      .select('id, completion_rate')
      .eq('publish_date', today)

    stats.value = {
      total_classes: classesData?.length || 0,
      total_students: studentsData?.length || 0,
      total_questions: questionsData?.length || 0,
      today_completion: assignmentsData?.[0]?.completion_rate || 0
    }
  } catch (error) {
    console.error('加载统计数据失败:', error)
  }
}

async function loadRecentAssignments() {
  try {
    const teacherId = userStore.user?.id

    const { data, error } = await supabase
      .from('assignments')
      .select('*, classes(name)')
      .eq('teacher_id', teacherId)
      .order('publish_date', { ascending: false })
      .limit(10)

    if (data) {
      recentAssignments.value = data.map(item => ({
        ...item,
        class_name: item.classes?.name || '未知班级'
      }))
    }
  } catch (error) {
    console.error('加载近期作业失败:', error)
  }
}

async function loadTodos() {
  try {
    const teacherId = userStore.user?.id

    const { data, error } = await supabase
      .from('todos')
      .select('*')
      .eq('teacher_id', teacherId)
      .eq('completed', false)
      .order('created_at', { ascending: false })

    if (data) {
      todos.value = data.map(item => ({
        ...item,
        type: item.type || 'other',
        urgent: item.urgent || false,
        time: formatDate(item.created_at)
      }))
    }
  } catch (error) {
    console.error('加载待办事项失败:', error)
  }
}

function createAssignment() {
  router.push('/teacher/assignments/create')
}

function viewDetail(assignment) {
  router.push(`/teacher/assignments/${assignment.id}`)
}

function viewResults(assignment) {
  router.push(`/teacher/analysis?assignment_id=${assignment.id}`)
}

function handleTodo(todo) {
  router.push(todo.link || '/teacher')
}

function formatDate(dateString) {
  const date = new Date(dateString)
  const month = date.getMonth() + 1
  const day = date.getDate()
  return `${month}月${day}日`
}
</script>

<style scoped>
.dashboard-container {
  padding: 20px;
}

.stats-cards {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 20px;
  margin-bottom: 20px;
}

.stat-card {
  cursor: pointer;
  transition: all 0.3s ease;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 16px;
}

.stat-icon {
  width: 56px;
  height: 56px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  color: #333;
  margin-bottom: 4px;
}

.stat-label {
  font-size: 14px;
  color: #999;
}

.content-sections {
  display: grid;
  grid-template-columns: 2fr 1fr;
  gap: 20px;
}

.section-card {
  height: 100%;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.todo-badge {
  margin-left: 8px;
}

.todo-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.todo-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  background: #f8f8f8;
  border-radius: 8px;
  border-left: 3px solid #409eff;
}

.todo-item.urgent {
  border-left-color: #f56c6c;
  background: #fff0f0;
}

.todo-icon {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: white;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #409eff;
}

.todo-content {
  flex: 1;
}

.todo-title {
  font-size: 14px;
  color: #333;
  margin-bottom: 4px;
}

.todo-time {
  font-size: 12px;
  color: #999;
}
</style>
