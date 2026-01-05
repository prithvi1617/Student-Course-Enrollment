import express from "express";
import { pool } from "./db.js";

const app = express();
app.use(express.json());

/**
 * Save student course selections
 * Input: { studentId, courseIds[] }
 */
app.post("/enroll", async (req, res) => {
  const { studentId, courseIds } = req.body;

  if (!studentId || !Array.isArray(courseIds))
    return res.status(400).json({ error: "Invalid input" });

  if (courseIds.length === 0)
    return res.status(400).json({ error: "Empty course list" });

  const client = await pool.connect();

  try {
    await client.query("BEGIN");

    const student = await client.query("SELECT * FROM students WHERE id = $1", [
      studentId,
    ]);
    if (!student.rowCount) throw new Error("Student not found");

    for (const courseId of courseIds) {
      await client.query(
        "INSERT INTO enrollments (student_id, course_id) VALUES ($1, $2)",
        [studentId, courseId]
      );
    }

    await client.query("COMMIT");
    res.json({ message: "Enrollment successful" });
  } catch (err) {
    await client.query("ROLLBACK");
    res.status(400).json({ error: err.message });
  } finally {
    client.release();
  }
});

/**
 * Admin: Add timetable
 */
app.post("/admin/timetable", async (req, res) => {
  const { courseId, day, startTime, endTime } = req.body;

  try {
    await pool.query(
      `INSERT INTO timetables (course_id, day, start_time, end_time)
       VALUES ($1, $2, $3, $4)`,
      [courseId, day, startTime, endTime]
    );
    res.json({ message: "Timetable added" });
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

app.listen(3000, () => console.log("Server running on port 3000"));
