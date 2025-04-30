/* 1. List all users with their name, email, and role. */
SELECT name, email, role FROM users;

/* 2. Find all students (role = 'student') who were born after January 1, 1997. */
SELECT users.id, users.name, students.date_of_birth FROM students 
LEFT JOIN users ON users.id = students.user_id
WHERE users.role = 'student' AND students.date_of_birth > '1997-01-01';

/* 3. Show the names of all instructors along with their area of expertise. */
SELECT users.id, users.name, instructors.expertise_area FROM users
LEFT JOIN instructors ON instructors.user_id = users.id
WHERE users.role = 'instructor';         

/* 4. Get the title and price of all courses in the "Computer Science" category. */
SELECT courses.title, course_categories.name, courses.price FROM courses
LEFT JOIN course_categories ON courses.category_id = course_categories.id
WHERE course_categories.name = 'Computer Science';