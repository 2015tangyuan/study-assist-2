<template>
  <div class="assignments-container">
    <div class="page-header">
      <h2>作业管理</h2>
      <el-button type="primary" @click="router.push('/teacher/assignments/create')">
        发布作业
      </el-button>
    </div>

    <div class="filter-bar">
      <el-select
        v-model="selectedClass"
        placeholder="选择班级"
        style="width: 200px"
        clearable
      >
        <el-option
          v-for="cls in classes"
          :key="cls.id"
          :label="cls.name"
          :value="cls.id"
        />
      </el-select>
      <el-date-picker
        v-model="selectedDate"
        type="daterange"
        range-separator="至"
        start-placeholder="开始日期"
        end-placeholder="结束日期"
        style="width: 300px"
      />
      <el-button type="primary" @click="loadAssignments">搜索</el-button>
      <el-button @click="resetFilter">重置</el-button>
    </div>

    <el-table :data="assignments" style="width: 100%">
      <el-table-column prop="title" label="作业名称" />
      <el-table-column prop="class_name" label="班级" />
      <el-table-column prop="question_count" label="题目数量" />
      <el-table-column prop="estimated_time" label="预计用时">
        <template #default="{ row }">
          {{ row.estimated_time }}分钟
        </template>
      </el-table-column>
      <el-table-column prop="publish_date" label="发布日期">
        <template #default="{ row }">
          {{ formatDate(row.publish_date) }}
        </template>
      </el-table-column>
      <el-table-column prop="deadline" label="截止日期">
        <template #default="{ row }">
          {{ row.deadline ? formatDate(row.deadline) : '无' }}
        </template>
      </el-table-column>
      <el-table-column prop="completion_rate" label="完成率">
        <template #default="{ row }">
          <el-progress
            :percentage="row.completion_rate || 0"
            :color="getProgressColor(row.completion_rate)"
          />
        </template>
      </el-table-column>
      <el-table-column prop="average_score" label="平均分" />
      <el-table-column label="操作" width="300">
        <template #default="{ row }">
          <el-button size="small" @click="viewDetail(row)">
            查看详情
          </el-button>
          <el-button size="small" type="primary" @click="viewResults(row)">
            查看结果
          </el-button>
          <el-button size="small" type="danger" @click="deleteAssignment(row)">
            删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-pagination
      v-model:current-page="currentPage"
      v-model:page-size="pageSize"
      :total="total"
      :page-sizes="[10, 20, 50]"
      layout="total, sizes, prev, pager, next, jumper"
      @size-change="loadAssignments"
      @current-change="loadAssignments"
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { supabase } from '@/config/supabase'

const router = useRouter()

const assignments = ref([])
const classes = ref([])
const selectedClass = ref('')
const selectedDate = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

onMounted(async () => {
  await loadClasses()
  await loadAssignments()
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

    let query = supabase
      .from('assignments')
      .select('*, classes(name), assignment_results(score)', { count: 'exact' })
      .eq('teacher_id', teacherId)

    if (selectedClass.value) {
      query = query.eq('class_id', selectedClass.value)
    }

    if (selectedDate.value && selectedDate.value.length === 2) {
      const [start, end] = selectedDate.value
      query = query.gte('publish_date', start.toISOString().split('T')[0])
      query = query.lte('publish_date', end.toISOString().split('T')[0])
    }

    const { data, error, count } = await query
      .range((currentPage.value - 1) * pageSize.value, currentPage.value * pageSize.value - 1)
      .order('publish_date', { ascending: false })

    if (error) throw error

    assignments.value = data.map(item => {
      const results = item.assignment_results || []
      const completedCount = results.length
      const totalScore = results.reduce((sum, r) => sum + r.score, 0)
      const averageScore = completedCount > 0 ? Math.round(totalScore / completedCount) : 0

      return {
        ...item,
        class_name: item.classes?.name || '未知班级',
        completion_rate: completedCount > 0 ? Math.round((completedCount / 30) * 100) : 0,
        average_score: averageScore
      }
    })

    total.value = count
  } catch (error) {
    console.error('加载作业列表失败:', error)
    ElMessage.error('加载作业列表失败')
  }
}

function resetFilter() {
  selectedClass.value = ''
  selectedDate.value = []
  currentPage.value = 1
  loadAssignments()
}

function viewDetail(row) {
  router.push(`/teacher/assignments/${row.id}`)
}

function viewResults(row) {
  router.push(`/teacher/analysis?assignment_id=${row.id}`)
}

async function deleteAssignment(row) {
  try {
    await ElMessageBox.confirm(
      `确定要删除作业"${row.title}"吗？此操作不可恢复。`,
      '确认删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const { error } = await supabase
      .from('assignments')
      .delete()
      .eq('id', row.id)

    if (error) throw error

    ElMessage.success('删除成功')
    await loadAssignments()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除失败:', error)
      ElMessage.error('删除失败，请重试')
    }
  }
}

function getProgressColor(percentage) {
  if (percentage >= 80) return '#67c23a'
  if (percentage >= 60) return '#e6a23c'
  return '#f56c6c'
}

function formatDate(dateString) {
  const date = new Date(dateString)
  const year = date.getFullYear()
  const month = date.getMonth() + 1
  const day = date.getDate()
  return `${year}-${month}-${day}`
}
</script>

<style scoped>
.assignments-container {
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
</style>
