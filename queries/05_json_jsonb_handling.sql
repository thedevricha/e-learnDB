------------------------------------------------------------------------------------
-- ADD & USE preferences IN users TABLE
------------------------------------------------------------------------------------
-- Step 1: Add JSONB column
ALTER TABLE users ADD COLUMN preferences JSONB;

-- Step 2: Insert JSONB data for a user
UPDATE users
SET preferences = '{
  "theme": "dark",
  "language": "en",
  "notifications": {
    "email": true,
    "sms": false
  }
}'::jsonb
WHERE id = 1;

-- Step 3: Query JSONB — simple filter
/* Get users who enabled email notifications: */
/*  
    ->> gets the value as text
    -> gets the value as JSON object
*/
SELECT id, name
FROM users
WHERE preferences ->> 'theme' = 'dark';

-- Step 4: Query nested JSONB values
/* Get users who use dark theme */
SELECT id, name
FROM users
WHERE preferences -> 'notifications' ->> 'email' = 'true';

------------------------------------------------------------------------------------
-- ADD & USE metadata IN courses TABLE
------------------------------------------------------------------------------------

-- Step 1: Add a metadata column (type: JSONB)
ALTER TABLE courses ADD COLUMN metadata JSONB;

-- Step 2: Insert JSONB metadata for a few courses
UPDATE courses
SET metadata = '{
  "difficulty": "intermediate",
  "estimated_hours": 10,
  "tags": ["SQL", "PostgreSQL", "Data Analysis"],
  "language": "English",
  "target_audience": "aspiring data analysts"
}'::jsonb
WHERE id = 1;
UPDATE courses
SET metadata = '{
  "difficulty": "beginner",
  "estimated_hours": 6,
  "tags": ["HTML", "CSS", "JS", "SQL"],
  "language": "English, Hindi",
  "target_audience": "aspiring web developer"
}'::jsonb
WHERE id = 2;
UPDATE courses
SET metadata = '{
  "difficulty": "advance",
  "estimated_hours": 6,
  "tags": ["React", "Tailwind", "PostgreSQL"],
  "language": "English, Hindi",
  "target_audience": "aspiring web developer"
}'::jsonb
WHERE id = 3;
-- Step 3: Querying metadata
-- Get courses where language is "English"
SELECT title, metadata
FROM courses
WHERE metadata ->> 'language' = 'English'

-- Get courses tagged with "SQL"
SELECT title, metadata
FROM courses
WHERE metadata -> 'tags' ? 'SQL' -- The ? operator checks if an array contains a string value (only works with JSONB).

-- Get courses where difficulty = 'beginner'
SELECT title, metadata
FROM courses
WHERE metadata ->> 'difficulty' = 'beginner'

-- List all course titles that include the tag "SQL".
SELECT title, metadata
FROM courses
WHERE metadata -> 'tags' ? 'SQL'

-- Find all courses targeted at "web developer".
SELECT title, metadata
FROM courses
WHERE LOWER(metadata ->> 'target_audience') LIKE '%web developer%'

-- Step 4: Advanced – Indexing for fast querying
-- This enables high-performance JSONB queries, great for large datasets.
CREATE INDEX idx_courses_metadata ON courses USING GIN (metadata);
