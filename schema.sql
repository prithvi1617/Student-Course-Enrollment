-- =========================
-- Colleges
-- =========================
CREATE TABLE colleges (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE
);

-- =========================
-- Students
-- =========================
CREATE TABLE students (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  college_id INT NOT NULL,
  CONSTRAINT fk_student_college
    FOREIGN KEY (college_id)
    REFERENCES colleges(id)
    ON DELETE CASCADE
);

-- =========================
-- Courses
-- =========================
CREATE TABLE courses (
  id SERIAL PRIMARY KEY,
  code TEXT NOT NULL,
  college_id INT NOT NULL,
  CONSTRAINT fk_course_college
    FOREIGN KEY (college_id)
    REFERENCES colleges(id)
    ON DELETE CASCADE,
  UNIQUE (code, college_id)
);

-- =========================
-- Course Timetables
-- =========================
CREATE TABLE timetables (
  id SERIAL PRIMARY KEY,
  course_id INT NOT NULL,
  day TEXT NOT NULL CHECK (day IN ('MON','TUE','WED','THU','FRI','SAT')),
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  CONSTRAINT fk_timetable_course
    FOREIGN KEY (course_id)
    REFERENCES courses(id)
    ON DELETE CASCADE,
  CHECK (start_time < end_time)
);

-- =========================
-- Student Enrollments
-- =========================
CREATE TABLE enrollments (
  student_id INT NOT NULL,
  course_id INT NOT NULL,
  PRIMARY KEY (student_id, course_id),
  CONSTRAINT fk_enroll_student
    FOREIGN KEY (student_id)
    REFERENCES students(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_enroll_course
    FOREIGN KEY (course_id)
    REFERENCES courses(id)
    ON DELETE CASCADE
);

-- ==================================================
-- Prevent student enrolling in course of other college
-- ==================================================
CREATE OR REPLACE FUNCTION check_same_college()
RETURNS TRIGGER AS $$
BEGIN
  IF (
    SELECT college_id FROM students WHERE id = NEW.student_id
  ) != (
    SELECT college_id FROM courses WHERE id = NEW.course_id
  ) THEN
    RAISE EXCEPTION 'Student and Course must belong to the same college';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_same_college
BEFORE INSERT ON enrollments
FOR EACH ROW
EXECUTE FUNCTION check_same_college();

-- ==================================================
-- Prevent timetable clashes for a student
-- ==================================================
CREATE OR REPLACE FUNCTION check_timetable_conflict()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM enrollments e
    JOIN timetables t1 ON t1.course_id = e.course_id
    JOIN timetables t2 ON t2.course_id = NEW.course_id
    WHERE e.student_id = NEW.student_id
      AND t1.day = t2.day
      AND t1.start_time < t2.end_time
      AND t2.start_time < t1.end_time
  ) THEN
    RAISE EXCEPTION 'Timetable conflict detected';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_timetable_conflict
BEFORE INSERT ON enrollments
FOR EACH ROW
EXECUTE FUNCTION check_timetable_conflict();


-- =========================
-- Seed Data
-- =========================

-- Colleges
INSERT INTO colleges (name) VALUES
('Engineering College A'),
('Engineering College B');

-- Students
INSERT INTO students (name, college_id) VALUES
('Alice', 1),
('Bob', 1),
('Charlie', 2);

-- Courses (College A)
INSERT INTO courses (code, college_id) VALUES
('CS101', 1),
('MA204', 1),
('AP105', 1);

-- Courses (College B)
INSERT INTO courses (code, college_id) VALUES
('CS201', 2);

-- Timetables for College A courses
INSERT INTO timetables (course_id, day, start_time, end_time) VALUES
-- CS101
(1, 'MON', '09:00', '10:00'),
(1, 'WED', '09:00', '10:00'),

-- MA204 (NO clash with CS101)
(2, 'MON', '10:00', '11:00'),

-- AP105 (WILL clash with CS101 on MON)
(3, 'MON', '09:30', '10:30');

-- Timetable for College B course
INSERT INTO timetables (course_id, day, start_time, end_time) VALUES
(4, 'MON', '09:00', '11:00');
