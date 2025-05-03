/* 1. List each course title and the number of students enrolled in it. Include courses even if they have no enrollments */
SELECT 
    courses.id, 
    courses.title AS course, 
    COUNT(enrollments.student_id) AS count_students 
FROM courses
LEFT JOIN enrollments ON courses.id = enrollments.course_id 
GROUP BY courses.id, courses.title;

/* 2. Show each instructor’s name and the total number of courses they teach. */
SELECT u.name AS instructor_name, COUNT(c.id) AS count_courses
FROM instructors AS i
JOIN users AS u ON i.user_id = u.id
JOIN courses AS c ON i.id = c.instructor_id
GROUP BY u.id, u.name;

/* 3. Find all students who are enrolled in more than one course. Show their name and total enrolled courses. */
SELECT u.name AS student_name, COUNT(e.course_id) AS total_enrolled_courses 
FROM students s
JOIN users AS u ON s.user_id = u.id
JOIN enrollments e ON s.id = e.student_id
GROUP BY u.id, u.name
HAVING COUNT(e.course_id) > 1;

/* 4.  List each course with the average rating it received in reviews. Include courses with no reviews (show NULL rating). */
SELECT c.id, c.title AS course, ROUND(AVG(r.rating), 0) AS average_rating 
FROM courses c
LEFT JOIN reviews r ON c.id = r.course_id
GROUP BY c.id, c.title

/* 5. List all students along with their total payment amount. Include students who haven’t made any payments (show 0). */
SELECT u.id, u.name AS student, COALESCE(SUM(p.amount), 0) AS total_payment 
FROM students s
JOIN users u ON s.user_id = u.id
LEFT JOIN payments p ON s.id = p.student_id
GROUP BY u.id
ORDER BY u.id;

/* 6. Find courses that have more than 2 lessons. Show course title and number of lessons. */
SELECT c.title AS course, count(l.id) AS total_lesson 
FROM courses c
JOIN lessons l ON c.id = l.course_id
GROUP BY c.title
HAVING count(l.course_id) > 30
ORDER BY total_lesson

/* 7. Find the course(s) with the highest number of enrolled students. */
SELECT c.title, cc.student_count
FROM (
    SELECT course_id, COUNT(student_id) AS student_count
    FROM enrollments
    GROUP BY course_id
) AS cc
JOIN courses c ON cc.course_id = c.id
WHERE cc.student_count = (
    SELECT MAX(student_count)
    FROM (
        SELECT course_id, COUNT(student_id) AS student_count
        FROM enrollments
        GROUP BY course_id
    ) AS inner_counts
);

/* 8. Show students who submitted at least one assignment, including student name and total submissions. */
SELECT u.name, sa.total_assignment FROM 
(
    SELECT student_id, count(assignment_id) as total_assignment 
    FROM submissions 
    GROUP BY student_id
) as sa
JOIN users u ON sa.student_id = u.id
ORDER BY total_assignment desc; 

/* 9. List all instructors who have at least one course with no assignments. */
SELECT DISTINCT u.name AS instructor_name
FROM courses c
LEFT JOIN assignments a ON c.id = a.course_id
JOIN users u ON c.instructor_id = u.id
WHERE a.id IS NULL;

/* 10. List students who have not submitted any assignments. */
SELECT u.name AS student_name
FROM students s
JOIN users u ON s.user_id = u.id
LEFT JOIN submissions sub ON s.id = sub.student_id
WHERE sub.id IS NULL;
