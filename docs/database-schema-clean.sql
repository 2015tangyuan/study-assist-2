-- 幼儿园英语学习助手 - 数据库设计

-- 教师表
CREATE TABLE teachers (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  name VARCHAR(50) NOT NULL,
  avatar TEXT,
  school_id UUID,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 班级表（需要先创建，因为学生表会引用它）
CREATE TABLE classes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id UUID REFERENCES teachers(id),
  name VARCHAR(50) NOT NULL,
  grade VARCHAR(20),
  invite_code VARCHAR(20) UNIQUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 学生表
CREATE TABLE students (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  name VARCHAR(50) NOT NULL,
  avatar TEXT,
  class_id UUID REFERENCES classes(id),
  level INTEGER DEFAULT 1,
  experience INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 家长表
CREATE TABLE parents (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  name VARCHAR(50),
  created_at TIMESTAMP DEFAULT NOW()
);

-- 家长学生关联表
CREATE TABLE parent_student (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id UUID REFERENCES parents(id),
  student_id UUID REFERENCES students(id),
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(parent_id, student_id)
);

-- 题目表
CREATE TABLE questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  word VARCHAR(50) NOT NULL,
  audio_url TEXT NOT NULL,
  options JSONB NOT NULL,
  correct_answer INTEGER NOT NULL,
  category VARCHAR(50),
  difficulty VARCHAR(20),
  status VARCHAR(20) DEFAULT 'pending',
  created_by UUID REFERENCES teachers(id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 作业表
CREATE TABLE assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id UUID REFERENCES teachers(id),
  class_id UUID REFERENCES classes(id),
  title VARCHAR(100) NOT NULL,
  description TEXT,
  question_count INTEGER DEFAULT 0,
  estimated_time INTEGER,
  publish_date DATE NOT NULL,
  deadline DATE,
  status VARCHAR(20) DEFAULT 'draft',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 作业题目关联表
CREATE TABLE assignment_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id UUID REFERENCES assignments(id),
  question_id UUID REFERENCES questions(id),
  order_num INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(assignment_id, question_id)
);

-- 作业结果表
CREATE TABLE assignment_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id UUID REFERENCES assignments(id),
  student_id UUID REFERENCES students(id),
  score INTEGER NOT NULL,
  correct_count INTEGER NOT NULL,
  total_count INTEGER NOT NULL,
  answers JSONB,
  time_spent INTEGER,
  comment TEXT,
  completed_at TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);

-- 学生统计表
CREATE TABLE student_stats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES students(id),
  total_assignments INTEGER DEFAULT 0,
  total_questions INTEGER DEFAULT 0,
  accuracy INTEGER DEFAULT 0,
  continuous_days INTEGER DEFAULT 0,
  last_study_date DATE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(student_id)
);

-- 成就表
CREATE TABLE badges (
  id INTEGER PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  icon VARCHAR(10) NOT NULL,
  description TEXT,
  condition JSONB NOT NULL
);

-- 学生成就表
CREATE TABLE student_badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES students(id),
  badge_id INTEGER REFERENCES badges(id),
  unlocked_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(student_id, badge_id)
);

-- 待办事项表
CREATE TABLE todos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id UUID REFERENCES teachers(id),
  type VARCHAR(20) NOT NULL,
  title VARCHAR(200) NOT NULL,
  description TEXT,
  link TEXT,
  urgent BOOLEAN DEFAULT false,
  completed BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- 索引设计
-- students表索引
CREATE INDEX idx_students_class_id ON students(class_id);
CREATE INDEX idx_students_user_id ON students(user_id);

-- assignments表索引
CREATE INDEX idx_assignments_teacher_id ON assignments(teacher_id);
CREATE INDEX idx_assignments_class_id ON assignments(class_id);
CREATE INDEX idx_assignments_publish_date ON assignments(publish_date);

-- assignment_results表索引
CREATE INDEX idx_results_assignment_id ON assignment_results(assignment_id);
CREATE INDEX idx_results_student_id ON assignment_results(student_id);
CREATE INDEX idx_results_completed_at ON assignment_results(completed_at);

-- questions表索引
CREATE INDEX idx_questions_category ON questions(category);
CREATE INDEX idx_questions_status ON questions(status);

-- Row Level Security (RLS) 策略
-- 启用RLS
ALTER TABLE teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignment_results ENABLE ROW LEVEL SECURITY;

-- 教师只能访问自己的数据
CREATE POLICY "Teachers can view own data" ON teachers
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Teachers can update own data" ON teachers
  FOR UPDATE USING (auth.uid() = id);

-- 学生只能访问自己的数据
CREATE POLICY "Students can view own data" ON students
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Students can update own data" ON students
  FOR UPDATE USING (auth.uid() = user_id);

-- 教师可以访问自己班级的学生
CREATE POLICY "Teachers can view class students" ON students
  FOR SELECT USING (
    class_id IN (
      SELECT id FROM classes WHERE teacher_id = auth.uid()
    )
  );

-- 教师可以管理自己的班级
CREATE POLICY "Teachers can manage own classes" ON classes
  FOR ALL USING (teacher_id = auth.uid());

-- 教师可以访问自己创建的题目
CREATE POLICY "Teachers can manage own questions" ON questions
  FOR ALL USING (created_by = auth.uid());

-- 教师可以管理自己的作业
CREATE POLICY "Teachers can manage own assignments" ON assignments
  FOR ALL USING (teacher_id = auth.uid());

-- 学生可以查看自己班级的作业
CREATE POLICY "Students can view class assignments" ON assignments
  FOR SELECT USING (
    class_id IN (
      SELECT class_id FROM students WHERE user_id = auth.uid()
    )
  );

-- 学生只能访问自己的作业结果
CREATE POLICY "Students can view own results" ON assignment_results
  FOR SELECT USING (student_id IN (
    SELECT id FROM students WHERE user_id = auth.uid()
  ));

-- 教师可以查看自己班级学生的作业结果
CREATE POLICY "Teachers can view class results" ON assignment_results
  FOR SELECT USING (
    student_id IN (
      SELECT id FROM students WHERE class_id IN (
        SELECT id FROM classes WHERE teacher_id = auth.uid()
      )
    )
  );

-- 初始化数据
-- 插入默认成就
INSERT INTO badges (id, name, icon, description, condition) VALUES
  (1, '初学者', '🌱', '完成第一次作业', '{"type": "first_assignment"}'),
  (2, '勤奋好学', '📖', '连续学习7天', '{"type": "continuous_days", "days": 7}'),
  (3, '答题达人', '🎯', '累计答题100题', '{"type": "total_questions", "count": 100}'),
  (4, '满分王者', '👑', '获得10次满分', '{"type": "perfect_scores", "count": 10}'),
  (5, '英语小能手', '🌟', '正确率达到90%', '{"type": "accuracy", "rate": 90}'),
  (6, '学习之星', '⭐', '连续学习30天', '{"type": "continuous_days", "days": 30}');
