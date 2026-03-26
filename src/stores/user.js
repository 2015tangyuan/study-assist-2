import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { supabase } from '@/config/supabase'

export const useUserStore = defineStore('user', () => {
  const user = ref(null)
  const student = ref(null)
  const loading = ref(false)

  const isLoggedIn = computed(() => !!user.value)
  const isStudent = computed(() => user.value?.user_metadata?.role === 'student')
  const isTeacher = computed(() => user.value?.user_metadata?.role === 'teacher')

  async function login(phone, code) {
    loading.value = true
    try {
      const { data, error } = await supabase.auth.signInWithOtp({
        phone: phone,
        options: {
          channel: 'sms'
        }
      })
      
      if (error) throw error
      
      return { success: true }
    } catch (error) {
      return { success: false, error: error.message }
    } finally {
      loading.value = false
    }
  }

  async function verifyOtp(phone, token) {
    loading.value = true
    try {
      const { data, error } = await supabase.auth.verifyOtp({
        phone: phone,
        token: token,
        type: 'sms'
      })
      
      if (error) throw error
      
      user.value = data.user
      await loadStudentInfo()
      
      return { success: true }
    } catch (error) {
      return { success: false, error: error.message }
    } finally {
      loading.value = false
    }
  }

  async function loadStudentInfo() {
    if (!user.value) return
    
    try {
      const { data, error } = await supabase
        .from('students')
        .select('*')
        .eq('user_id', user.value.id)
        .single()
      
      if (error) throw error
      
      student.value = data
    } catch (error) {
      console.error('加载学生信息失败:', error)
    }
  }

  async function logout() {
    await supabase.auth.signOut()
    user.value = null
    student.value = null
  }

  return {
    user,
    student,
    loading,
    isLoggedIn,
    isStudent,
    isTeacher,
    login,
    verifyOtp,
    loadStudentInfo,
    logout
  }
})
