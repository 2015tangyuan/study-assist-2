<template>
  <div class="login-container">
    <div class="login-box">
      <div class="logo">
        <h2>英语学习助手</h2>
        <p>教师管理后台</p>
      </div>

      <el-form :model="loginForm" :rules="rules" ref="loginFormRef">
        <el-form-item prop="phone">
          <el-input
            v-model="loginForm.phone"
            placeholder="请输入手机号"
            prefix-icon="User"
            size="large"
          />
        </el-form-item>

        <el-form-item prop="password">
          <el-input
            v-model="loginForm.password"
            type="password"
            placeholder="请输入密码"
            prefix-icon="Lock"
            size="large"
            show-password
          />
        </el-form-item>

        <el-form-item>
          <el-button
            type="primary"
            size="large"
            :loading="loading"
            @click="handleLogin"
            style="width: 100%"
          >
            登录
          </el-button>
        </el-form-item>
      </el-form>

      <div class="footer">
        <p>© 2024 英语学习助手</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'

const router = useRouter()
const userStore = useUserStore()

const loginFormRef = ref(null)
const loading = ref(false)

const loginForm = reactive({
  phone: '',
  password: ''
})

const rules = {
  phone: [
    { required: true, message: '请输入手机号', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码长度不能少于6位', trigger: 'blur' }
  ]
}

async function handleLogin() {
  const valid = await loginFormRef.value.validate()
  if (!valid) return

  loading.value = true
  
  try {
    const { data, error } = await supabase.auth.signInWithPassword({
      email: loginForm.phone + '@example.com',
      password: loginForm.password
    })

    if (error) throw error

    ElMessage.success('登录成功')
    router.push('/teacher')
  } catch (error) {
    ElMessage.error(error.message || '登录失败，请重试')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.login-box {
  background: white;
  border-radius: 12px;
  padding: 40px;
  width: 100%;
  max-width: 400px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
}

.logo {
  text-align: center;
  margin-bottom: 40px;
}

.logo h2 {
  font-size: 24px;
  color: #333;
  margin: 0 0 8px 0;
}

.logo p {
  font-size: 14px;
  color: #999;
  margin: 0;
}

.footer {
  text-align: center;
  margin-top: 20px;
}

.footer p {
  font-size: 12px;
  color: #999;
  margin: 0;
}
</style>
