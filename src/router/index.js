import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    redirect: '/student'
  },
  {
    path: '/student',
    name: 'StudentLayout',
    component: () => import('@/views/student/StudentLayout.vue'),
    children: [
      {
        path: '',
        name: 'StudentHome',
        component: () => import('@/views/student/Home.vue')
      },
      {
        path: 'login',
        name: 'StudentLogin',
        component: () => import('@/views/student/Login.vue')
      },
      {
        path: 'practice/:id',
        name: 'StudentPractice',
        component: () => import('@/views/student/Practice.vue')
      },
      {
        path: 'result/:id',
        name: 'StudentResult',
        component: () => import('@/views/student/Result.vue')
      },
      {
        path: 'report',
        name: 'StudentReport',
        component: () => import('@/views/student/Report.vue')
      },
      {
        path: 'profile',
        name: 'StudentProfile',
        component: () => import('@/views/student/Profile.vue')
      }
    ]
  },
  {
    path: '/teacher',
    name: 'TeacherLayout',
    component: () => import('@/views/teacher/TeacherLayout.vue'),
    children: [
      {
        path: '',
        name: 'TeacherDashboard',
        component: () => import('@/views/teacher/Dashboard.vue')
      },
      {
        path: 'login',
        name: 'TeacherLogin',
        component: () => import('@/views/teacher/Login.vue')
      },
      {
        path: 'classes',
        name: 'TeacherClasses',
        component: () => import('@/views/teacher/Classes.vue')
      },
      {
        path: 'questions',
        name: 'TeacherQuestions',
        component: () => import('@/views/teacher/Questions.vue')
      },
      {
        path: 'assignments',
        name: 'TeacherAssignments',
        component: () => import('@/views/teacher/Assignments.vue')
      },
      {
        path: 'assignments/create',
        name: 'CreateAssignment',
        component: () => import('@/views/teacher/CreateAssignment.vue')
      },
      {
        path: 'analysis',
        name: 'TeacherAnalysis',
        component: () => import('@/views/teacher/Analysis.vue')
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router
