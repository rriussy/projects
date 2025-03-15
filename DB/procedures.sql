use mmf2025;
set SQL_SAFE_UPDATES = 0;
set global log_bin_trust_function_creators = 1;

# 4.1 - raise scholarship for everyone ---------------------------------------------------------------------------------------------------------------------------
drop procedure if exists raise_scholarship;
delimiter //
create procedure raise_scholarship(IN percent INT)
begin
	update studs
    set scholarship = scholarship*(1+0.01*percent);
end//
delimiter ;


# 4.2 - avg mark from certain teacher on exams ---------------------------------------------------------------------------------------------------------------------------
drop function if exists avg_mark_from_teacher;
delimiter //
create function avg_mark_from_teacher(in_teacher varchar(20))
returns float
begin
	declare avg_mark float;
    select AVG(exam_results.mark) into avg_mark
    from exam_results join exams on exam_results.exam_id = exams.id 
    left join subjects on exams.subj_id = subjects.id
    where subjects.teacher = in_teacher;
    
    return avg_mark;
end//
delimiter ;

# 4.3 bonus for active studs ---------------------------------------------------------------------------------------------------------------------------
drop procedure if exists give_bonus_to_active;
delimiter //
create procedure give_bonus_to_active(in bonus float)
begin
	update studs
    set scholarship = scholarship+bonus
    where activity_hours > 20;
    
end//
delimiter ;


# 4.4 top 5 best, worst, activiest ---------------------------------------------------------------------------------------------------------------------------
drop procedure if exists top5best;
delimiter //
create procedure top5best()
begin
	
	declare id int;
    declare avg_mark float;
    declare is_end int default 0;
	declare cur cursor for 
		select lessons.st_id as id, AVG(mark) AS avg_mark
		from lessons
		group by lessons.st_id
		order by avg_mark desc
		limit 5;
	declare continue handler for not found set is_end = 1;
    
	open cur;
    curs : loop
		fetch cur into id, avg_mark;
        if is_end then leave curs; end if;
        
        insert into bestStuds
        (bestStuds.st_id, bestStuds.avg_mark)
        values
        (id,avg_mark);
	end loop curs;
    close cur;
end//
delimiter ;


drop procedure if exists top5worst;
delimiter //
create procedure top5worst()
begin
	declare id int;
    declare avg_mark float;
    declare is_end int default 0;
	declare cur cursor for 
		select lessons.st_id as id, AVG(mark) AS avg_mark
		from lessons
		group by lessons.st_id
		order by avg_mark asc
		limit 5;
	declare continue handler for not found set is_end = 1;
    
	open cur;
    curs : loop
		fetch cur into id, avg_mark;
        if is_end then leave curs; end if;
        
        insert into worstStuds
        (worstStuds.st_id, worstStuds.avg_mark)
        values
        (id,avg_mark);
	end loop curs;
    close cur;
end//
delimiter ;

drop procedure if exists top5active;
delimiter //
create procedure top5active()
begin
	declare id int;
    declare act_hours float;
    
    declare is_end int default 0;
	declare cur cursor for 
		select studs.id, studs.activity_hours
		from studs
        where studs.id is not null
		order by studs.activity_hours desc
		limit 5
        ;
	declare continue handler for not found set is_end = 1;
    
	open cur;
    curs : loop
		fetch cur into id, act_hours;
        if is_end then leave curs; end if;
        
        insert into activeStuds
        (activeStuds.st_id, activeStuds.activity_hours)
        values
        (id,act_hours);
	end loop curs;
    close cur;
end//
delimiter ;

# 4.5 expel problematic studs ----------------------------------------------------------------------------------------------------------------------------
drop procedure if exists expel_stupid;
delimiter //
create procedure expel_stupid()
begin
	declare id int;
    
    declare is_end int default 0;
	declare cur cursor for 
		select st_id from (select exam_results.st_id as st_id, count(*) as cnt
		from exam_results 
		left join exams on exam_results.exam_id = exams.id
		left join subjects on subjects.id = exams.subj_id
		where exam_results.mark <4
		group by exam_results.st_id) as t
		where t.cnt >2
        ;
	declare continue handler for not found set is_end = 1;
    
	open cur;
    curs : loop
		fetch cur into id;
		if is_end then leave curs; end if;
        
        delete from studs where studs.id = id;
	
	end loop curs;
    close cur;
end//
delimiter ;

# 4.6 find most common mark in group (on lessons) ---------------------------------------------------------------------------------------------------------------------------
drop function if exists find_common_mark;
delimiter //
create function find_common_mark(groupN INT)
returns INT
begin
	declare com_mark INT default 0;
    
    select t.mark into com_mark
    from(
    select mark, count(*) over(partition by mark) as popularity 
    from lessons
	left join subjects on lessons.subj_id = subjects.id
	left join st_groups on subjects.group_id = st_groups.id
	where st_groups.id =groupN and lessons.mark is not null
	order by popularity desc
    limit 1) as t;

	return com_mark;
end//
delimiter ;

# 4.7 find skipped lessons percent in one group ---------------------------------------------------------------------------------------------------------------------------
drop procedure if exists skipped_lessons_percent;
delimiter //
create procedure skipped_lessons_percent(IN groupN INT)
begin
	declare all_lessons INT default 0;
    
    select max(t.cnt) into all_lessons from
	(select count(*) as cnt from lessons
	left join studs on studs.id = lessons.st_id
	where studs.group_id = groupN
	group by studs.id) as t;
    
    select studs.id, ifnull(t.skipped/all_lessons,0) as skipped_lessons from
	studs left join
	(select studs.id, count(*) as skipped
	from lessons
	left join studs on studs.id = lessons.st_id
	where studs.group_id = groupN and not lessons.attended 
	group by studs.id) as t
	on studs.id = t.id
	where studs.group_id = groupN;


end//
delimiter ;

# 4.11 predict mark ---------------------------------------------------------------------------------------------------------------------------
drop function if exists predict_mark;
delimiter //
create function predict_mark(stud_id INT, subj_id INT)
returns int
begin
	declare res int;
	select 
	if((select AVG(mark)
	from lessons where lessons.st_id = stud_id and lessons.subj_id = subj_id) is null, # no marks
	 4,
	 (select round(AVG(mark))
	from lessons  where lessons.st_id = stud_id and lessons.subj_id = subj_id))
    into res;

	return res;
end//
delimiter ;

# 4.8 is teacher unfair ---------------------------------------------------------------------------------------------------------------------------
drop function if exists is_teacher_fair;
delimiter //
create function is_teacher_fair(teacher varchar(20))
returns bool
begin
	declare res bool default false;
    declare subject_id int;
    declare group_id int;
    declare ratio float;
    
    select subjects.id into subject_id from subjects
	where subjects.teacher = teacher
	limit 1;
    select subjects.group_id into group_id from subjects where subjects.id = subject_id;
    
    
    select sum(d.diff)/count(diff) into ratio from 
	(
	select s.id, abs(predict_mark(s.id,subject_id) - ex.mark) as diff
	from 
	(select * from studs where group_id = group_id) as s
	left join
	(select st_id, mark from exam_results
	left join exams on exams.id = exam_results.exam_id
	where exams.subj_id = subject_id
	) as ex
	on  s.id = ex.st_id
	) as d
	;

	select if(ratio>2.5, 0, 1) into res;
	return res;
end//
delimiter ; 

# 4.9 give bonus to studs who were born between date1 date2 -----------	----------------------------------------------------------------------------------------------------------------
drop procedure if exists give_birth_bonus;
delimiter //
create procedure give_birth_bonus(IN date1 DATETIME, IN date2 DATETIME)
begin

	update studs
    set studs.scholarship = studs.scholarship+0.1*datediff(studs.birthday,date1)
	where studs.birthday between date1 and date2 and studs.scholarship is not null;
    
	update studs
    set studs.fee = studs.fee-0.1*datediff(studs.birthday,date1)
	where studs.birthday between date1 and date2 and studs.fee is not null;

end//
delimiter ;

# 4.12 create timetable ---------------------------------------------------------------------------------------------------------------------------
drop procedure if exists show_timetable;
delimiter //
create procedure show_timetable(IN groupN INT)
begin
	if groupN >0
    then
		select distinct lessons.start_time, subjects.subj_name, subjects.teacher
		from lessons
		left join subjects on lessons.subj_id = subjects.id
        where subjects.group_id = groupN
		order by lessons.start_time
        ;
	else
		select distinct subjects.group_id, lessons.start_time, subjects.subj_name, subjects.teacher
		from lessons
		left join subjects on lessons.subj_id = subjects.id
		order by lessons.start_time;
	end if;

end//
delimiter ;