USE schooldatabase;

/*2. LISTS NUMBER OF COURSES OF EACH DEPARTMENT*/
select d.name, count(c.id) as numCourses from course c join department d 
on c.deptid = d.id
group by d.name
order by numCourses asc;

/*3. LIST COURSE AND NUMBER OF STUDENTS IN THAT COURSE*/
select c.name, count(s.studentid) as numStudents from studentCourse s 
join course c on s.courseid = c.id 
group by c.name
order by numStudents desc, c.name asc;

/*4. LIST COURSES WITHOUT FACULTY*/
select c.name from facultyCourse f right join course c
on f.courseid = c.id where f.facultyid is null
order by c.name asc;

/*5. LIST # OF STUDENTS IN COURSES WITHOUT FACULTY*/
select c.name, count(s.studentid) as numStudents from studentCourse s 
join course c on s.courseid = c.id
left join facultyCourse f on c.id = f.courseid
where f.facultyid is null
group by c.name
order by numStudents desc, c.name asc; 

/*6. LIST TOTAL # OF STUDENTS ENROLLED EACH YEAR*/
select count(distinct(s.id)) as Students, date_format(sc.startDate, '%Y') as Year 
from studentCourse sc join student s
on sc.studentid = s.id
group by Year
order by Year asc, Students desc;

/*7. LIST START DATE AND # OF STUDENTS ENROLLED IN AUGUST OF EACH YEAR.*/
select  sc.startDate, count(distinct(s.id)) as Students 
from studentCourse sc join student s
on sc.studentid = s.id
where date_format(sc.startDate, '%m') = "08"
group by sc.startDate
order by sc.startDate asc, Students desc;

/*8. LIST STUDENTS NAME AND # OF COURSES IN THEIR MAJOR.*/
select s.firstname, s.lastname, count(c.id) as numCourse from studentCourse sc
join student s on s.id = sc.studentid 
join course c on sc.courseid = c.id
where s.majorid = c.deptid
group by s.firstname, s.lastname
order by numCourse desc, s.firstname asc, s.lastname asc;

/*9. LIST NAME AND AVERAGE OF STUDENTS WITH LESS THAN 50%.*/
select s.firstname, s.lastname, round(avg(sc.progress), 1) as avgProgress 
from student s
join studentCourse sc on s.id = sc.studentid
group by s.firstname, s.lastname
having avgProgress < 50
order by avgProgress desc, firstname asc, lastname asc;

/*10. LIST COURSE NAME AND STUDENTS AVERAGE.*/
select c.name, round(avg(sc.progress), 1) as avgProgress from studentCourse sc join course c on sc.courseid = c.id
group by c.name
order by avgProgress desc, c.name asc;

/*11. COURSE WITH THE HIGHEST AVERAGE PROGRESS*/
select c.name, round(avg(sc.progress), 1) as avgProgress from studentCourse sc join course c on sc.courseid = c.id
group by c.name
order by avgProgress desc
limit 1;

/*12. LIST FACULTY NAME AND THE AVERAGE PROGRESS OF THEIR ALL THEIR COURSES*/
select f.firstname, f.lastname, round(avg(sc.progress), 1) as avgProgress
from facultyCourse fc 
join faculty f on fc.facultyid = f.id 
join course c on fc.courseid = c.id
join studentCourse sc on sc.courseid = c.id
where f.deptid = c.deptid 
group by f.firstname, f.lastname
order by avgProgress desc, f.firstname asc, f.lastname asc;

/*13. LIST FACULTY AVERAGE IF >90% OF MAX COURSE AVERAGE*/
select f.firstname, f.lastname, round(avg(sc.progress), 1) as avgProgess from facultyCourse fc 
join faculty f on fc.facultyid = f.id
join course c on fc.courseid = c.id
join studentCourse sc on c.id = sc.courseid
group by f.id
having avgProgess > 0.9 * (
	select avg(sc.progress) as avgP from studentCourse sc join course c
    on sc.courseid = c.id
    group by sc.courseid
    order by avgP desc
    limit 1)
order by avgProgess desc, f.firstname asc, f.lastname asc;

/*14. MINIMUM & MAXIMUM GRADE*/
select s.firstname, s.lastname,
case
    when min(sc.progress) < 40 then "F"
    when min(sc.progress) < 50 then "D"
    when min(sc.progress) < 60 then "C"
    when min(sc.progress) < 70 then "B"
    when min(sc.progress) >= 70 then "A"
end as minGrade,
case
    when max(sc.progress) < 40 then "F"
    when max(sc.progress) < 50 then "D"
    when max(sc.progress) < 60 then "C"
    when max(sc.progress) < 70 then "B"
    when max(sc.progress) >= 70 then "A"
end as maxGrade from studentCourse sc
join student s on sc.studentid = s.id
group by s.id
order by minGrade desc, maxGrade desc, s.firstname asc, s.lastname asc;


