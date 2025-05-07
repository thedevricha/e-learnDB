/* CTEs (COMMON TABLE EXPRESSIONS) */
/* 1. Show the average payment made by each student, and list only those who paid more than the average of all students. */
WITH student_total_payment AS (
    SELECT 
    student_id,
    SUM(amount) AS total_payment
    FROM payments
    GROUP BY student_id
),
overall_avg_payment AS (
    SELECT 
    ROUND(AVG(total_payment),2) AS avg_payment
    FROM student_total_payment
)
SELECT 
    stp.student_id,
    u.name,
    stp.total_payment,
    oap.avg_payment
FROM student_total_payment stp
JOIN overall_avg_payment oap ON true
JOIN students s ON stp.student_id = s.id
JOIN users u ON s.user_id = u.id
WHERE stp.total_payment > oap.avg_payment
ORDER BY stp.total_payment DESC;

/* 2. Find all students who enrolled in courses but never submitted any assignments. */
-- Step 1: Get all students who enrolled in at least one course
WITH enrolled_students AS (
    SELECT 
        DISTINCT student_id
    FROM enrollments
),
-- Step 2: Get all students who submitted at least one assignment
students_who_submitted AS (
    SELECT 
        DISTINCT student_id
    FROM submissions
)
-- Step 3: Select enrolled students who never submitted any assignment
SELECT u.name AS student_name
FROM enrolled_students e
LEFT JOIN students_who_submitted s ON e.student_id = s.student_id
JOIN students st ON e.student_id = st.id
JOIN users u ON st.user_id = u.id
WHERE s.student_id IS NULL
ORDER BY u.name;

/* 3. List all courses that have more than 2 lessons but no assignments. Show the course title and number of lessons. */
-- Step 1: Get all courses that have more than 2 lessons
WITH courses_with_lessons AS (
    SELECT 
        course_id,
        COUNT(id) AS total_lesson
    FROM lessons
    GROUP BY course_id
    HAVING COUNT(id) > 2
),
-- Step 2: Get all course IDs that have at least one assignment.
courses_with_assignments AS (
    SELECT 
        course_id
    FROM assignments
    GROUP BY course_id
    HAVING COUNT(id) >= 1
)
-- Step 3: Now select courses from the first CTE that are not in the second CTE.
SELECT 
    cl.course_id,
    c.title,
    cl.total_lesson
FROM courses_with_lessons cl
LEFT JOIN courses_with_assignments ca 
ON cl.course_id = ca.course_id
JOIN courses c 
ON cl.course_id = c.id
WHERE ca.course_id IS NULL
ORDER BY cl.total_lesson DESC

/* 4. Find the instructors whose average course rating is higher than the average rating of all courses in the platform. */
-- Step 1: Get average rating per course
WITH course_avg_rating AS (
    SELECT 
        course_id,
        ROUND(AVG(rating),2) AS avg_rating
    FROM reviews
    GROUP BY course_id
)
-- Step 2: Calculate overall platform-wide average rating
, platform_avg_rating AS (
    SELECT 
        ROUND(AVG(avg_rating),2) AS platform_avg
    FROM course_avg_rating
)

/* WINDOW FUNCTIONS */
/* 1. List each student with their total payments and rank them from highest to lowest payer. */
WITH student_totals AS (
    SELECT 
        s.id AS student_id,
        u.name AS student_name,
        COALESCE(SUM(p.amount), 0) AS total_payments
    FROM students s
    JOIN users u ON s.user_id = u.id
    LEFT JOIN payments p ON s.id = p.student_id
    GROUP BY s.id, u.name
)
SELECT *,
    RANK() OVER(ORDER BY total_payments DESC) AS rank_high_to_low
FROM student_totals;

/* 2. List lessons with a row number within each course to show lesson order. */
SELECT 
    c.title AS course,
    l.title AS lesson,
    RANK() OVER(PARTITION BY l.course_id ORDER BY l.lesson_order) AS lesson_order
FROM lessons l
JOIN courses c
ON l.course_id = c.id

/* 3.  For each student, find their most recent assignment submission. */
WITH submission_stats AS (
    SELECT 
        s.student_id,
        s.submission_date,
        s.assignment_id,
        ROW_NUMBER() OVER(PARTITION BY s.student_id ORDER BY s.submission_date DESC) AS rn
    FROM submissions s
)
SELECT 
    u.name AS student_name,
    a.title AS assignment_title,
    ss.submission_date
FROM submission_stats ss
JOIN students st ON ss.student_id = st.id
JOIN users u ON st.user_id = u.id
JOIN assignments a ON ss.assignment_id = a.id
WHERE ss.rn = 1;

/* 4. List each course review, and also show the course’s average rating next to each review */
SELECT 
    c.id AS course_id,
    c.title AS course,
    r.student_id,
    r.rating,
    ROUND(AVG(r.rating) OVER(PARTITION BY course_id), 2) AS avg_ratings
FROM reviews r
JOIN courses c
ON r.course_id = c.id
ORDER BY avg_ratings DESC

/* 5. For Each Instructor, Show Their Courses and How Popular Each Course Is Compared to Their Others */
WITH student_enrolled AS (
    SELECT 
        e.course_id,
        COUNT(e.student_id) AS total_students
    FROM enrollments e
    GROUP BY e.course_id
)
SELECT 
    c.id AS course_id,
    c.title AS course_title,
    u.name AS instructor,
    COALESCE(se.total_students, 0) AS total_students,
    RANK() OVER(PARTITION BY c.instructor_id ORDER BY COALESCE(se.total_students, 0) DESC) AS rank
FROM courses c
LEFT JOIN student_enrolled se ON c.id = se.course_id
JOIN users u ON c.instructor_id = u.id
ORDER BY u.name, rank;
