SELECT * FROM users;
SELECT preferences FROM users WHERE id = 1;
SELECT * FROM students;
SELECT * FROM instructors;
SELECT * FROM courses WHERE id =1;  
SELECT * FROM course_categories;
SELECT * FROM lessons;
SELECT * FROM payments;
SELECT * FROM reviews;
SELECT * FROM certificates WHERE enrollment_id=175;
-- DELETE FROM certificates WHERE enrollment_id=175;
SELECT * FROM submissions
WHERE assignment_id IN (39, 65, 71)
AND student_id = 1;
-- DELETE FROM submissions WHERE assignment_id IN (39, 71)
SELECT * FROM assignments WHERE course_id=37
;
SELECT * FROM enrollments WHERE student_id=1;
SELECT * FROM certificate_audit;

/* 1. List all users with their name, email, and role. */
SELECT name, email, role FROM users;

/* 2. Find all students (role = 'student') who were born after January 1, 1997. */
SELECT u.id, u.name, s.date_of_birth 
FROM students s
JOIN users u
ON s.user_id = u.id
WHERE u.role = 'student' AND s.date_of_birth > '1997-01-01';

/* 3. Show the names of all instructors along with their area of expertise. */
SELECT u.id, u.name, i.expertise_area 
FROM instructors i
JOIN users u 
ON i.user_id = u.id
WHERE u.role = 'instructor';         

/* 4. Get the title and price of all courses in the "Web Development" category. */
SELECT c.title, cc.name, c.price 
FROM courses c
JOIN course_categories cc
ON c.category_id = cc.id
WHERE cc.name = 'Web Development';

/* 5. List all lessons for the course "Object-based needs-based leverage Course", ordered by lesson order. */
SELECT c.title, l.content, l.lesson_order 
FROM lessons l
JOIN courses c
ON l.course_id = c.id
WHERE c.title = 'Object-based needs-based leverage Course'
ORDER BY l.lesson_order;

/* 6. How many lessons are there in each course? */
SELECT c.title AS course_name, l.course_id, COUNT(l.id) as lesson_count 
FROM lessons l
JOIN courses c
ON l.course_id = c.id
GROUP BY l.course_id, c.title
ORDER BY lesson_count DESC;

/* 7. Find all students enrolled in the course that include "Multi-channeled" in course title. */
SELECT u.name AS student_name, c.title AS course_name 
FROM enrollments e
JOIN students s
ON e.student_id = s.id
JOIN users u
ON s.user_id = u.id
JOIN courses c
ON e.course_id = c.id
WHERE c.title LIKE '%Multi-channeled%';

/* 8. List the assignments and their due dates for the course title start with "Optimized". */
SELECT c.title AS course, a.title AS assignment, a.due_date 
FROM assignments a
LEFT JOIN courses c 
ON a.course_id = c.id 
WHERE c.title LIKE 'Optimized%';

/* 9. Show all course reviews with the student ID, course ID, rating, and comment. */
SELECT r.course_id, c.title AS course, r.student_id, r.rating, r.comment 
FROM reviews r
LEFT JOIN courses c 
ON r.course_id = c.id;

/* 10. List total payment amount made by each student. (Hint: GROUP BY student_id) */
SELECT payments.student_id, SUM(payments.amount) AS total_payment 
FROM payments
GROUP BY student_id;
