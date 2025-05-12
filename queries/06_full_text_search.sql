--------------------------------------------------------------------------------
-- Search Courses by Title and Description
--------------------------------------------------------------------------------
/* Step 1: Add a tsvector column to store searchable data */
ALTER TABLE courses ADD COLUMN search_vector tsvector;

/* Step 2: Populate the search_vector from title and description */
UPDATE courses
SET search_vector = 
  to_tsvector('english', coalesce(title, '') || ' ' || coalesce(description, '')); -- coalesce avoids NULL issues

/* Step 3: Create a GIN index for fast search */
CREATE INDEX idx_courses_search_vector ON courses USING GIN(search_vector);

/* Step 4: Run a full-text search query */
-- Find courses matching "data analysis":
SELECT id, title
FROM courses
WHERE search_vector @@ to_tsquery('english', 'data')
-- @@ is the FTS match operator
-- 'data & analysis' = search for both words

/* Step 5: Order by relevance (optional) */
SELECT id, title, search_vector,
  ts_rank(search_vector, to_tsquery('english', 'data')) AS rank
FROM courses
WHERE search_vector @@ to_tsquery('english', 'data')
ORDER BY rank DESC;

---------------------------------------------------------------------------------------
-- Automating the update of search_vector via a trigger function
---------------------------------------------------------------------------------------
/* Automatically update the search_vector column on every INSERT or UPDATE to the courses table (based on title and description). */

-- Step 1: Create the trigger function
-- Drop previous triggers and functions safely
DROP TRIGGER IF EXISTS trigger_update_search_vector ON courses;
DROP FUNCTION IF EXISTS update_course_search_vector();

CREATE OR REPLACE FUNCTION update_course_search_vector()
RETURNS trigger AS $$
BEGIN
  NEW.search_vector :=
    to_tsvector('english', 
      coalesce(NEW.title, '') || ' ' || coalesce(NEW.description, '')
    );
  RETURN NEW;
END
$$ LANGUAGE plpgsql;

-- Step 2: Attach the trigger to the courses table
CREATE TRIGGER trigger_update_search_vector
BEFORE INSERT OR UPDATE ON courses
FOR EACH ROW
EXECUTE FUNCTION update_course_search_vector();

------------------------------------------------------
-- TEST TRIGGERS
------------------------------------------------------
-- Insert and Update courses
INSERT INTO courses 
    (category_id, instructor_id, title, description, price)
VALUES 
    (2, 1, 'Advanced PostgreSQL', 'Learn full-text search and indexing in depth', 99.00);

UPDATE courses SET description = 'Updated to include JSONB and triggers' WHERE id = 1;

-- Find courses matching "data analysis":
SELECT id, title, search_vector
FROM courses
WHERE search_vector @@ to_tsquery('english', 'course');

------------------------------------------------------------------------------
-- Reseed courses.id Sequence
-- To avoid duplicate key errors in the future
------------------------------------------------------------------------------
SELECT setval(pg_get_serial_sequence('courses', 'id'), COALESCE(MAX(id), 1), true) FROM courses;