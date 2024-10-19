1. 查询所有学生的信息。
SELECT * FROM student;
2. 查询所有课程的信息。
SELECT * FROM course;  
3. 查询所有学生的姓名、学号和班级。
SELECT name, student_id, my_class FROM student; 
4. 查询所有教师的姓名和职称。
SELECT name, title FROM teacher;  
5. 查询不同课程的平均分数。
SELECT course_id, AVG(score) AS average_score   
FROM score   
GROUP BY course_id; 
6. 查询每个学生的平均分数。
SELECT student_id, AVG(score) AS average_score   
FROM score   
GROUP BY student_id;  
7. 查询分数大于85分的学生学号和课程号。
SELECT student_id, course_id   
FROM score   
WHERE score > 85; 
8. 查询每门课程的选课人数。
SELECT course_id, COUNT(student_id) AS student_count   
FROM score   
GROUP BY course_id;  
9. 查询选修了"高等数学"课程的学生姓名和分数。
SELECT s.name, sc.score   
FROM student s  
JOIN score sc ON s.student_id = sc.student_id   
WHERE sc.course_id = (SELECT course_id FROM course WHERE course_name = '高等数学');  
10. 查询没有选修"大学物理"课程的学生姓名。
SELECT name   
FROM student   
WHERE student_id NOT IN (SELECT student_id FROM score WHERE course_id = (SELECT course_id FROM course WHERE course_name = '大学物理'));  
11. 查询C001比C002课程成绩高的学生信息及课程分数。
SELECT s.student_id, s.name, sc1.score AS C001_score, sc2.score AS C002_score   
FROM student s  
JOIN score sc1 ON s.student_id = sc1.student_id AND sc1.course_id = 'C001'  
JOIN score sc2 ON s.student_id = sc2.student_id AND sc2.course_id = 'C002'  
WHERE sc1.score > sc2.score;  
12. 统计各科成绩各分数段人数：课程编号，课程名称，[100-85]，[85-70]，[70-60]，[60-0] 及所占百分比
WITH ranked_scores AS (  
    SELECT   
        c.course_id,  
        c.course_name,  
        s.student_id,  
        s.score,  
        DENSE_RANK() OVER (PARTITION BY c.course_id ORDER BY s.score DESC) AS score_rank  
    FROM course c  
    LEFT JOIN score s ON c.course_id = s.course_id  
),  
aggregated_scores AS (  
    SELECT  
        course_id,  
        course_name,  
        SUM(CASE WHEN score BETWEEN 85 AND 100 THEN 1 ELSE 0 END) AS `100-85`,  
        SUM(CASE WHEN score BETWEEN 70 AND 85 THEN 1 ELSE 0 END) AS `85-70`,  
        SUM(CASE WHEN score BETWEEN 60 AND 70 THEN 1 ELSE 0 END) AS `70-60`,  
        SUM(CASE WHEN score < 60 THEN 1 ELSE 0 END) AS `60-0`,  
        ROUND((SUM(CASE WHEN score BETWEEN 85 AND 100 THEN 1 ELSE 0 END) / COUNT(student_id) * 100), 2) AS percent_100_85,  
        ROUND((SUM(CASE WHEN score BETWEEN 70 AND 85 THEN 1 ELSE 0 END) / COUNT(student_id) * 100), 2) AS percent_85_70,  
        ROUND((SUM(CASE WHEN score BETWEEN 60 AND 70 THEN 1 ELSE 0 END) / COUNT(student_id) * 100), 2) AS percent_70_60,  
        ROUND((SUM(CASE WHEN score < 60 THEN 1 ELSE 0 END) / COUNT(student_id) * 100), 2) AS percent_60_0   
    FROM ranked_scores  
    GROUP BY course_id, course_name  
)  
SELECT   
    ag.course_id,  
    ag.course_name,  
    ag.`100-85`,  
    ag.`85-70`,  
    ag.`70-60`,  
    ag.`60-0`,  
    ag.percent_100_85,
    ag.percent_85_70,
    ag.percent_70_60,
    ag.percent_60_0
FROM aggregated_scores ag;  
13. 查询选择C002课程但没选择C004课程的成绩情况(不存在时显示为 null )。
WITH ranked_scores AS (  
    SELECT   
        c.course_id,  
        c.course_name,  
        s.student_id,  
        s.score,  
        DENSE_RANK() OVER (PARTITION BY c.course_id ORDER BY s.score DESC) AS score_rank  
    FROM course c  
    LEFT JOIN score s ON c.course_id = s.course_id  
),  
aggregated_scores AS (  
    SELECT  
        course_id,  
        course_name,  
        SUM(CASE WHEN score BETWEEN 85 AND 100 THEN 1 ELSE 0 END) AS `100-85`,  
        SUM(CASE WHEN score BETWEEN 70 AND 85 THEN 1 ELSE 0 END) AS `85-70`,  
        SUM(CASE WHEN score BETWEEN 60 AND 70 THEN 1 ELSE 0 END) AS `70-60`,  
        SUM(CASE WHEN score < 60 THEN 1 ELSE 0 END) AS `60-0`,  
        ROUND((SUM(CASE WHEN score BETWEEN 85 AND 100 THEN 1 ELSE 0 END) / COUNT(student_id) * 100), 2) AS percent_100_85,  
        ROUND((SUM(CASE WHEN score BETWEEN 70 AND 85 THEN 1 ELSE 0 END) / COUNT(student_id) * 100), 2) AS percent_85_70,  
        ROUND((SUM(CASE WHEN score BETWEEN 60 AND 70 THEN 1 ELSE 0 END) / COUNT(student_id) * 100), 2) AS percent_70_60,  
        ROUND((SUM(CASE WHEN score < 60 THEN 1 ELSE 0 END) / COUNT(student_id) * 100), 2) AS percent_60_0   
    FROM ranked_scores  
    GROUP BY course_id, course_name  
)  
SELECT r.student_id, r.score  
FROM ranked_scores r  
WHERE r.course_id = 'C002'  
AND r.student_id NOT IN (SELECT student_id FROM score WHERE course_id = 'C004');
14. 查询平均分数最高的学生姓名和平均分数。
WITH average_scores AS (  
    SELECT s.student_id, s.name AS student_name, AVG(sc.score) AS avg_score  
    FROM student s  
    JOIN score sc ON s.student_id = sc.student_id  
    GROUP BY s.student_id, s.name  
)  
SELECT student_name, avg_score  
FROM average_scores  
ORDER BY avg_score DESC  
LIMIT 1;  
15. 查询总分最高的前三名学生的姓名和总分。
WITH total_scores AS (  
    SELECT s.student_id, s.name AS student_name, SUM(sc.score) AS total_score  
    FROM student s  
    JOIN score sc ON s.student_id = sc.student_id  
    GROUP BY s.student_id, s.name  
)  
SELECT student_name, total_score  
FROM total_scores  
ORDER BY total_score DESC  
LIMIT 3;
16. 查询各科成绩最高分、最低分和平均分。要求如下：
以如下形式显示：课程 ID，课程 name，最高分，最低分，平均分，及格率，中等率，优良率，优秀率
及格为>=60，中等为：70-80，优良为：80-90，优秀为：>=90
要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列
WITH course_stats AS (  
    SELECT   
        c.course_id,   
        c.course_name,   
        MAX(sc.score) AS max_score,   
        MIN(sc.score) AS min_score,   
        AVG(sc.score) AS avg_score,  
        ROUND(SUM(CASE WHEN sc.score >= 60 THEN 1 ELSE 0 END) / COUNT(sc.student_id) * 100, 2) AS pass_rate,  
        ROUND(SUM(CASE WHEN sc.score BETWEEN 70 AND 80 THEN 1 ELSE 0 END) / COUNT(sc.student_id) * 100, 2) AS moderate_rate,  
        ROUND(SUM(CASE WHEN sc.score BETWEEN 80 AND 90 THEN 1 ELSE 0 END) / COUNT(sc.student_id) * 100, 2) AS good_rate,  
        ROUND(SUM(CASE WHEN sc.score >= 90 THEN 1 ELSE 0 END) / COUNT(sc.student_id) * 100, 2) AS excellent_rate,  
        COUNT(sc.student_id) AS student_count  
    FROM course c  
    LEFT JOIN score sc ON c.course_id = sc.course_id  
    GROUP BY c.course_id, c.course_name  
)  
SELECT course_id, course_name, max_score, min_score, avg_score, pass_rate, moderate_rate, good_rate, excellent_rate, student_count  
FROM course_stats  
ORDER BY student_count DESC, course_id ASC;
17. 查询男生和女生的人数。
SELECT   
    SUM(CASE WHEN gender = '男' THEN 1 ELSE 0 END) AS male_count,  
    SUM(CASE WHEN gender = '女' THEN 1 ELSE 0 END) AS female_count  
FROM student;
18. 查询年龄最大的学生姓名。
SELECT name AS student_name  
FROM student  
ORDER BY birth_date ASC  
LIMIT 1;
19. 查询年龄最小的教师姓名。
SELECT name AS teacher_name  
FROM teacher  
ORDER BY birth_date ASC  
LIMIT 1;
20. 查询学过「张教授」授课的同学的信息。
SELECT DISTINCT s.*  
FROM student s  
JOIN score sc ON s.student_id = sc.student_id  
JOIN course c ON sc.course_id = c.course_id  
JOIN teacher t ON c.teacher_id = t.teacher_id  
WHERE t.name = '张教授';
21. 查询查询至少有一门课与学号为"2021001"的同学所学相同的同学的信息 。
SELECT DISTINCT s.*  
FROM student s  
WHERE s.student_id IN (  
    SELECT sc.student_id  
    FROM score sc  
    WHERE sc.course_id IN (  
        SELECT course_id   
        FROM score   
        WHERE student_id = '2021001'  
    )  
);
22. 查询每门课程的平均分数，并按平均分数降序排列。
SELECT c.course_id, c.course_name, AVG(sc.score) AS average_score  
FROM course c  
JOIN score sc ON c.course_id = sc.course_id  
GROUP BY c.course_id, c.course_name  
ORDER BY average_score DESC;
23. 查询学号为"2021001"的学生所有课程的分数。
SELECT course_id, score   
FROM score   
WHERE student_id = '2021001';
24. 查询所有学生的姓名、选修的课程名称和分数。
SELECT s.name AS student_name, c.course_name, sc.score   
FROM student s  
JOIN score sc ON s.student_id = sc.student_id  
JOIN course c ON sc.course_id = c.course_id;
25. 查询每个教师所教授课程的平均分数。
SELECT t.name AS teacher_name, AVG(sc.score) AS average_score  
FROM teacher t  
JOIN course c ON t.teacher_id = c.teacher_id  
JOIN score sc ON c.course_id = sc.course_id  
GROUP BY t.name;
26. 查询分数在80到90之间的学生姓名和课程名称。
SELECT s.name AS student_name, c.course_name   
FROM student s  
JOIN score sc ON s.student_id = sc.student_id  
JOIN course c ON sc.course_id = c.course_id  
WHERE sc.score BETWEEN 80 AND 90;
27. 查询每个班级的平均分数。
SELECT my_class, AVG(sc.score) AS average_score  
FROM student s  
JOIN score sc ON s.student_id = sc.student_id  
GROUP BY my_class;
28. 查询没学过"王讲师"老师讲授的任一门课程的学生姓名。
SELECT s.name AS student_name  
FROM student s  
WHERE s.student_id NOT IN (  
    SELECT DISTINCT sc.student_id  
    FROM score sc  
    JOIN course c ON sc.course_id = c.course_id  
    JOIN teacher t ON c.teacher_id = t.teacher_id  
    WHERE t.name = '王讲师'  
);
29. 查询两门及其以上小于85分的同学的学号，姓名及其平均成绩 。
SELECT s.student_id, s.name AS student_name, AVG(sc.score) AS average_score  
FROM student s  
JOIN score sc ON s.student_id = sc.student_id  
WHERE sc.score < 85  
GROUP BY s.student_id, s.name  
HAVING COUNT(sc.course_id) >= 2;
30. 查询所有学生的总分并按降序排列。
SELECT s.student_id
31. 查询平均分数超过85分的课程名称。
SELECT c.course_name  
FROM course c  
JOIN score sc ON c.course_id = sc.course_id  
GROUP BY c.course_name  
HAVING AVG(sc.score) > 85;  
32. 查询每个学生的平均成绩排名。
WITH average_scores AS (  
    SELECT s.student_id, s.name AS student_name, AVG(sc.score) AS avg_score  
    FROM student s  
    JOIN score sc ON s.student_id = sc.student_id  
    GROUP BY s.student_id, s.name  
)  
SELECT student_name, avg_score, RANK() OVER (ORDER BY avg_score DESC) AS rank  
FROM average_scores;
33. 查询每门课程分数最高的学生姓名和分数。
WITH max_scores AS (  
    SELECT course_id, MAX(score) AS max_score  
    FROM score  
    GROUP BY course_id  
)  
SELECT s.name AS student_name, c.course_name, ms.max_score  
FROM max_scores ms  
JOIN score sc ON ms.course_id = sc.course_id AND ms.max_score = sc.score  
JOIN student s ON sc.student_id = s.student_id  
JOIN course c ON sc.course_id = c.course_id;
34. 查询选修了"高等数学"和"大学物理"的学生姓名。
SELECT s.name AS student_name  
FROM student s  
JOIN score sc ON s.student_id = sc.student_id  
WHERE sc.course_id IN (  
    SELECT c.course_id  
    FROM course c  
    WHERE c.course_name IN ('高等数学', '大学物理')  
)  
GROUP BY s.student_id  
HAVING COUNT(DISTINCT sc.course_id) = 2;
35. 按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩（没有选课则为空）。
WITH student_scores AS (  
    SELECT s.student_id, s.name AS student_name, c.course_name, sc.score  
    FROM student s  
    LEFT JOIN score sc ON s.student_id = sc.student_id  
    LEFT JOIN course c ON sc.course_id = c.course_id  
),  
average_scores AS (  
    SELECT student_id, AVG(score) AS avg_score  
    FROM student_scores  
    WHERE score IS NOT NULL  
    GROUP BY student_id  
)  
SELECT ss.student_name, ss.course_name, ss.score, as.avg_score  
FROM student_scores ss  
LEFT JOIN average_scores as ON ss.student_id = as.student_id  
ORDER BY as.avg_score DESC;
36. 查询分数最高和最低的学生姓名及其分数。
WITH high_low_scores AS (  
    SELECT s.name AS student_name, sc.score,  
           RANK() OVER (ORDER BY sc.score DESC) AS rank_desc,  
           RANK() OVER (ORDER BY sc.score ASC) AS rank_asc  
    FROM student s  
    JOIN score sc ON s.student_id = sc.student_id  
)  
SELECT student_name, score  
FROM high_low_scores  
WHERE rank_desc = 1 OR rank_asc = 1;
37. 查询每个班级的最高分和最低分。
SELECT s.my_class, MAX(sc.score) AS max_score, MIN(sc.score) AS min_score  
FROM student s  
JOIN score sc ON s.student_id = sc.student_id  
GROUP BY s.my_class;
38. 查询每门课程的优秀率（优秀为90分）。
SELECT c.course_name,   
       ROUND(SUM(CASE WHEN sc.score >= 90 THEN 1 ELSE 0 END) * 100.0 / COUNT(sc.student_id), 2) AS excellence_rate  
FROM course c  
LEFT JOIN score sc ON c.course_id = sc.course_id  
GROUP BY c.course_name;
39. 查询平均分数超过班级平均分数的学生。
WITH class_average AS (  
    SELECT s.my_class, AVG(sc.score) AS avg_score  
    FROM student s  
    JOIN score sc ON s.student_id = sc.student_id  
    GROUP BY s.my_class  
)  
SELECT s.name AS student_name  
FROM student s  
JOIN score sc ON s.student_id = sc.student_id  
JOIN class_average ca ON s.my_class = ca.my_class  
GROUP BY s.student_id, s.name  
HAVING AVG(sc.score) > ca.avg_score;
40. 查询每个学生的分数及其与课程平均分的差值。
WITH course_avg AS (  
    SELECT course_id, AVG(score) AS avg_score  
    FROM score  
    GROUP BY course_id  
)  
SELECT s.student_id, s.name AS student_name, sc.course_id, sc.score,   
       (sc.score - ca.avg_score) AS score_difference  
FROM student s  
JOIN score sc ON s.student_id = sc.student_id  
JOIN course_avg ca ON sc.course_id = ca.course_id;