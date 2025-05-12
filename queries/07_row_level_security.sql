------------------------------------------------------------------------------------------
-- Add RLS(Row-Level Security) to courses Table
------------------------------------------------------------------------------------------
-- Each instructor can only see the courses they created
/* Step 1: Enable RLS on the courses table */
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;

/* Step 2: Create a sample role (in a real app, you'd map this to a logged-in user) */
CREATE ROLE instructor_cristian;

/* Step 3: Grant access */
GRANT SELECT ON courses TO instructor_cristian;

/* Step 4: Add a policy: "can only see their own courses" */
-- Drop the existing policy if it exists
DROP POLICY IF EXISTS instructor_own_courses_policy ON courses;

-- Then create the new policy
CREATE POLICY instructor_own_courses_policy
ON courses
FOR SELECT
TO instructor_cristian
USING (instructor_id = current_setting('app.current_instructor_id', false)::int);

-- View all policies on the courses table
SELECT * FROM pg_policies WHERE tablename = 'courses';

/* Step 5: Try it out */
-- Set the context variable for which instructor we're impersonating
SET app.current_instructor_id = '1';

-- Switch to the instructor role to apply RLS
SET ROLE instructor_cristian;

-- Should return only courses where instructor_id = 1
SELECT * FROM courses ORDER BY instructor_id ASC;

-- Reset back to your original role
RESET ROLE;