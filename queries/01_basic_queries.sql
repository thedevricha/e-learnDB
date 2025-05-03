SELECT * FROM users;
SELECT * FROM students;
SELECT * FROM instructors;
SELECT * FROM courses;  
SELECT * FROM course_categories;
SELECT * FROM lessons;
SELECT * FROM payments;
SELECT * FROM reviews;
SELECT * FROM certificates;
SELECT * FROM submissions;
SELECT * FROM assignments;
SELECT * FROM enrollments;

/* 1. List all users with their name, email, and role. */
SELECT name, email, role FROM users;

/* 2. Find all students (role = 'student') who were born after January 1, 1997. */
SELECT users.id, users.name, students.date_of_birth FROM students 
JOIN users ON students.user_id = users.id
WHERE users.role = 'student' AND students.date_of_birth > '1997-01-01';

/* 3. Show the names of all instructors along with their area of expertise. */
SELECT users.id, users.name, instructors.expertise_area FROM instructors
JOIN users ON instructors.user_id = users.id
WHERE users.role = 'instructor';         

/* 4. Get the title and price of all courses in the "Computer Science" category. */
SELECT courses.title, course_categories.name, courses.price FROM courses
JOIN course_categories ON courses.category_id = course_categories.id
WHERE course_categories.name = 'Computer Science';

/* 5. List all lessons for the course "Course 2: Professional Mathematics", ordered by lesson order. */
SELECT courses.title, lessons.content, lessons.lesson_order FROM lessons
JOIN courses ON lessons.course_id = courses.id
WHERE courses.title = 'Course 2: Professional Mathematics'
ORDER BY lessons.lesson_order;

/* 6. How many lessons are there in each course? */
SELECT course_id, COUNT(id) as lesson_count FROM lessons GROUP BY course_id;

/* 7. Find all students enrolled in the course "Course 2: Advanced Data Analysis". */
SELECT users.name FROM enrollments
JOIN students ON enrollments.student_id = students.id
JOIN users ON students.user_id = users.id
JOIN courses ON enrollments.course_id = courses.id
WHERE courses.title = 'Course 2: Advanced Data Analysis';

/* 8. List the assignments and their due dates for the course "Course 2: Advanced Data Analysis". */
SELECT courses.title AS course, assignments.title AS assignment, assignments.due_date 
FROM assignments
LEFT JOIN courses ON assignments.course_id = courses.id
WHERE courses.title = 'Course 2: Advanced Data Analysis';

/* 9. Show all course reviews with the student ID, course ID, rating, and comment. */
SELECT reviews.course_id, courses.title AS course, reviews.student_id, reviews.rating, reviews.comment 
FROM reviews
LEFT JOIN courses ON reviews.course_id = courses.id;

/* 10. List total payment amount made by each student. (Hint: GROUP BY student_id) */
SELECT payments.student_id, SUM(payments.amount) AS total_payment 
FROM payments 
GROUP BY student_id;
