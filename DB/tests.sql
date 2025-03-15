use mmf2025;
GRANT ALL PRIVILEGES ON mmf2025.* TO 'root'@'localhost' IDENTIFIED BY 'haha';
select * from exams;
select * from studs;
select * from test;
select * from bestStuds;
select * from temp;
truncate bestStuds;
call top5best();
call skipped_lessons_percent(1);

select * from information_schema.columns where table_schema = 'mmf2025' and table_name = 'studs';

create table temp(
id INT PRIMARY KEY AUTO_INCREMENT,
st_name VARCHAR(20),
st_surname VARCHAR(20),
birthday DATETIME,
group_id INT,
form ENUM('paid','budget'),
scholarship FLOAT,
fee FLOAT,
health ENUM("healthy","normal","invalid","hardly alive"),
activity_hours INTEGER,
problematicQ bool default false
);


select find_common_mark(1);

update st_groups 
set semester = 2
where id = 1;

select * from studs where group_id = 1;
select * from exam_results where st_id = 4;

update exam_results set mark = 3 where exam_id = 3 and st_id = 4;
insert into exam_results (exam_id, st_id, mark)
values (7,4,7);
# event for lessons generation 
insert into lessons(subj_id, st_id)
values 
(1,2);
select * from subjects;

# 4.1
call raise_scholarship(10);
select * from studs;

# 4.2
select avg_mark_from_teacher("Kushnerov");
select * from exam_results where exam_id = 2 or exam_id = 3;

# 4.3
select * from studs;
call give_bonus_to_active(15);

# 4.4 
call top5best();
select * from bestStuds;

call top5worst();
select * from worstStuds;

call top5active();
select * from activeStuds;

select * from studs;

# 4.5
call expel_stupid();
select * from studs;

# 4.6
select find_common_mark(1);


    select subjects.id from subjects
	where subjects.teacher = teacher
	limit 1;
     select subjects.group_id from subjects where subjects.id = 1;
     
     select st_id,mark from exam_results
     left join exams on exams.id =exam_results.exam_id
     where exams.subj_id = 1;
     
     
# 4.7
call skipped_lessons_percent(1);

# 4.8
select is_teacher_fair("Kushnerov");

# 4.9
call give_birth_bonus("2005-02-01","2005-10-01");
select * from studs;

# 4.11
select id,predict_mark(id,1), t.mark 
from studs
left join  (select st_id,mark from exam_results
     left join exams on exams.id =exam_results.exam_id
     where exams.subj_id = 1) as t
     on t.st_id = studs.id
     ;

# 4.12
call show_timetable(2);

# cant retry exams if you passed, havent tried
select * from exam_results;
select * from exams;
insert into exam_results
(exam_id, st_id, mark)
values
(6,2,6);

# check if student is from the corresponding group on exams
select * from studs;
select * from exam_results;

insert into exam_results
(exam_id,st_id,mark)
values
(1,1,9);

# no exams on the same day
SELECT * FROM exams;
UPDATE exams 
SET exam_date = "2024-01-09 14:00:00"
WHERE id = 1;

#  no disabled in our university
select * from st_groups;
update st_groups set semester = 2 where id = 1;

select * from studs where group_id = 4;

# health log
select * from studs;
update studs set health = "normal" where id =1;
select * from health_log;

# cant have exams without passing small exams
insert into exams (subj_id, exam_date, exam_type)
values
("1","2024-12-01","small");

select * from exam_results;
delete from exam_results where exam_id = 2 and st_id = 2;

insert into exam_results (exam_id, st_id, mark) values (2,2,4);

select studs.id, exam_results.mark
		from studs 
		left join subjects on subjects.group_id = studs.group_id
		left join exams on subjects.id = exams.subj_id
		left join exam_results on exams.id = exam_results.exam_id
		where exams.exam_type = "small" and (exam_results.mark <4 or exam_results.mark is null);
        
# mark problematic
insert into lessons (start_time,subj_id,st_id,attended, mark)
values
(now(),1,2,1,9)
;
select * from studs;

select t.id from(
	select st_id as id, avg(attended) as attendance, avg(mark) as avg_mark from lessons
	group by st_id) as t
	where t.attendance < 0.4 or t.avg_mark < 4;