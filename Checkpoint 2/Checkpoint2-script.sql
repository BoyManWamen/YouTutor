-- ============================================================================
-- CSE 111 Fall 2026: Project Checkpoint 2 Script
-- Project Title: YouTutor: Campus AI Learning Platform
-- Team Members: Julian Lee, Richard Chen
-- File: Checkpoint2-script.sql
-- Run with SQLite 3.35+: sqlite3 Checkpoint2-dbase.sqlite3 ".read Checkpoint2-script.sql"
-- Rebuild from the repo: sqlite3 rebuilt.sqlite3 ".read Support/Checkpoint2-seed.sql"
-- ============================================================================

-- SCHEMA MODIFICATIONS SINCE CHECKPOINT 1
-- Kept all nine table definitions. Added indexes for course enrollments,
-- student session history, and practice question searches by topic.
-- The script creates a progress view and a session insert trigger.

-- MEMBER CONTRIBUTIONS SUMMARY
-- SECTION 1: SIMPLE STATEMENTS
-- Statement 01: Julian Lee: 100%, Richard Chen: 0%
-- Statement 02: Julian Lee: 100%, Richard Chen: 0%
-- Statement 03: Julian Lee: 100%, Richard Chen: 0%
-- Statement 04: Julian Lee: 100%, Richard Chen: 0%
-- Statement 05: Julian Lee: 0%, Richard Chen: 100%
-- Statement 06: Julian Lee: 0%, Richard Chen: 100%
-- Statement 07: Julian Lee: 0%, Richard Chen: 100%
-- Statement 08: Julian Lee: 0%, Richard Chen: 100%
-- Statement 09: Julian Lee: 50%, Richard Chen: 50%
-- Statement 10: Julian Lee: 50%, Richard Chen: 50%

-- SECTION 2: INTERMEDIATE STATEMENTS
-- Statement 11: Julian Lee: 0%, Richard Chen: 100%
-- Statement 12: Julian Lee: 0%, Richard Chen: 100%
-- Statement 13: Julian Lee: 0%, Richard Chen: 100%
-- Statement 14: Julian Lee: 0%, Richard Chen: 100%
-- Statement 15: Julian Lee: 100%, Richard Chen: 0%
-- Statement 16: Julian Lee: 100%, Richard Chen: 0%
-- Statement 17: Julian Lee: 100%, Richard Chen: 0%
-- Statement 18: Julian Lee: 100%, Richard Chen: 0%
-- Statement 19: Julian Lee: 50%, Richard Chen: 50%
-- Statement 20: Julian Lee: 50%, Richard Chen: 50%
-- Statement 21: Julian Lee: 50%, Richard Chen: 50%

-- SECTION 3: COMPLEX STATEMENTS
-- Statement 22: Julian Lee: 100%, Richard Chen: 0%
-- Statement 23: Julian Lee: 100%, Richard Chen: 0%
-- Statement 24: Julian Lee: 100%, Richard Chen: 0%
-- Statement 25: Julian Lee: 100%, Richard Chen: 0%
-- Statement 26: Julian Lee: 0%, Richard Chen: 100%
-- Statement 27: Julian Lee: 0%, Richard Chen: 100%
-- Statement 28: Julian Lee: 0%, Richard Chen: 100%
-- Statement 29: Julian Lee: 0%, Richard Chen: 100%
-- Statement 30: Julian Lee: 50%, Richard Chen: 50%
-- Statement 31: Julian Lee: 50%, Richard Chen: 50%
-- Statement 32: Julian Lee: 50%, Richard Chen: 50%

PRAGMA foreign_keys = ON;
.headers on
.mode column
.bail on

-- Roll back the examples at the end so the seed data is ready for another run.
BEGIN;

-- SECTION 1: SIMPLE STATEMENTS

-- Statement 01: Course catalog
-- Explanation: List the course codes and titles in catalog order.
SELECT course_code, title
FROM Courses
ORDER BY course_code;

-- Statement 02: CSE 111 topics
-- Explanation: Show the topics in course 1 in the order students study them.
SELECT sequence_no, title
FROM Topics
WHERE course_id = 1
ORDER BY sequence_no;

-- Statement 03: Introductory join questions
-- Explanation: List join questions with difficulty levels 1 through 3.
SELECT question_id, prompt, difficulty
FROM PracticeQuestions
WHERE topic_id = 1 AND difficulty BETWEEN 1 AND 3
ORDER BY difficulty, question_id;

-- Statement 04: Saved tutoring conversation
-- Explanation: Load the messages from session 1 in conversation order.
SELECT message_no, role, content
FROM AIMessages
WHERE session_id = 1
ORDER BY message_no;

-- Statement 05: Student name search
-- Explanation: Find active students whose names start with M.
SELECT student_id, name, email
FROM Students
WHERE active = 1 AND name LIKE 'M%'
ORDER BY name, student_id;

-- Statement 06: Session practice score
-- Explanation: Count the practice attempts and correct answers in session 1.
SELECT COUNT(*) AS attempts, COALESCE(SUM(is_correct), 0) AS correct_answers
FROM QuestionAttempts
WHERE session_id = 1;

-- Statement 07: Register a student
-- Explanation: Create a student account for Sofia Reyes.
INSERT INTO Students (student_id, name, email, created_at)
VALUES (901, 'Sofia Reyes', 'sofia.reyes@example.test', '2026-11-08 12:00:00')
RETURNING student_id, name, email;

-- Statement 08: Revise a question's difficulty
-- Explanation: Set question 6 to difficulty level 5.
UPDATE PracticeQuestions
SET difficulty = 5
WHERE question_id = 6
RETURNING question_id, difficulty;

-- Statement 09: Add a course enrollment
-- Explanation: Enroll Sofia in CSE 111.
INSERT INTO CourseEnrollments (student_id, course_id, enrolled_at)
VALUES (901, 1, '2026-11-08 12:00:00');

-- Statement 10: Clear a viewed topic
-- Explanation: Clear Zoe's viewed marker for Graph Traversal.
DELETE FROM TopicViews
WHERE student_id = 5 AND topic_id = 5
RETURNING student_id, topic_id;

-- SECTION 2: INTERMEDIATE STATEMENTS

-- Statement 11: Student's active courses
-- Explanation: Show Sofia's active enrollments with their course codes and titles.
SELECT c.course_code, c.title, e.enrolled_at
FROM CourseEnrollments AS e
JOIN Courses AS c ON c.course_id = e.course_id
WHERE e.student_id = 901 AND e.status = 'active'
ORDER BY c.course_code;

-- Statement 12: Shared sessions available to a student
-- Explanation: Show sessions other students shared in Ben's active courses.
SELECT c.course_code, t.title AS topic, s.session_id, author.name AS shared_by
FROM CourseEnrollments AS e
JOIN Courses AS c ON c.course_id = e.course_id
JOIN Topics AS t ON t.course_id = c.course_id
JOIN LearningSessions AS s ON s.topic_id = t.topic_id
JOIN Students AS author ON author.student_id = s.student_id
WHERE e.student_id = 8 AND e.status = 'active'
  AND s.share_status = 'shared' AND s.student_id <> e.student_id
ORDER BY c.course_code, t.sequence_no, s.started_at DESC, s.session_id;

-- Statement 13: Fork history
-- Explanation: Show the source session for each of Leo's forks.
SELECT child.session_id AS fork_id, parent.session_id AS source_id,
       author.name AS source_author, t.title AS topic
FROM LearningSessions AS child
JOIN LearningSessions AS parent ON parent.session_id = child.parent_session_id
JOIN Students AS author ON author.student_id = parent.student_id
JOIN Topics AS t ON t.topic_id = child.topic_id
WHERE child.student_id = 2
ORDER BY child.session_id;

-- Statement 14: Active sessions without practice
-- Explanation: Find active sessions with no recorded question attempts.
SELECT s.session_id, s.student_id, t.title AS topic, s.started_at
FROM LearningSessions AS s
JOIN Topics AS t ON t.topic_id = s.topic_id
LEFT JOIN QuestionAttempts AS a ON a.session_id = s.session_id
WHERE s.status = 'active' AND a.session_id IS NULL
ORDER BY s.started_at, s.session_id;

-- Statement 15: Topics with a full practice set
-- Explanation: List topics that have at least three questions in the question bank.
SELECT c.course_code, t.title AS topic, COUNT(*) AS questions
FROM Topics AS t
JOIN Courses AS c ON c.course_id = t.course_id
JOIN PracticeQuestions AS q ON q.topic_id = t.topic_id
GROUP BY c.course_code, t.topic_id, t.title
HAVING COUNT(*) >= 3
ORDER BY c.course_code, t.topic_id;

-- Statement 16: Active students per course
-- Explanation: Count active students with active enrollments, including courses with zero.
SELECT c.course_code, COUNT(st.student_id) AS active_students
FROM Courses AS c
LEFT JOIN CourseEnrollments AS e
    ON e.course_id = c.course_id AND e.status = 'active'
LEFT JOIN Students AS st ON st.student_id = e.student_id AND st.active = 1
GROUP BY c.course_id, c.course_code
ORDER BY active_students DESC, c.course_code;

-- Statement 17: Above-average difficulty in CSE 111
-- Explanation: Find CSE 111 questions harder than the average for that course.
SELECT q.question_id, t.title AS topic, q.prompt, q.difficulty
FROM PracticeQuestions AS q
JOIN Topics AS t ON t.topic_id = q.topic_id
WHERE t.course_id = 1 AND q.difficulty > (
    SELECT AVG(q2.difficulty)
    FROM PracticeQuestions AS q2
    JOIN Topics AS t2 ON t2.topic_id = q2.topic_id
    WHERE t2.course_id = 1
)
ORDER BY q.difficulty DESC, q.question_id;

-- Statement 18: Questions missed by several students
-- Explanation: Find practice questions that at least two different students answered incorrectly.
SELECT q.question_id, t.title AS topic, q.prompt,
       COUNT(DISTINCT s.student_id) AS students_who_missed
FROM PracticeQuestions AS q
JOIN Topics AS t ON t.topic_id = q.topic_id
JOIN QuestionAttempts AS a ON a.question_id = q.question_id
JOIN LearningSessions AS s ON s.session_id = a.session_id
WHERE a.is_correct = 0
GROUP BY q.question_id, t.title, q.prompt
HAVING COUNT(DISTINCT s.student_id) >= 2
ORDER BY students_who_missed DESC, q.question_id;

-- Statement 19: Practice feedback for a session
-- Explanation: Show the prompt, response and feedback for each attempt in session 3.
SELECT a.attempt_no, q.prompt, a.response, a.is_correct, a.feedback
FROM QuestionAttempts AS a
JOIN PracticeQuestions AS q ON q.question_id = a.question_id
WHERE a.session_id = 3
ORDER BY a.attempt_no;

-- Statement 20: Complete a guided session
-- Explanation: Close Maya's session 3 if it is still active and contains practice work.
UPDATE LearningSessions
SET status = 'completed', ended_at = '2026-11-08 12:00:00'
WHERE session_id = 3 AND student_id = 1 AND status = 'active'
  AND started_at <= '2026-11-08 12:00:00'
  AND (SELECT COUNT(*) FROM QuestionAttempts WHERE session_id = 3) > 0
RETURNING session_id, status, ended_at;

-- Statement 21: Restore a course enrollment
-- Explanation: Reactivate Imani's withdrawn CSE 111 enrollment if her account is active.
UPDATE CourseEnrollments
SET status = 'active'
WHERE student_id = 7 AND course_id = 1 AND status = 'withdrawn'
  AND student_id IN (SELECT student_id FROM Students WHERE active = 1)
RETURNING student_id, course_id, status;

-- SECTION 3: COMPLEX STATEMENTS

-- Statement 22: Next join questions to try
-- Explanation: Find join questions Maya can access through an active enrollment and has yet to try.
SELECT q.question_id, q.prompt, q.difficulty
FROM PracticeQuestions AS q
WHERE q.topic_id = 1
  AND EXISTS (
      SELECT 1
      FROM Topics AS t
      JOIN CourseEnrollments AS e ON e.course_id = t.course_id
      JOIN Students AS st ON st.student_id = e.student_id
      WHERE t.topic_id = q.topic_id AND st.student_id = 1
        AND st.active = 1 AND e.status = 'active'
  )
  AND NOT EXISTS (
      SELECT 1
      FROM QuestionAttempts AS a
      JOIN LearningSessions AS s ON s.session_id = a.session_id
      WHERE a.question_id = q.question_id AND s.student_id = 1
  )
ORDER BY q.difficulty, q.question_id;

-- Statement 23: Session activity timeline
-- Explanation: Combine the tutoring messages and practice responses in session 1 by time.
SELECT created_at AS activity_at, role AS activity, message_no AS item_no, content AS detail
FROM AIMessages
WHERE session_id = 1
UNION
SELECT submitted_at, 'practice', attempt_no, response
FROM QuestionAttempts
WHERE session_id = 1
ORDER BY activity_at, activity, item_no;

-- Statement 24: Topics viewed and practiced
-- Explanation: List the topics Maya has both viewed and practiced.
SELECT t.topic_id, t.title
FROM Topics AS t
WHERE t.topic_id IN (
    SELECT topic_id
    FROM TopicViews
    WHERE student_id = 1
    INTERSECT
    SELECT s.topic_id
    FROM LearningSessions AS s
    JOIN QuestionAttempts AS a ON a.session_id = s.session_id
    WHERE s.student_id = 1
)
ORDER BY t.topic_id;

-- Statement 25: Enrolled students without a shared session
-- Explanation: Find active CSE 111 students who have yet to share a session in that course.
SELECT st.student_id, st.name
FROM Students AS st
WHERE st.active = 1 AND st.student_id IN (
    SELECT student_id
    FROM CourseEnrollments
    WHERE course_id = 1 AND status = 'active'
    EXCEPT
    SELECT s.student_id
    FROM LearningSessions AS s
    JOIN Topics AS t ON t.topic_id = s.topic_id
    WHERE t.course_id = 1 AND s.share_status = 'shared'
)
ORDER BY st.name, st.student_id;

-- Statement 26: Most recent answer per question
-- Explanation: Show Maya's latest answer to each question she has tried, including retries.
WITH ranked_attempts AS (
    SELECT a.question_id, a.response, a.is_correct, a.submitted_at,
           ROW_NUMBER() OVER (
               PARTITION BY a.question_id
               ORDER BY a.submitted_at DESC, a.session_id DESC, a.attempt_no DESC
           ) AS attempt_rank
    FROM QuestionAttempts AS a
    JOIN LearningSessions AS s ON s.session_id = a.session_id
    WHERE s.student_id = 1
)
SELECT q.question_id, q.prompt, a.response, a.is_correct, a.submitted_at
FROM ranked_attempts AS a
JOIN PracticeQuestions AS q ON q.question_id = a.question_id
WHERE a.attempt_rank = 1
ORDER BY q.question_id;

-- Statement 27: Most forked sessions by topic
-- Explanation: Rank shared sessions by fork count within each topic, keeping ties at the same rank.
SELECT t.title AS topic, s.session_id, COUNT(f.session_id) AS forks,
       DENSE_RANK() OVER (
           PARTITION BY s.topic_id ORDER BY COUNT(f.session_id) DESC
       ) AS fork_rank
FROM LearningSessions AS s
JOIN Topics AS t ON t.topic_id = s.topic_id
LEFT JOIN LearningSessions AS f ON f.parent_session_id = s.session_id
WHERE s.share_status = 'shared'
GROUP BY s.topic_id, t.title, s.session_id
ORDER BY s.topic_id, fork_rank, s.session_id;

-- Statement 28: Topic progress view
-- Explanation: Summarize each student's completed practice by topic and flag accuracy below 70%.
CREATE VIEW CompletedTopicProgress AS
WITH topic_scores AS (
    SELECT s.student_id, s.topic_id, COUNT(*) AS attempts,
           SUM(a.is_correct) AS correct_answers
    FROM LearningSessions AS s
    JOIN QuestionAttempts AS a ON a.session_id = s.session_id
    WHERE s.status = 'completed'
    GROUP BY s.student_id, s.topic_id
)
SELECT student_id, topic_id, attempts, correct_answers,
       ROUND(100.0 * correct_answers / attempts, 1) AS accuracy_pct,
       CASE
           WHEN 100.0 * correct_answers / attempts < 70 THEN 'review'
           ELSE 'on track'
       END AS progress
FROM topic_scores;

-- Statement 29: Topics to review
-- Explanation: Use the progress view to show Maya which topics could use more practice.
SELECT t.title AS topic, p.attempts, p.correct_answers, p.accuracy_pct
FROM CompletedTopicProgress AS p
JOIN Topics AS t ON t.topic_id = p.topic_id
WHERE p.student_id = 1 AND p.progress = 'review'
ORDER BY p.accuracy_pct, p.topic_id;

-- Statement 30: Validate and track new sessions
-- Explanation: Require active enrollment and a shared source on the same topic for forks, then mark the topic viewed.
CREATE TRIGGER track_new_session
AFTER INSERT ON LearningSessions
BEGIN
    SELECT RAISE(ABORT, 'An active course enrollment is required')
    WHERE NOT EXISTS (
        SELECT 1
        FROM Topics AS t
        JOIN CourseEnrollments AS e ON e.course_id = t.course_id
        JOIN Students AS st ON st.student_id = e.student_id
        WHERE t.topic_id = NEW.topic_id AND st.student_id = NEW.student_id
          AND st.active = 1 AND e.status = 'active'
    );

    SELECT RAISE(ABORT, 'A fork requires a shared session on the same topic')
    WHERE NEW.parent_session_id IS NOT NULL AND NOT EXISTS (
        SELECT 1
        FROM LearningSessions AS parent
        WHERE parent.session_id = NEW.parent_session_id
          AND parent.topic_id = NEW.topic_id AND parent.share_status = 'shared'
    );

    INSERT INTO TopicViews (student_id, topic_id)
    VALUES (NEW.student_id, NEW.topic_id)
    ON CONFLICT (student_id, topic_id) DO NOTHING;
END;

-- Statement 31: Start a session from a shared source
-- Explanation: Start Ben's private fork from Maya's shared session if it belongs to one of his active courses.
INSERT INTO LearningSessions (session_id, student_id, topic_id, parent_session_id, started_at)
SELECT 901, st.student_id, parent.topic_id, parent.session_id, '2026-11-08 12:30:00'
FROM LearningSessions AS parent
JOIN Topics AS t ON t.topic_id = parent.topic_id
JOIN CourseEnrollments AS e ON e.course_id = t.course_id
JOIN Students AS st ON st.student_id = e.student_id
WHERE parent.session_id = 1 AND parent.share_status = 'shared'
  AND st.student_id = 8 AND st.active = 1 AND e.status = 'active';

-- Statement 32: Verify the fork and topic view
-- Explanation: Show Ben's new fork and whether the trigger marked its topic viewed.
SELECT st.name, t.title AS topic, s.session_id, s.parent_session_id, s.share_status,
       CASE WHEN v.topic_id IS NULL THEN 'no' ELSE 'yes' END AS topic_viewed
FROM LearningSessions AS s
JOIN Students AS st ON st.student_id = s.student_id
JOIN Topics AS t ON t.topic_id = s.topic_id
LEFT JOIN TopicViews AS v ON v.student_id = s.student_id AND v.topic_id = s.topic_id
WHERE s.session_id = 901;

ROLLBACK;
