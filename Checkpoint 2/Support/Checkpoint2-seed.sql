PRAGMA foreign_keys = ON;

BEGIN;

CREATE TABLE Students (
    student_id INTEGER PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Courses (
    course_id INTEGER PRIMARY KEY,
    course_code VARCHAR(30) NOT NULL UNIQUE,
    title VARCHAR(150) NOT NULL
);

CREATE TABLE Topics (
    topic_id INTEGER PRIMARY KEY,
    course_id INTEGER NOT NULL,
    title VARCHAR(150) NOT NULL,
    sequence_no INTEGER NOT NULL CHECK (sequence_no > 0),
    UNIQUE (course_id, title),
    UNIQUE (course_id, sequence_no),
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE CourseEnrollments (
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'withdrawn')),
    enrolled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Courses(course_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE TopicViews (
    student_id INTEGER NOT NULL,
    topic_id INTEGER NOT NULL,
    PRIMARY KEY (student_id, topic_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (topic_id) REFERENCES Topics(topic_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE LearningSessions (
    session_id INTEGER PRIMARY KEY,
    student_id INTEGER NOT NULL,
    topic_id INTEGER NOT NULL,
    parent_session_id INTEGER,
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'completed')),
    share_status VARCHAR(20) NOT NULL DEFAULT 'private'
        CHECK (share_status IN ('private', 'shared')),
    CHECK (ended_at IS NULL OR ended_at >= started_at),
    CHECK (parent_session_id IS NULL OR parent_session_id <> session_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (topic_id) REFERENCES Topics(topic_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (parent_session_id) REFERENCES LearningSessions(session_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE AIMessages (
    message_id INTEGER PRIMARY KEY,
    session_id INTEGER NOT NULL,
    message_no INTEGER NOT NULL CHECK (message_no > 0),
    role VARCHAR(20) NOT NULL
        CHECK (role IN ('student', 'assistant')),
    content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (session_id, message_no),
    FOREIGN KEY (session_id) REFERENCES LearningSessions(session_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE PracticeQuestions (
    question_id INTEGER PRIMARY KEY,
    topic_id INTEGER NOT NULL,
    prompt TEXT NOT NULL,
    answer_key TEXT NOT NULL,
    explanation TEXT NOT NULL,
    difficulty INTEGER NOT NULL DEFAULT 2
        CHECK (difficulty BETWEEN 1 AND 5),
    FOREIGN KEY (topic_id) REFERENCES Topics(topic_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE QuestionAttempts (
    session_id INTEGER NOT NULL,
    attempt_no INTEGER NOT NULL CHECK (attempt_no > 0),
    question_id INTEGER NOT NULL,
    response TEXT NOT NULL,
    is_correct BOOLEAN NOT NULL,
    feedback TEXT,
    submitted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (session_id, attempt_no),
    FOREIGN KEY (session_id) REFERENCES LearningSessions(session_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES PracticeQuestions(question_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE INDEX idx_enrollments_course_status
    ON CourseEnrollments(course_id, status);

CREATE INDEX idx_sessions_student_topic_status
    ON LearningSessions(student_id, topic_id, status);

CREATE INDEX idx_questions_topic_difficulty
    ON PracticeQuestions(topic_id, difficulty);

INSERT INTO Students (student_id, name, email, active, created_at) VALUES
    (1, 'Maya Patel', 'maya.patel@example.com', 1, '2026-08-18 11:20:00'),
    (2, 'Leo Kim', 'leo.kim@example.com', 1, '2026-08-19 09:15:00'),
    (3, 'Ana Torres', 'ana.torres@example.com', 1, '2026-08-19 13:05:00'),
    (4, 'Noah Park', 'noah.park@example.com', 1, '2026-08-20 10:30:00'),
    (5, 'Zoe Martin', 'zoe.martin@example.com', 1, '2026-08-20 16:45:00'),
    (6, 'Omar Reed', 'omar.reed@example.com', 0, '2026-08-21 12:10:00'),
    (7, 'Imani Brooks', 'imani.brooks@example.com', 1, '2026-08-23 14:00:00'),
    (8, 'Ben Flores', 'ben.flores@example.com', 1, '2026-11-07 10:25:00');

INSERT INTO Courses (course_id, course_code, title) VALUES
    (1, 'CSE 111', 'Database Systems'),
    (2, 'CSE 100', 'Algorithm Design and Analysis'),
    (3, 'MATH 021', 'Calculus I'),
    (4, 'CSE 120', 'Software Engineering');

INSERT INTO Topics (topic_id, course_id, title, sequence_no) VALUES
    (1, 1, 'Joins', 1),
    (2, 1, 'Grouping and Aggregation', 2),
    (3, 1, 'Transactions', 3),
    (4, 2, 'Recursion', 1),
    (5, 2, 'Graph Traversal', 2),
    (6, 3, 'Limits', 1),
    (7, 3, 'Derivatives', 2),
    (8, 4, 'Requirements', 1),
    (9, 4, 'Software Testing', 2);

INSERT INTO CourseEnrollments (student_id, course_id, status, enrolled_at) VALUES
    (1, 1, 'active', '2026-08-24 08:10:00'),
    (1, 3, 'active', '2026-08-24 08:11:00'),
    (2, 1, 'active', '2026-08-24 09:00:00'),
    (2, 2, 'active', '2026-08-24 09:03:00'),
    (3, 1, 'active', '2026-08-24 10:14:00'),
    (3, 2, 'active', '2026-08-24 10:15:00'),
    (4, 1, 'active', '2026-08-24 10:45:00'),
    (4, 3, 'active', '2026-08-24 10:46:00'),
    (5, 2, 'active', '2026-08-24 11:00:00'),
    (5, 3, 'active', '2026-08-24 11:03:00'),
    (6, 2, 'withdrawn', '2026-08-24 13:28:00'),
    (7, 1, 'withdrawn', '2026-08-24 14:02:00'),
    (7, 3, 'active', '2026-08-24 14:08:00'),
    (8, 1, 'active', '2026-11-07 10:30:00'),
    (8, 4, 'active', '2026-11-07 10:31:00');

INSERT INTO TopicViews (student_id, topic_id) VALUES
    (1, 1), (1, 2), (1, 3), (1, 6),
    (2, 1), (2, 2), (2, 4), (2, 5),
    (3, 1), (3, 2), (3, 4), (3, 5),
    (4, 1), (4, 2), (4, 3), (4, 6), (4, 7),
    (5, 4), (5, 5), (5, 6), (5, 7),
    (6, 5),
    (7, 6), (7, 7);

INSERT INTO LearningSessions
    (session_id, student_id, topic_id, parent_session_id, started_at, ended_at, status, share_status)
VALUES
    (1, 1, 1, NULL, '2026-11-02 09:00:00', '2026-11-02 09:26:00', 'completed', 'shared'),
    (2, 2, 1, 1, '2026-11-02 11:10:00', '2026-11-02 11:32:00', 'completed', 'private'),
    (3, 1, 2, NULL, '2026-11-05 14:00:00', NULL, 'active', 'private'),
    (4, 3, 1, NULL, '2026-11-03 10:00:00', '2026-11-03 10:25:00', 'completed', 'shared'),
    (5, 4, 1, 4, '2026-11-03 13:00:00', '2026-11-03 13:18:00', 'completed', 'private'),
    (6, 3, 4, NULL, '2026-11-04 10:00:00', '2026-11-04 10:20:00', 'completed', 'shared'),
    (7, 2, 4, 6, '2026-11-04 15:00:00', '2026-11-04 15:22:00', 'completed', 'private'),
    (8, 4, 6, NULL, '2026-11-06 14:00:00', NULL, 'active', 'private'),
    (9, 5, 7, NULL, '2026-11-03 11:00:00', '2026-11-03 11:20:00', 'completed', 'shared'),
    (10, 7, 7, 9, '2026-11-04 16:00:00', '2026-11-04 16:24:00', 'completed', 'private'),
    (11, 6, 5, NULL, '2026-10-28 15:00:00', '2026-10-28 15:20:00', 'completed', 'private'),
    (12, 2, 2, NULL, '2026-11-05 10:00:00', '2026-11-05 10:25:00', 'completed', 'shared'),
    (13, 3, 2, 12, '2026-11-06 10:00:00', '2026-11-06 10:18:00', 'completed', 'private'),
    (14, 1, 6, NULL, '2026-11-07 09:00:00', '2026-11-07 09:16:00', 'completed', 'private'),
    (15, 5, 4, NULL, '2026-11-07 15:00:00', NULL, 'active', 'private'),
    (16, 4, 3, NULL, '2026-11-07 16:00:00', '2026-11-07 16:23:00', 'completed', 'shared'),
    (17, 4, 1, 1, '2026-11-06 15:00:00', '2026-11-06 15:21:00', 'completed', 'private');

INSERT INTO PracticeQuestions (question_id, topic_id, prompt, answer_key, explanation, difficulty) VALUES
    (1, 1, 'Which join returns only matching rows from both tables?', 'INNER JOIN', 'An inner join keeps only rows that meet the join condition.', 1),
    (2, 1, 'With Students on the left, which join keeps students without enrollments?', 'LEFT JOIN', 'A left join keeps all students and supplies NULL for missing enrollment columns.', 2),
    (3, 1, 'After a LEFT JOIN to enrollments, what condition finds students without an enrollment?', 'WHERE e.student_id IS NULL', 'The right table has NULL in its student ID only when the left row had no match.', 4),
    (4, 2, 'Which aggregate counts every row in a group?', 'COUNT(*)', 'COUNT(*) counts all rows, including rows with NULL column values.', 1),
    (5, 2, 'Which clause keeps only groups with at least three attempts?', 'HAVING COUNT(*) >= 3', 'HAVING filters groups after the aggregate is computed.', 3),
    (6, 2, 'What does COUNT(feedback) return for a group of two NULLs and one non-NULL value?', '1', 'COUNT(column) ignores NULL values.', 4),
    (7, 3, 'Which statement saves the changes in the current transaction?', 'COMMIT', 'COMMIT makes the transaction changes permanent.', 1),
    (8, 3, 'Which statement undoes the entire open transaction?', 'ROLLBACK', 'ROLLBACK discards changes made since the transaction began.', 2),
    (9, 3, 'How do you undo work since SAVEPOINT try_again without ending the transaction?', 'ROLLBACK TO try_again', 'ROLLBACK TO discards later changes but leaves the transaction open.', 3),
    (10, 4, 'What value should factorial return when n is zero?', '1', 'Returning 1 for zero gives the recursion its base case.', 1),
    (11, 4, 'How many calls are on the stack at the deepest point of factorial(3) with a base case at 0?', '4', 'The calls for 3, 2, 1 and 0 are all on the stack before unwinding.', 3),
    (12, 5, 'Which traversal finds a shortest path in an unweighted graph?', 'BFS', 'Breadth-first search visits vertices in order of distance from the start.', 2),
    (13, 5, 'Which data structure stores vertices waiting to be explored in BFS?', 'Queue', 'A queue processes the earliest discovered vertices first.', 1),
    (14, 6, 'What is the limit of (x^2 - 4)/(x - 2) as x approaches 2?', '4', 'Cancel x - 2 for x away from 2, then evaluate x + 2.', 2),
    (15, 6, 'Does a two-sided limit exist if the left-hand limit is -1 and the right-hand limit is 1?', 'No', 'The one-sided limits must be equal for the two-sided limit to exist.', 1),
    (16, 7, 'What is the derivative of x^3?', '3x^2', 'The power rule multiplies by the exponent and subtracts 1 from it.', 1),
    (17, 7, 'What is the derivative of (2x + 1)^4?', '8(2x + 1)^3', 'Apply the power rule to the outside, then multiply by the inside derivative of 2.', 3),
    (18, 8, 'Is a requirement to save session history functional or nonfunctional?', 'Functional', 'Saving history describes a behavior the system must provide.', 1),
    (19, 9, 'What kind of test checks whether two components work together?', 'Integration test', 'Integration tests verify interactions across component boundaries.', 2);

INSERT INTO AIMessages (message_id, session_id, message_no, role, content, created_at) VALUES
    (1, 1, 1, 'student', 'How are inner and left joins different?', '2026-11-02 09:01:00'),
    (2, 1, 2, 'assistant', 'An inner join keeps matches. A left join also keeps unmatched rows from the left table.', '2026-11-02 09:02:00'),
    (3, 1, 3, 'student', 'What happens to columns from the right table for those unmatched rows?', '2026-11-02 09:17:00'),
    (4, 1, 4, 'assistant', 'They are NULL for those rows.', '2026-11-02 09:18:00'),
    (5, 2, 1, 'student', 'How do I find the students who have no enrollments?', '2026-11-02 11:11:00'),
    (6, 2, 2, 'assistant', 'Left join enrollments and filter for a NULL on the enrollment side.', '2026-11-02 11:12:00'),
    (7, 3, 1, 'student', 'When should I use HAVING?', '2026-11-05 14:01:00'),
    (8, 3, 2, 'assistant', 'Use HAVING to filter groups, such as students with more than three attempts.', '2026-11-05 14:02:00'),
    (9, 4, 1, 'student', 'What happens if I join a student to two enrollment records?', '2026-11-03 10:01:00'),
    (10, 4, 2, 'assistant', 'You get one joined row per matching enrollment, so the student appears twice.', '2026-11-03 10:02:00'),
    (11, 5, 1, 'student', 'Can a left join return more rows than the left table?', '2026-11-03 13:01:00'),
    (12, 5, 2, 'assistant', 'Yes. A left row with multiple right-side matches appears once per match.', '2026-11-03 13:02:00'),
    (13, 6, 1, 'student', 'Why does recursive factorial stop at zero?', '2026-11-04 10:01:00'),
    (14, 6, 2, 'assistant', 'Zero is the base case. Its return value of 1 lets the earlier calls finish multiplying.', '2026-11-04 10:02:00'),
    (15, 7, 1, 'student', 'Which calls are still on the stack when factorial(3) reaches zero?', '2026-11-04 15:01:00'),
    (16, 7, 2, 'assistant', 'The calls for 3, 2, 1 and 0 are on the stack. They return in the opposite order.', '2026-11-04 15:02:00'),
    (17, 8, 1, 'student', 'Why can I cancel x - 2 if x is approaching 2?', '2026-11-06 14:01:00'),
    (18, 8, 2, 'assistant', 'The limit uses values near 2. At any of those values except 2 itself, x - 2 is nonzero.', '2026-11-06 14:02:00'),
    (19, 9, 1, 'student', 'Can you review the power rule?', '2026-11-03 11:01:00'),
    (20, 9, 2, 'assistant', 'For x^n, the derivative is n times x raised to n - 1.', '2026-11-03 11:02:00'),
    (21, 10, 1, 'student', 'Do I still use the power rule for (2x + 1)^4?', '2026-11-04 16:01:00'),
    (22, 10, 2, 'assistant', 'Yes. Differentiate the outside power and multiply by the derivative of 2x + 1.', '2026-11-04 16:02:00'),
    (23, 11, 1, 'student', 'Does breadth-first search use a stack?', '2026-10-28 15:01:00'),
    (24, 11, 2, 'assistant', 'Breadth-first search uses a queue. A stack is useful for depth-first search.', '2026-10-28 15:02:00'),
    (25, 12, 1, 'student', 'What is the difference between COUNT(*) and COUNT(feedback)?', '2026-11-05 10:01:00'),
    (26, 12, 2, 'assistant', 'COUNT(*) counts all rows. COUNT(feedback) counts rows where feedback is present.', '2026-11-05 10:02:00'),
    (27, 13, 1, 'student', 'Can I use COUNT(*) in WHERE to keep only large groups?', '2026-11-06 10:01:00'),
    (28, 13, 2, 'assistant', 'Use HAVING. WHERE applies to individual rows before grouping.', '2026-11-06 10:02:00'),
    (29, 14, 1, 'student', 'What if the left and right limits disagree?', '2026-11-07 09:01:00'),
    (30, 14, 2, 'assistant', 'The two-sided limit does not exist when the one-sided limits differ.', '2026-11-07 09:02:00'),
    (31, 15, 1, 'student', 'Does every recursive function need a base case?', '2026-11-07 15:01:00'),
    (32, 15, 2, 'assistant', 'A terminating recursive function needs a stopping case and a way to reach it.', '2026-11-07 15:02:00'),
    (33, 16, 1, 'student', 'Can I undo only one part of a transaction?', '2026-11-07 16:01:00'),
    (34, 16, 2, 'assistant', 'Set a savepoint first. ROLLBACK TO that savepoint undoes changes after it.', '2026-11-07 16:02:00'),
    (35, 17, 1, 'student', 'Why do the unmatched enrollments show NULLs?', '2026-11-06 15:01:00'),
    (36, 17, 2, 'assistant', 'A left join still returns the student. The missing enrollment fields become NULL.', '2026-11-06 15:02:00');

INSERT INTO QuestionAttempts (session_id, attempt_no, question_id, response, is_correct, feedback, submitted_at) VALUES
    (1, 1, 1, 'INNER JOIN', 1, 'Correct.', '2026-11-02 09:06:00'),
    (1, 2, 2, 'INNER JOIN', 0, 'An inner join drops students with no match.', '2026-11-02 09:12:00'),
    (1, 3, 2, 'CROSS JOIN', 0, 'A cross join pairs every student with every enrollment.', '2026-11-02 09:23:00'),
    (2, 1, 2, 'LEFT JOIN', 1, 'Correct.', '2026-11-02 11:18:00'),
    (2, 2, 3, 'WHERE e.student_id IS NULL', 1, 'Correct. The NULL identifies an unmatched student.', '2026-11-02 11:26:00'),
    (3, 1, 4, 'COUNT(*)', 1, 'Correct.', '2026-11-05 14:06:00'),
    (3, 2, 5, 'WHERE COUNT(*) >= 3', 0, 'Use HAVING to filter on the count for a group.', '2026-11-05 14:10:00'),
    (4, 1, 1, 'INNER JOIN', 1, 'Correct.', '2026-11-03 10:06:00'),
    (4, 2, 2, 'INNER JOIN', 0, 'Choose the join that keeps all students on the left.', '2026-11-03 10:13:00'),
    (4, 3, 2, 'LEFT JOIN', 1, 'Correct.', '2026-11-03 10:21:00'),
    (5, 1, 2, 'RIGHT JOIN', 0, 'Students is the left table in this question.', '2026-11-03 13:06:00'),
    (5, 2, 3, 'WHERE e.student_id IS NULL', 1, 'Correct.', '2026-11-03 13:12:00'),
    (6, 1, 10, '1', 1, 'Correct.', '2026-11-04 10:06:00'),
    (6, 2, 11, '3', 0, 'Include the call that handles the base case.', '2026-11-04 10:14:00'),
    (7, 1, 11, '4', 1, 'Correct.', '2026-11-04 15:08:00'),
    (7, 2, 10, '1', 1, 'Correct.', '2026-11-04 15:15:00'),
    (9, 1, 16, '3x^2', 1, 'Correct.', '2026-11-03 11:06:00'),
    (9, 2, 17, '4(2x + 1)^3', 0, 'Multiply by 2 for the derivative of the inner expression.', '2026-11-03 11:14:00'),
    (10, 1, 17, '8(2x + 1)^3', 1, 'Correct.', '2026-11-04 16:09:00'),
    (10, 2, 16, '3x', 0, 'Subtract one from the original exponent.', '2026-11-04 16:18:00'),
    (11, 1, 12, 'DFS', 0, 'Breadth-first search visits all nearer vertices before farther ones.', '2026-10-28 15:07:00'),
    (11, 2, 13, 'Queue', 1, NULL, '2026-10-28 15:14:00'),
    (12, 1, 4, 'COUNT(*)', 1, 'Correct.', '2026-11-05 10:07:00'),
    (12, 2, 6, '1', 1, 'Correct.', '2026-11-05 10:18:00'),
    (13, 1, 5, 'HAVING COUNT(*) >= 3', 1, 'Correct.', '2026-11-06 10:07:00'),
    (13, 2, 6, '3', 0, 'Only one feedback value is non-NULL.', '2026-11-06 10:14:00'),
    (14, 1, 14, '4', 1, 'Correct.', '2026-11-07 09:06:00'),
    (14, 2, 15, 'No', 1, 'Correct.', '2026-11-07 09:11:00'),
    (15, 1, 10, '0', 0, 'The value of 0! is 1.', '2026-11-07 15:06:00'),
    (16, 1, 7, 'COMMIT', 1, 'Correct.', '2026-11-07 16:06:00'),
    (16, 2, 9, 'ROLLBACK TO try_again', 1, 'Correct.', '2026-11-07 16:15:00'),
    (17, 1, 2, 'LEFT JOIN', 1, 'Correct.', '2026-11-06 15:07:00'),
    (17, 2, 3, 'WHERE e.student_id = NULL', 0, 'Use IS NULL to test for a NULL value.', '2026-11-06 15:15:00');

COMMIT;
