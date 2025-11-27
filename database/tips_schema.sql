-- =====================================================
-- POWERHOUSE TIPS FEATURE - DATABASE SCHEMA
-- =====================================================
-- This schema creates tables for the tips/educational content feature
-- Run this in your Supabase SQL Editor

-- =====================================================
-- 1. TIP CATEGORIES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS tip_categories (
  category_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(50) UNIQUE NOT NULL,
  display_name VARCHAR(100) NOT NULL,
  icon_name VARCHAR(50),
  color_hex VARCHAR(7),
  description TEXT,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Insert default categories
INSERT INTO tip_categories (name, display_name, icon_name, color_hex, description, sort_order) VALUES
('exercise', 'Exercise Tips', 'fitness_center', '#1DAB87', 'Learn proper form and techniques for exercises', 1),
('nutrition', 'Healthy Meals', 'restaurant', '#F97316', 'Nutrition guides and healthy meal ideas', 2),
('wisdom', 'Daily Wisdom', 'lightbulb', '#FFB800', 'Motivational quotes and mindset tips', 3),
('myth', 'Myth Busting', 'fact_check', '#E11D48', 'Debunking common fitness myths', 4),
('recovery', 'Recovery & Rest', 'spa', '#8B5CF6', 'Rest, sleep, and recovery tips', 5),
('lifestyle', 'Lifestyle', 'self_improvement', '#06B6D4', 'Healthy lifestyle habits and wellness', 6)
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- 2. TIPS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS tips (
  tip_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title VARCHAR(200) NOT NULL,
  category VARCHAR(50) NOT NULL REFERENCES tip_categories(name) ON DELETE CASCADE,
  content TEXT NOT NULL,
  summary VARCHAR(300),
  image_url TEXT,
  video_url TEXT,
  difficulty_level VARCHAR(20) CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
  reading_time INT DEFAULT 3,
  is_featured BOOLEAN DEFAULT FALSE,
  view_count INT DEFAULT 0,
  like_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_tips_category ON tips(category);
CREATE INDEX IF NOT EXISTS idx_tips_featured ON tips(is_featured);
CREATE INDEX IF NOT EXISTS idx_tips_created_at ON tips(created_at DESC);

-- =====================================================
-- 3. USER TIPS PROGRESS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS user_tips_progress (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  tip_id UUID NOT NULL REFERENCES tips(tip_id) ON DELETE CASCADE,
  is_read BOOLEAN DEFAULT FALSE,
  is_liked BOOLEAN DEFAULT FALSE,
  is_bookmarked BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, tip_id)
);

-- Indexes for user queries
CREATE INDEX IF NOT EXISTS idx_user_tips_user ON user_tips_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_tips_bookmarked ON user_tips_progress(user_id, is_bookmarked) WHERE is_bookmarked = TRUE;
CREATE INDEX IF NOT EXISTS idx_user_tips_liked ON user_tips_progress(user_id, is_liked) WHERE is_liked = TRUE;

-- =====================================================
-- 4. SAMPLE TIPS DATA
-- =====================================================
-- Insert some sample tips for testing

INSERT INTO tips (title, category, content, summary, reading_time, is_featured, difficulty_level) VALUES
(
  'Perfect Your Squat Form',
  'exercise',
  E'# Perfect Your Squat Form\n\n## Why Squats Matter\nSquats are one of the most effective exercises for building lower body strength. They work your quads, hamstrings, glutes, and core.\n\n## Proper Form Steps:\n\n1. **Stance**: Stand with feet shoulder-width apart, toes slightly pointed out\n2. **Core**: Engage your core and keep your chest up\n3. **Descent**: Push your hips back and bend your knees, keeping them aligned with your toes\n4. **Depth**: Go down until thighs are parallel to the ground (or lower if mobility allows)\n5. **Ascent**: Drive through your heels to stand back up\n\n## Common Mistakes to Avoid:\n- Knees caving inward\n- Leaning too far forward\n- Not going deep enough\n- Lifting heels off the ground\n\n## Pro Tip:\nPractice with bodyweight first before adding weights!',
  'Master the squat with proper form to build lower body strength safely and effectively.',
  5,
  TRUE,
  'beginner'
),
(
  'Protein: How Much Do You Really Need?',
  'nutrition',
  E'# Protein: How Much Do You Really Need?\n\n## The Protein Myth\nMany people think you need massive amounts of protein to build muscle. The truth is more nuanced.\n\n## General Guidelines:\n\n- **Sedentary adults**: 0.8g per kg of body weight\n- **Active individuals**: 1.2-1.6g per kg\n- **Athletes/Bodybuilders**: 1.6-2.2g per kg\n- **Weight loss**: Higher protein (1.6-2.4g per kg) helps preserve muscle\n\n## Best Protein Sources:\n\n### Animal-Based:\n- Chicken breast (31g per 100g)\n- Eggs (13g per 2 eggs)\n- Greek yogurt (10g per 100g)\n- Salmon (25g per 100g)\n\n### Plant-Based:\n- Lentils (9g per 100g cooked)\n- Chickpeas (8g per 100g)\n- Tofu (8g per 100g)\n- Quinoa (4g per 100g)\n\n## Timing Matters:\nSpread protein intake throughout the day for optimal muscle protein synthesis!',
  'Learn how much protein you actually need based on your fitness goals and activity level.',
  4,
  TRUE,
  'beginner'
),
(
  'The Truth About Spot Reduction',
  'myth',
  E'# The Truth About Spot Reduction\n\n## The Myth:\n"If I do 1000 crunches, I''ll get a six-pack and lose belly fat!"\n\n## The Reality:\n**Spot reduction is a myth.** You cannot target fat loss in specific areas through exercise.\n\n## Why It Doesn''t Work:\n\n1. **Fat Loss is Systemic**: When you lose fat, your body decides where it comes from based on genetics\n2. **Exercise Burns Calories**: Crunches burn calories, but not specifically belly fat\n3. **Muscle ≠ Fat**: Building abs doesn''t burn the fat covering them\n\n## What Actually Works:\n\n✅ **Overall calorie deficit** through diet and exercise\n✅ **Full-body strength training** to build muscle\n✅ **Cardio** for additional calorie burn\n✅ **Patience** - fat loss takes time\n✅ **Consistency** - sustainable habits win\n\n## The Truth About Abs:\nAbs are made in the kitchen! You need to reduce overall body fat percentage to see them.\n\n## Bottom Line:\nTrain all muscle groups, maintain a calorie deficit, and be patient. The fat will come off where your genetics determine!',
  'Debunking the myth of spot reduction - why you can''t target fat loss in specific areas.',
  3,
  FALSE,
  'beginner'
),
(
  'Sleep: Your Secret Weapon for Gains',
  'recovery',
  E'# Sleep: Your Secret Weapon for Gains\n\n## Why Sleep Matters\n\nSleep is when your body repairs and builds muscle. Skimp on sleep, and you''re sabotaging your progress.\n\n## What Happens During Sleep:\n\n- **Growth hormone release**: Peaks during deep sleep\n- **Muscle repair**: Damaged muscle fibers rebuild stronger\n- **Glycogen restoration**: Energy stores replenish\n- **Mental recovery**: Nervous system resets\n\n## Optimal Sleep for Athletes:\n\n- **Duration**: 7-9 hours per night\n- **Consistency**: Same bedtime/wake time daily\n- **Quality**: Deep, uninterrupted sleep\n\n## Sleep Optimization Tips:\n\n### Before Bed:\n1. No screens 1 hour before sleep\n2. Keep room cool (60-67°F / 15-19°C)\n3. Complete darkness or eye mask\n4. Avoid caffeine after 2 PM\n5. Light dinner 2-3 hours before bed\n\n### Sleep Hygiene:\n- Consistent schedule (even weekends)\n- Relaxing bedtime routine\n- Comfortable mattress and pillows\n- White noise if needed\n\n## Signs You''re Not Getting Enough:\n- Decreased performance\n- Increased hunger/cravings\n- Slower recovery\n- Mood changes\n- Reduced motivation\n\n## Remember:\nYou don''t grow in the gym - you grow when you rest!',
  'Discover why sleep is crucial for muscle growth, recovery, and overall fitness progress.',
  6,
  FALSE,
  'beginner'
),
(
  'Hydration: The Overlooked Performance Booster',
  'lifestyle',
  E'# Hydration: The Overlooked Performance Booster\n\n## Why Hydration Matters\n\nEven 2% dehydration can significantly impact your performance, strength, and endurance.\n\n## Benefits of Proper Hydration:\n\n✅ Better workout performance\n✅ Improved recovery\n✅ Enhanced nutrient delivery\n✅ Better temperature regulation\n✅ Reduced fatigue\n✅ Clearer thinking\n\n## How Much Water Do You Need?\n\n**General Formula**: Body weight (kg) × 0.033 = Liters per day\n\n**Example**: 70kg person = 2.3 liters (about 8-10 glasses)\n\n**Add more if:**\n- Exercising (add 0.5-1L per hour of exercise)\n- Hot weather\n- High altitude\n- Pregnant/breastfeeding\n\n## Hydration Tips:\n\n### Before Exercise:\n- Drink 500ml 2 hours before\n- Drink 250ml 15 minutes before\n\n### During Exercise:\n- 200-300ml every 15-20 minutes\n- For workouts over 60 min, consider electrolytes\n\n### After Exercise:\n- Drink 1.5L for every kg lost during workout\n\n## Signs of Dehydration:\n\n🚨 Dark yellow urine\n🚨 Dry mouth\n🚨 Headache\n🚨 Dizziness\n🚨 Fatigue\n🚨 Decreased performance\n\n## Pro Tips:\n\n1. **Start your day with water**: Drink a glass upon waking\n2. **Carry a water bottle**: Make it visible and accessible\n3. **Set reminders**: Use your phone if needed\n4. **Eat water-rich foods**: Watermelon, cucumber, oranges\n5. **Monitor urine color**: Aim for pale yellow\n\n## Remember:\nBy the time you feel thirsty, you''re already dehydrated!',
  'Learn how proper hydration can boost your performance and why it''s crucial for fitness.',
  5,
  TRUE,
  'beginner'
),
(
  'Motivation vs Discipline: What You Need to Know',
  'wisdom',
  E'# Motivation vs Discipline: What You Need to Know\n\n## The Hard Truth\n\n**Motivation is fleeting. Discipline is forever.**\n\n## Understanding the Difference:\n\n### Motivation:\n- Emotional and temporary\n- Comes and goes\n- Feels exciting\n- Unreliable long-term\n\n### Discipline:\n- Habitual and permanent\n- Always there\n- Feels like routine\n- Reliable foundation\n\n## Why Discipline Wins:\n\n> "We are what we repeatedly do. Excellence, then, is not an act, but a habit." - Aristotle\n\n### The Reality:\n- You won''t always feel motivated\n- Some days you''ll want to skip the gym\n- Some days healthy food won''t appeal to you\n- **Discipline shows up anyway**\n\n## Building Discipline:\n\n### 1. Start Small\n- Don''t overhaul your entire life\n- Pick ONE habit to build\n- Master it before adding more\n\n### 2. Make it Easy\n- Reduce friction\n- Prepare gym clothes the night before\n- Meal prep on Sundays\n- Remove temptations\n\n### 3. Track Progress\n- Use a habit tracker\n- Celebrate small wins\n- Don''t break the chain\n\n### 4. Have a System\n- Same time every day\n- Same routine\n- Remove decisions\n\n### 5. Embrace Discomfort\n- Growth happens outside comfort zone\n- Discipline is doing it when you don''t feel like it\n- That''s where transformation happens\n\n## The 2-Minute Rule:\n\nDon''t feel like working out? Commit to just 2 minutes. Usually, starting is the hardest part.\n\n## Remember:\n\n💪 Motivation gets you started\n💪 Discipline keeps you going\n💪 Results keep you committed\n\n## Your Challenge:\n\nPick ONE habit. Do it every day for 30 days. No excuses. Build that discipline muscle!',
  'Understanding why discipline beats motivation and how to build unshakeable fitness habits.',
  4,
  FALSE,
  'beginner'
);

-- =====================================================
-- 5. ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on tables
ALTER TABLE tips ENABLE ROW LEVEL SECURITY;
ALTER TABLE tip_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_tips_progress ENABLE ROW LEVEL SECURITY;

-- Tips: Everyone can read
CREATE POLICY "Tips are viewable by everyone"
  ON tips FOR SELECT
  USING (true);

-- Tip categories: Everyone can read
CREATE POLICY "Tip categories are viewable by everyone"
  ON tip_categories FOR SELECT
  USING (true);

-- User tips progress: Users can only see their own progress
CREATE POLICY "Users can view their own tip progress"
  ON user_tips_progress FOR SELECT
  USING (auth.uid()::text = user_id::text);

-- User tips progress: Users can insert their own progress
CREATE POLICY "Users can insert their own tip progress"
  ON user_tips_progress FOR INSERT
  WITH CHECK (auth.uid()::text = user_id::text);

-- User tips progress: Users can update their own progress
CREATE POLICY "Users can update their own tip progress"
  ON user_tips_progress FOR UPDATE
  USING (auth.uid()::text = user_id::text);

-- =====================================================
-- 6. FUNCTIONS FOR UPDATING COUNTS
-- =====================================================

-- Function to increment view count
CREATE OR REPLACE FUNCTION increment_tip_view_count(tip_uuid UUID)
RETURNS void AS $$
BEGIN
  UPDATE tips
  SET view_count = view_count + 1,
      updated_at = NOW()
  WHERE tip_id = tip_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to update like count
CREATE OR REPLACE FUNCTION update_tip_like_count(tip_uuid UUID)
RETURNS void AS $$
BEGIN
  UPDATE tips
  SET like_count = (
    SELECT COUNT(*)
    FROM user_tips_progress
    WHERE tip_id = tip_uuid AND is_liked = TRUE
  ),
  updated_at = NOW()
  WHERE tip_id = tip_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- SETUP COMPLETE!
-- =====================================================
-- You can now use the tips feature in your app
