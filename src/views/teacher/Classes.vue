<template>
  <div class="classes-container">
    <div class="page-header">
      <h2>班级管理</h2>
      <el-button type="primary" @click="showCreateDialog = true">
        创建班级
      </el-button>
    </div>

    <el-table :data="classes" style="width: 100%">
      <el-table-column prop="name" label="班级名称" />
      <el-table-column prop="grade" label="年级" />
      <el-table-column prop="student_count" label="学生数量">
        <template #default="{ row }">
          {{ row.student_count || 0 }}人
        </template>
      </el-table-column>
      <el-table-column prop="invite_code" label="邀请码">
        <template #default="{ row }">
          <el-tag>{{ row.invite_code }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="created_at" label="创建时间">
        <template #default="{ row }">
          {{ formatDate(row.created_at) }}
        </template>
      </el-table-column>
      <el-table-column label="操作" width="300">
        <template #default="{ row }">
          <el-button size="small" @click="viewStudents(row)">
            查看学生
          </el-button>
          <el-button size="small" type="primary" @click="editClass(row)">
            编辑
          </el-button>
          <el-button size="small" type="danger" @click="deleteClass(row)">
            删除
          </el-button>
        </template>
      </el-table-column>
    </el-table>

    <el-dialog
      v-model="showCreateDialog"
      :title="editingClass ? '编辑班级' : '创建班级'"
      width="500px"
    >
      <el-form :model="classForm" :rules="rules" ref="classFormRef">
        <el-form-item label="班级名称" prop="name">
          <el-input v-model="classForm.name" placeholder="请输入班级名称" />
        </el-form-item>
        <el-form-item label="年级" prop="grade">
          <el-select v-model="classForm.grade" placeholder="请选择年级">
            <el-option label="小班" value="小班" />
            <el-option label="中班" value="中班" />
            <el-option label="大班" value="大班" />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showCreateDialog = false">取消</el-button>
        <el-button type="primary" @click="submitClass">确定</el-button>
      </template>
    </el-dialog>

    <el-dialog
      v-model="showStudentsDialog"
      title="学生列表"
      width="800px"
    >
      <div class="students-header">
        <el-button type="primary" @click="showAddStudentDialog = true">
          添加学生
        </el-button>
        <el-button @click="importStudents">批量导入</el-button>
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
        <el-table-column label="家长绑定">
          <template #default="{ row }">
            <el-tag :type="row.parent_bound ? 'success' : 'info'">
              {{ row.parent_bound ? '已绑定' : '未绑定' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作">
          <template #default="{ row }">
            <el-button size="small" @click="editStudent(row)">编辑</el-button>
            <el-button size="small" type="danger" @click="deleteStudent(row)">
              删除
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { supabase } from '@/config/supabase'

const classes = ref([])
const students = ref([])
const showCreateDialog = ref(false)
const showStudentsDialog = ref(false)
const showAddStudentDialog = ref(false)
const editingClass = ref(null)
const currentClass = ref(null)

const classFormRef = ref(null)
const classForm = reactive({
  name: '',
  grade: ''
})

const rules = {
  name: [
    { required: true, message: '请输入班级名称', trigger: 'blur' }
  ],
  grade: [
    { required: true, message: '请选择年级', trigger: 'change' }
  ]
}

onMounted(async () => {
  await loadClasses()
})

async function loadClasses() {
  try {
    const teacherId = userStore.user?.id

    const { data, error } = await supabase
      .from('classes')
      .select('*, students(count)')
      .eq('teacher_id', teacherId)
      .order('created_at', { ascending: false })

    if (error) throw error

    classes.value = data.map(item => ({
      ...item,
      student_count: item.students?.[0]?.count || 0
    }))
  } catch (error) {
    console.error('加载班级列表失败:', error)
    ElMessage.error('加载班级列表失败')
  }
}

async function loadStudents(classId) {
  try {
    const { data, error } = await supabase
      .from('students')
      .select('*, parent_student(parent_id)')
      .eq('class_id', classId)
      .order('created_at', { ascending: false })

    if (error) throw error

    students.value = data.map(item => ({
      ...item,
      parent_bound: item.parent_student?.length > 0
    }))
  } catch (error) {
    console.error('加载学生列表失败:', error)
    ElMessage.error('加载学生列表失败')
  }
}

async function submitClass() {
  const valid = await classFormRef.value.validate()
  if (!valid) return

  try {
    const teacherId = userStore.user?.id

    if (editingClass.value) {
      const { error } = await supabase
        .from('classes')
        .update({
          name: classForm.name,
          grade: classForm.grade
        })
        .eq('id', editingClass.value.id)

      if (error) throw error

      ElMessage.success('更新成功')
    } else {
      const inviteCode = generateInviteCode()

      const { error } = await supabase
        .from('classes')
        .insert({
          teacher_id: teacherId,
          name: classForm.name,
          grade: classForm.grade,
          invite_code: inviteCode
        })

      if (error) throw error

      ElMessage.success('创建成功')
    }

    showCreateDialog.value = false
    await loadClasses()
  } catch (error) {
    console.error('操作失败:', error)
    ElMessage.error('操作失败，请重试')
  }
}

function editClass(row) {
  editingClass.value = row
  classForm.name = row.name
  classForm.grade = row.grade
  showCreateDialog.value = true
}

async function deleteClass(row) {
  try {
    await ElMessageBox.confirm(
      `确定要删除班级"${row.name}"吗？此操作不可恢复。`,
      '确认删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const { error } = await supabase
      .from('classes')
      .delete()
      .eq('id', row.id)

    if (error) throw error

    ElMessage.success('删除成功')
    await loadClasses()
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除失败:', error)
      ElMessage.error('删除失败，请重试')
    }
  }
}

function viewStudents(row) {
  currentClass.value = row
  loadStudents(row.id)
  showStudentsDialog.value = true
}

function generateInviteCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
  let code = ''
  for (let i = 0; i < 6; i++) {
    code += chars.charAt(Math.floor(Math.random() * chars.length))
  }
  return code
}

function importStudents() {
  ElMessage.info('批量导入功能开发中...')
}

function editStudent(row) {
  ElMessage.info('编辑学生功能开发中...')
}

async function deleteStudent(row) {
  try {
    await ElMessageBox.confirm(
      `确定要删除学生"${row.name}"吗？`,
      '确认删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )

    const { error } = await supabase
      .from('students')
      .delete()
      .eq('id', row.id)

    if (error) throw error

    ElMessage.success('删除成功')
    await loadStudents(currentClass.value.id)
  } catch (error) {
    if (error !== 'cancel') {
      console.error('删除失败:', error)
      ElMessage.error('删除失败，请重试')
    }
  }
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
.classes-container {
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

.students-header {
  display: flex;
  gap: 12px;
  margin-bottom: 16px;
}
</style>
