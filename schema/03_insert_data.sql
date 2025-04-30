-- Generate Users
COPY users
FROM 'C:\wamp64\www\learning\e-learnDB\csv_files\users.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

-- Generate Instructors
INSERT INTO instructors (user_id, bio, expertise_area)
SELECT 
    id,
    'Professional with ' || (RANDOM() * 20 + 1)::INT || ' years of experience in ' || 
    CASE (RANDOM() * 5)::INT
        WHEN 0 THEN 'Computer Science'
        WHEN 1 THEN 'Data Science'
        WHEN 2 THEN 'Business'
        WHEN 3 THEN 'Mathematics'
        WHEN 4 THEN 'Design'
        ELSE 'Education'
    END AS bio,
    CASE (RANDOM() * 5)::INT
        WHEN 0 THEN 'Programming'
        WHEN 1 THEN 'Data Analysis'
        WHEN 2 THEN 'Management'
        WHEN 3 THEN 'Statistics'
        WHEN 4 THEN 'UX/UI'
        ELSE 'Pedagogy'
    END AS expertise_area
FROM users
WHERE role = 'instructor';

SELECT * FROM instructors;
-- Generate Students
INSERT INTO students (user_id, date_of_birth)
SELECT 
    id,
    CURRENT_DATE - ((RANDOM() * 10000 + 6570) * INTERVAL '1 day') AS date_of_birth  -- Ages around 18-45
FROM users
WHERE role = 'student';

-- Generate Course Categories
INSERT INTO course_categories (name, description)
VALUES 
    ('Computer Science', 'Courses related to programming, algorithms, and software development'),
    ('Data Science', 'Courses on data analysis, machine learning, and statistics'),
    ('Business', 'Courses on management, marketing, and entrepreneurship'),
    ('Design', 'Courses on graphic design, UX/UI, and creative arts'),
    ('Mathematics', 'Courses on various math disciplines and applications'),
    ('Language', 'Courses for learning different languages and communication skills'),
    ('Health & Fitness', 'Courses on personal health, nutrition, and fitness'),
    ('Personal Development', 'Courses for improving personal and professional skills');

-- Generate Courses
INSERT INTO courses (category_id, instructor_id, title, description, price, created_at)
SELECT 
    (RANDOM() * 7 + 1)::INT AS category_id,
    i.id AS instructor_id,
    'Course ' || s.i || ': ' || 
    CASE (RANDOM() * 5)::INT
        WHEN 0 THEN 'Introduction to '
        WHEN 1 THEN 'Advanced '
        WHEN 2 THEN 'Mastering '
        WHEN 3 THEN 'Fundamentals of '
        WHEN 4 THEN 'Professional '
        ELSE 'Complete '
    END || 
    CASE (RANDOM() * 5)::INT
        WHEN 0 THEN 'Programming'
        WHEN 1 THEN 'Data Analysis'
        WHEN 2 THEN 'Business Strategy'
        WHEN 3 THEN 'Design Principles'
        WHEN 4 THEN 'Mathematics'
        ELSE 'Personal Growth'
    END AS title,
    'This course covers all aspects of the subject with practical examples and projects.' AS description,
    (RANDOM() * 150 + 9.99)::NUMERIC(10,2) AS price,
    CURRENT_TIMESTAMP - (RANDOM() * INTERVAL '730 days') AS created_at
FROM instructors i
CROSS JOIN generate_series(1, 5) AS s(i)
ORDER BY RANDOM()
LIMIT 200;

-- Generate Lessons
INSERT INTO lessons (course_id, title, content, lesson_order)
SELECT 
    c.id AS course_id,
    'Lesson ' || s.lesson_num || ': ' || 
    CASE (RANDOM() * 4)::INT
        WHEN 0 THEN 'Understanding '
        WHEN 1 THEN 'Exploring '
        WHEN 2 THEN 'Building '
        WHEN 3 THEN 'Analyzing '
        ELSE 'Practicing '
    END || 
    'Topic ' || s.lesson_num AS title,
    'This lesson covers important concepts and includes examples and exercises.' AS content,
    s.lesson_num AS lesson_order
FROM courses c
CROSS JOIN (SELECT generate_series(1, 10) AS lesson_num) s;

-- Generate Enrollments
INSERT INTO enrollments (student_id, course_id, enrollment_date)
SELECT 
    s.id AS student_id,
    c.id AS course_id,
    CURRENT_DATE - (RANDOM() * INTERVAL '180 days') AS enrollment_date
FROM students s
CROSS JOIN courses c
WHERE RANDOM() < 0.05  -- Each student enrolls in roughly 5% of courses
ORDER BY RANDOM()
LIMIT 1000;  -- Total number of enrollments

-- Generate Assignments
INSERT INTO assignments (course_id, title, description, due_date)
SELECT 
    c.id AS course_id,
    'Assignment ' || s.assignment_num || ': ' || 
    CASE (RANDOM() * 3)::INT
        WHEN 0 THEN 'Complete the '
        WHEN 1 THEN 'Submit your '
        WHEN 2 THEN 'Analyze and '
        ELSE 'Research and '
    END || 
    'Project ' || s.assignment_num AS title,
    'Complete this assignment based on lessons covered so far.' AS description,
    CURRENT_DATE + ((RANDOM() * 30)::INT * INTERVAL '1 day') AS due_date
FROM courses c
CROSS JOIN (SELECT generate_series(1, 3) AS assignment_num) s;

-- Generate Submissions (only for past due dates and enrolled students)
INSERT INTO submissions (assignment_id, student_id, file_url, submission_date)
SELECT 
    a.id AS assignment_id,
    e.student_id,
    'https://example.com/files/submission_' || a.id || '_' || e.student_id || '.pdf' AS file_url,
    a.due_date - ((RANDOM() * 3)::INT * INTERVAL '1 day') AS submission_date
FROM assignments a
JOIN enrollments e ON a.course_id = e.course_id
WHERE a.due_date < CURRENT_DATE
AND RANDOM() < 0.7  -- 70% of students submit their assignments
LIMIT 800;

-- Generate Reviews
INSERT INTO reviews (student_id, course_id, rating, comment, review_date)
SELECT 
    e.student_id,
    e.course_id,
    (RANDOM() * 4 + 1)::INT AS rating,  -- Ratings from 1 to 5
    CASE (RANDOM() * 4)::INT
        WHEN 0 THEN 'Great course! I learned a lot.'
        WHEN 1 THEN 'Very informative content and engaging instructor.'
        WHEN 2 THEN 'Good course overall. Some sections could be improved.'
        WHEN 3 THEN 'Decent material but could use more examples.'
        ELSE 'Excellent course, highly recommended!'
    END AS comment,
    e.enrollment_date + ((RANDOM() * 60)::INT * INTERVAL '1 day') AS review_date
FROM enrollments e
WHERE RANDOM() < 0.6  -- 60% of enrolled students leave reviews
LIMIT 600;

-- Generate Payments
INSERT INTO payments (student_id, course_id, amount, payment_date)
SELECT 
    e.student_id,
    e.course_id,
    c.price AS amount,
    e.enrollment_date AS payment_date
FROM enrollments e
JOIN courses c ON e.course_id = c.id;

-- Generate Certificates (only for completed courses)
INSERT INTO certificates (enrollment_id, certificate_url, issued_date)
SELECT 
    e.id AS enrollment_id,
    'https://example.com/certificates/cert_' || e.id || '.pdf' AS certificate_url,
    e.enrollment_date + ((RANDOM() * 90)::INT * INTERVAL '1 day') AS issued_date
FROM enrollments e
WHERE RANDOM() < 0.4  -- 40% of enrollments complete the course and get certificates
LIMIT 400;