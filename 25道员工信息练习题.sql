1. 查询所有员工的姓名、邮箱和工作岗位。
SELECT first_name, last_name, email, job_title FROM employees;
2. 查询所有部门的名称和位置。
SELECT dept_name, location FROM departments;
3. 查询工资超过70000的员工姓名和工资。
SELECT first_name, last_name, salary FROM employees WHERE salary > 70000;
4. 查询IT部门的所有员工。
SELECT first_name, last_name FROM employees WHERE dept_id = (SELECT dept_id FROM departments WHERE dept_name = 'IT');
5. 查询入职日期在2020年之后的员工信息。
SELECT * FROM employees WHERE hire_date > '2020-01-01';
6. 计算每个部门的平均工资。
SELECT d.dept_name, AVG(e.salary) AS average_salary  
FROM departments d  
LEFT JOIN employees e ON d.dept_id = e.dept_id  
GROUP BY d.dept_name;
7. 查询工资最高的前3名员工信息。
SELECT * FROM employees ORDER BY salary DESC LIMIT 3;
8. 查询每个部门员工数量。
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count  
FROM departments d  
LEFT JOIN employees e ON d.dept_id = e.dept_id  
GROUP BY d.dept_name;
9. 查询没有分配部门的员工。
SELECT * FROM employees WHERE dept_id IS NULL;
10. 查询参与项目数量最多的员工。
SELECT emp_id, COUNT(project_id) AS project_count  
FROM employee_projects  
GROUP BY emp_id  
ORDER BY project_count DESC  
LIMIT 1;
11. 计算所有员工的工资总和。
SELECT SUM(salary) AS total_salary FROM employees;
12. 查询姓"Smith"的员工信息。
SELECT * FROM employees WHERE last_name = 'Smith';
13. 查询即将在半年内到期的项目。
SELECT * FROM projects WHERE end_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 6 MONTH);
14. 查询至少参与了两个项目的员工。
SELECT emp_id  
FROM employee_projects  
GROUP BY emp_id  
HAVING COUNT(project_id) >= 2;
15. 查询没有参与任何项目的员工。
SELECT * FROM employees WHERE emp_id NOT IN (SELECT emp_id FROM employee_projects);
16. 计算每个项目参与的员工数量。
SELECT p.project_name, COUNT(ep.emp_id) AS employee_count  
FROM projects p  
LEFT JOIN employee_projects ep ON p.project_id = ep.project_id  
GROUP BY p.project_name;
17. 查询工资第二高的员工信息。
SELECT * FROM employees  
WHERE salary = (SELECT DISTINCT salary FROM employees ORDER BY salary DESC LIMIT 1 OFFSET 1);
18. 查询每个部门工资最高的员工。
SELECT e.*  
FROM employees e  
JOIN (  
    SELECT dept_id, MAX(salary) AS max_salary  
    FROM employees  
    GROUP BY dept_id  
) AS max_dept_salaries  
ON e.dept_id = max_dept_salaries.dept_id AND e.salary = max_dept_salaries.max_salary;
19. 计算每个部门的工资总和,并按照工资总和降序排列。
SELECT d.dept_name, SUM(e.salary) AS total_salary  
FROM departments d  
LEFT JOIN employees e ON d.dept_id = e.dept_id  
GROUP BY d.dept_name  
ORDER BY total_salary DESC;
20. 查询员工姓名、部门名称和工资。
SELECT e.first_name, e.last_name, d.dept_name, e.salary  
FROM employees e  
JOIN departments d ON e.dept_id = d.dept_id;
21. 查询每个员工的上级主管(假设emp_id小的是上级)。
SELECT e1.first_name AS employee_name, e2.first_name AS manager_name  
FROM employees e1  
LEFT JOIN employees e2 ON e1.dept_id = e2.dept_id AND e1.emp_id != e2.emp_id  
WHERE e2.emp_id < e1.emp_id;
22. 查询所有员工的工作岗位,不要重复。
SELECT DISTINCT job_title FROM employees;
23. 查询平均工资最高的部门。
SELECT d.dept_name  
FROM departments d  
JOIN employees e ON d.dept_id = e.dept_id  
GROUP BY d.dept_name  
ORDER BY AVG(e.salary) DESC  
LIMIT 1;
24. 查询工资高于其所在部门平均工资的员工。
SELECT e.*  
FROM employees e  
JOIN (  
    SELECT dept_id, AVG(salary) AS avg_salary  
    FROM employees  
    GROUP BY dept_id  
) AS avg_salaries ON e.dept_id = avg_salaries.dept_id  
WHERE e.salary > avg_salaries.avg_salary;
25. 查询每个部门工资前两名的员工。
with ranked_employees as (  
    select e.*, d.dept_name,  
           rank() over (partition by e.dept_id order by e.salary desc) as salary_rank  
    from employees e  
    join departments d on e.dept_id = d.dept_id  
)  
select *  
from ranked_employees  
where salary_rank <= 2;