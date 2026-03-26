<template>
  <div class="login-container">
    <div class="login-box">
      <div class="logo">
        <div class="logo-icon">🎓</div>
        <h1>英语学习助手</h1>
        <p>幼儿园英语学习好帮手</p>
      </div>

      <van-form @submit="handleSubmit">
        <van-cell-group inset>
          <van-field
            v-model="phone"
            name="phone"
            label="手机号"
            placeholder="请输入手机号"
            :rules="[{ required: true, message: '请输入手机号' }]"
            type="tel"
            maxlength="11"
          />
          <van-field
            v-model="code"
            name="code"
            label="验证码"
            placeholder="请输入验证码"
            :rules="[{ required: true, message: '请输入验证码' }]"
            type="tel"
            maxlength="6"
          >
            <template #button>
              <van-button
                size="small"
                type="primary"
                :disabled="countdown > 0"
                @click="sendCode"
              >
                {{ countdown > 0 ? `${countdown}秒` : '获取验证码' }}
              </van-button>
            </template>
          </van-field>
        </van-cell-group>

        <div class="login-btn">
          <van-button
            round
            block
            type="primary"
            native-type="submit"
            :loading="loading"
            loading-text="登录中..."
          >
            登录
          </van-button>
        </div>

        <div class="guest-mode">
          <van-button
            type="default"
            size="small"
            @click="guestMode"
          >
            游客模式体验
          </van-button>
        </div>
      </van-form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { showToast, showDialog } from 'vant'

const router = useRouter()
const userStore = useUserStore()

const phone = ref('')
const code = ref('')
const loading = ref(false)
const countdown = ref(0)
let timer = null

async function sendCode() {
  if (!phone.value) {
    showToast('请先输入手机号')
    return
  }

  if (!/^1[3-9]\d{9}$/.test(phone.value)) {
    showToast('请输入正确的手机号')
    return
  }

  const result = await userStore.login(phone.value)
  
  if (result.success) {
    showToast('验证码已发送')
    startCountdown()
  } else {
    showToast(result.error || '发送失败，请重试')
  }
}

function startCountdown() {
  countdown.value = 60
  timer = setInterval(() => {
    countdown.value--
    if (countdown.value <= 0) {
      clearInterval(timer)
    }
  }, 1000)
}

async function handleSubmit() {
  loading.value = true
  
  try {
    const result = await userStore.verifyOtp(phone.value, code.value)
    
    if (result.success) {
      showToast('登录成功')
      router.push('/student')
    } else {
      showToast(result.error || '登录失败，请重试')
    }
  } finally {
    loading.value = false
  }
}

function guestMode() {
  showDialog({
    title: '游客模式',
    message: '游客模式下仅可体验练习样题，无法查看个人数据和完成正式作业',
    confirmButtonText: '开始体验',
    confirmButtonColor: '#07c160'
  }).then(() => {
    router.push('/student')
  }).catch(() => {})
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
  border-radius: 20px;
  padding: 40px 30px;
  width: 100%;
  max-width: 400px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
}

.logo {
  text-align: center;
  margin-bottom: 40px;
}

.logo-icon {
  font-size: 64px;
  margin-bottom: 16px;
}

.logo h1 {
  font-size: 28px;
  color: #333;
  margin-bottom: 8px;
}

.logo p {
  font-size: 14px;
  color: #999;
}

.login-btn {
  margin: 30px 16px 20px;
}

.guest-mode {
  text-align: center;
  margin-top: 20px;
}
</style>
