# Student Course Enrollment Backend

This project implements a **Student Course Enrollment System** using **Node.js, **PostgreSQL**, and **Docker\*\*.

It ensures:

- Students can only enroll in courses from their own college
- Students cannot enroll in courses with timetable clashes
- Database-level constraints + triggers enforce data integrity

---

## 🚀 How to Run

```bash
docker compose up --build
```

API runs at:

```
http://localhost:3000
```

---

## 📌 Seed Data Reference

### Colleges

| ID  | Name                  |
| --- | --------------------- |
| 1   | Engineering College A |
| 2   | Engineering College B |

### Students

| ID  | Name    | College   |
| --- | ------- | --------- |
| 1   | Alice   | College A |
| 2   | Bob     | College A |
| 3   | Charlie | College B |

### Courses

| ID  | Code  | College   |
| --- | ----- | --------- |
| 1   | CS101 | College A |
| 2   | MA204 | College A |
| 3   | AP105 | College A |
| 4   | CS201 | College B |

---

## 🧪 API Usage (cURL)

### 1️⃣ Enroll Student in Courses (SUCCESS)

Enroll **Alice (studentId=1)** into **CS101 & MA204** (no clash).

```bash
curl -X POST http://localhost:3000/enroll \
  -H "Content-Type: application/json" \
  -d '{
    "studentId": 1,
    "courseIds": [1, 2]
  }'
```

**Response**

```json
{
  "message": "Enrollment successful"
}
```

---

### 2️⃣ Enroll With Timetable Clash (FAIL ❌)

CS101 and AP105 overlap on **Monday**.

```bash
curl -X POST http://localhost:3000/enroll \
  -H "Content-Type: application/json" \
  -d '{
    "studentId": 1,
    "courseIds": [1, 3]
  }'
```

**Response**

```json
{
  "error": "Timetable conflict detected"
}
```

---

### 3️⃣ Cross-College Enrollment (FAIL ❌)

Alice (College A) tries to enroll in **CS201 (College B)**.

```bash
curl -X POST http://localhost:3000/enroll \
  -H "Content-Type: application/json" \
  -d '{
    "studentId": 1,
    "courseIds": [4]
  }'
```

**Response**

```json
{
  "error": "Student and Course must belong to the same college"
}
```

---

### 4️⃣ Invalid Student (FAIL ❌)

```bash
curl -X POST http://localhost:3000/enroll \
  -H "Content-Type: application/json" \
  -d '{
    "studentId": 999,
    "courseIds": [1]
  }'
```

**Response**

```json
{
  "error": "Student not found"
}
```

---

### 5️⃣ Empty Course List (FAIL ❌)

```bash
curl -X POST http://localhost:3000/enroll \
  -H "Content-Type: application/json" \
  -d '{
    "studentId": 1,
    "courseIds": []
  }'
```

**Response**

```json
{
  "error": "Empty course list"
}
```

---

## 🛠 Admin APIs

### Add Course Timetable

```bash
curl -X POST http://localhost:3000/admin/timetable \
  -H "Content-Type: application/json" \
  -d '{
    "courseId": 2,
    "day": "FRI",
    "startTime": "14:00",
    "endTime": "16:00"
  }'
```

**Response**

```json
{
  "message": "Timetable added"
}
```

---

**Author:** Prithvi Chouhan
