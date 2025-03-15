use mmf2025;
set SQL_SAFE_UPDATES = 0;
# ---------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------------  studs ----------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------

# 5.1 set fee & scholarship ---------------------------------------------------------------------------------------------------------
drop trigger if exists stud_check_ins;
DELIMITER //
CREATE TRIGGER stud_check_ins BEFORE INSERT ON studs
FOR EACH ROW
BEGIN	
	CASE NEW.form
		WHEN 'budget' THEN
			SET NEW.scholarship = 100;
		WHEN 'paid' THEN
			SET NEW.fee = 200;
	END CASE;
END//
DELIMITER ;

# ---------------------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------------------  exam_results  --------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------

# check exam mark -----------------------------------------------------------------------------------------------------------------
drop trigger if exists exam_check_ins;
drop trigger if exists exam_check_upd;
DELIMITER //
CREATE TRIGGER exam_check_ins BEFORE INSERT ON exam_results
FOR EACH ROW
BEGIN	
	IF NEW.mark < 0 THEN SET NEW.mark = 0;
    END IF;
    IF NEW.mark >10 THEN SET NEW.mark = 10;
    END IF;
END//

CREATE TRIGGER exam_check_upd BEFORE UPDATE ON exam_results
FOR EACH ROW
BEGIN	
	IF NEW.mark < 0 THEN SET NEW.mark = 0;
    END IF;
    IF NEW.mark >10 THEN SET NEW.mark = 10;
    END IF;
END//
DELIMITER ;


# check if inserting retry without first attempt, if the student passed this exam already -----------------------------------
drop trigger if exists check_first_attempt;
delimiter //
create trigger check_first_attempt before insert on exam_results
for each row
begin
	declare subject_id INT default 0;
    
	if (select exams.exam_type from exams where exams.id = new.exam_id) = "retry"
    then select exams.subj_id into subject_id from exams where exams.id = new.exam_id;
    end if;
    
    if subject_id <> 0
    then
		if (select exams.exam_type
			from exam_results
			left join exams on exam_results.exam_id = exams.id
			 where exams.subj_id = subject_id and exam_results.st_id = new.st_id
			 order by exams.exam_date asc
			 limit 1) <> "big" 
         or 
			 (select exam_results.mark 
			from exam_results
			left join exams on exam_results.exam_id = exams.id
			 where exams.subj_id = subject_id and exam_results.st_id = new.st_id
			 order by exams.exam_date desc
			 limit 1) >3
		then signal sqlstate VALUE '45000' SET MESSAGE_TEXT = "Cant retry exams if the student hasnt tried yet / The student passed this exam already";
        end if;
    end if;
end//
delimiter ;

# expel stupid automatically ------------------------------------------------------------------------------------------
drop trigger expel_stupid_automatically_ins;
drop trigger expel_stupid_automatically_upd;
delimiter //
create trigger expel_stupid_automatically_ins after insert on exam_results
for each row
begin
	call expel_stupid();
end//
delimiter ;

delimiter //
create trigger expel_stupid_automatically_upd after update on exam_results
for each row
begin
	call expel_stupid();
end//
delimiter ;

# check if student is from corresponding group --------------------------------------------------------------------------
drop trigger if exists group_check_ins;
drop trigger if exists group_check_upd;
DELIMITER //
CREATE TRIGGER group_check_ins BEFORE INSERT ON exam_results
FOR EACH ROW
BEGIN	
	If (select studs.group_id from studs where studs.id = new.st_id) != (
    select subjects.group_id from exams 
    left join subjects on exams.subj_id = subjects.id
    where exams.id = new.exam_id)
    then signal sqlstate VALUE '45000' SET MESSAGE_TEXT = "this student is not from group which has this exam";
    end if;
END//
delimiter ;
DELIMITER //
CREATE TRIGGER group_check_upd BEFORE UPDATE ON exam_results
FOR EACH ROW
BEGIN	
	If (select studs.group_id from studs where studs.id = new.st_id) != (
    select subjects.group_id from exams 
    left join subjects on exams.subj_id = subjects.id
    where exams.id = new.exam_id)
    then signal sqlstate VALUE '45000' SET MESSAGE_TEXT = "this student is not from group which has this exam";
    end if;
END//
delimiter ;

# ---------------------------------------------------------------------------------------------------------------------------------
# --------------------------------------------------------------  exams  ----------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------

# no exams on one day -------------------------------------------------------------------------------------------------------------
drop trigger if exists exams_check_ins;
drop trigger if exists exams_check_upd;
DELIMITER //
CREATE TRIGGER exams_check_ins BEFORE INSERT ON exams
FOR EACH ROW
BEGIN	

IF(
	EXISTS(
		SELECT 1 
		FROM exams left join 
		subjects on exams.subj_id = subjects.id
		WHERE subjects.group_id = (SELECT group_id from subjects where subjects.id = NEW.subj_id) AND DATE(exams.exam_date)  = DATE(NEW.exam_date)
        )
)
THEN signal sqlstate VALUE '45000' SET MESSAGE_TEXT = "cant put two exams on the same day"; 
END IF;
END//

CREATE TRIGGER exams_check_upd BEFORE UPDATE ON exams
FOR EACH ROW
BEGIN	

IF(
	EXISTS(
		SELECT 1 
		FROM exams left join 
		subjects on exams.subj_id = subjects.id
		WHERE subjects.group_id = (SELECT group_id from subjects where subjects.id = NEW.subj_id) AND DATE(exams.exam_date)  = DATE(NEW.exam_date)
        )
)
THEN signal sqlstate VALUE '45000' SET MESSAGE_TEXT = "cant put two exams on the same day"; 
END IF;
END//
DELIMITER ;

# ---------------------------------------------------------------------------------------------------------------------------------
# -------------------------------------------------------------- lessons ----------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------

# check marks on lessons -------------------------------------------------- -------------------------------------------------------
drop trigger if exists mark_check_ins;
drop trigger if exists mark_check_upd;
DELIMITER //
CREATE TRIGGER mark_check_ins BEFORE INSERT ON lessons
FOR EACH ROW
BEGIN	
	if not new.attended
    then set new.mark = null;
    end if;
	IF NEW.mark < 0 THEN SET NEW.mark = 0;
    END IF;
    IF NEW.mark >10 THEN SET NEW.mark = 10;
    END IF;
END//

CREATE TRIGGER mark_check_upd BEFORE UPDATE ON lessons
FOR EACH ROW
BEGIN	
	if not new.attended
    then set new.mark = null;
    end if;
	IF NEW.mark < 0 THEN SET NEW.mark = 0;
    END IF;
    IF NEW.mark >10 THEN SET NEW.mark = 10;
    END IF;
END//
DELIMITER ;


# check if student is from corresponding group -------------------------------------------------------------------------
drop trigger if exists group_lesson_check_ins;
drop trigger if exists group_lesson_check_upd;

DELIMITER //
CREATE TRIGGER group_lesson_check_ins BEFORE INSERT ON lessons
FOR EACH ROW
BEGIN	
	If (select studs.group_id from studs where studs.id = new.st_id) != (
    select subjects.group_id from subjects 
    where subjects.id = new.subj_id)
    then signal sqlstate VALUE '45000' SET MESSAGE_TEXT = "this student is not from group which has this lesson";
    end if;
END//
delimiter ;

DELIMITER //
CREATE TRIGGER group_lesson_check_upd BEFORE UPDATE ON lessons
FOR EACH ROW
BEGIN	
	If (select studs.group_id from studs where studs.id = new.st_id) != (
    select subjects.group_id from subjects 
    where subjects.id = new.subj_id)
    then signal sqlstate VALUE '45000' SET MESSAGE_TEXT = "this student is not from group which has this lesson";
    end if;
END//
delimiter ;

# ---------------------------------------------------------------------------------------------------------------------------------
# ------------------------------------------------------------ st_groups ----------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------------------------------

# check grade in groups -----------------------------------------------------------------------------------------------
drop trigger if exists sem_check_ins;
drop trigger if exists sem_check_upd;
DELIMITER //
CREATE TRIGGER sem_check_ins BEFORE INSERT ON st_groups
FOR EACH ROW
BEGIN	
	IF NEW.semester < 1 THEN SET NEW.semester = 1;
    END IF;
    IF NEW.semester >7 THEN SET NEW.semester = null;
    END IF;
END//

CREATE TRIGGER sem_check_upd BEFORE UPDATE ON st_groups
FOR EACH ROW
BEGIN	
	IF NEW.semester < 1 THEN SET NEW.semester = 1;
    END IF;
    IF NEW.semester >7 THEN SET NEW.semester = null;
    END IF;
END//
DELIMITER ;


# set scholarship according to exam marks ---------------------------------------------------------------------------------------
drop trigger if exists set_scholarship_marks;
delimiter //
create trigger set_scholarship_marks BEFORE UPDATE ON st_groups
FOR EACH ROW
begin
	declare cur_st INT;
    declare avg_mark FLOAT;
	declare is_end int default 0;
	declare cur cursor for select studs.id from studs where studs.group_id = NEW.id;
    declare continue handler for not found set is_end = 1;

	open cur;
    l:loop
		fetch cur into cur_st;
        if is_end then leave l; end if;
        if (select studs.scholarship from studs where studs.id = cur_st) is null then iterate l; end if;
		if "retry" in(select exam_type from studs
			left join exam_results on studs.id = exam_results.st_id
			left join exams on exams.id = exam_results.exam_id
			where studs.id =cur_st)
		then
			update studs set scholarship = 0 where studs.id = cur_st;
		else 
			select AVG(mark) into avg_mark from exam_results where exam_results.st_id =cur_st;
			case 
            when 4<=avg_mark<5 then update studs set scholarship = 50 where studs.id = cur_st;
            when 5<=avg_mark<6 then update studs set scholarship = 60 where studs.id = cur_st;
            when 6<=avg_mark<7 then update studs set scholarship = 70 where studs.id = cur_st;
            when 7<=avg_mark<8 then update studs set scholarship = 80 where studs.id = cur_st;
            when 8<=avg_mark<9 then update studs set scholarship = 90 where studs.id = cur_st;
            when 9<=avg_mark<=10 then update studs set scholarship = 100 where studs.id = cur_st;
			end case;
		end if;
    end loop l;
    close cur;
end//
delimiter ;

# decrease fee according to exam marks --------------------------------------------------------------------------------------------
drop trigger if exists set_fee_marks;
delimiter //
create trigger set_fee_marks BEFORE UPDATE ON st_groups
FOR EACH ROW
begin
	declare cur_st INT;
    declare avg_mark FLOAT;
	declare is_end int default 0;
	declare cur cursor for select studs.id from studs where studs.group_id = NEW.id;
    declare continue handler for not found set is_end = 1;

	open cur;
    l:loop
		fetch cur into cur_st;
        if is_end then leave l; end if;
        if (select studs.fee from studs where studs.id = cur_st) is null then iterate l; end if;
        
		if "retry" not in(select exam_type from studs
			left join exam_results on studs.id = exam_results.st_id
			left join exams on exams.id = exam_results.exam_id
			where studs.id =cur_st)
		then
			select AVG(mark) into avg_mark from exam_results where exam_results.st_id =cur_st;
			case 
            when 4<=avg_mark<5 then update studs set fee = 500 where studs.id = cur_st;
            when 5<=avg_mark<6 then update studs set fee = 400 where studs.id = cur_st;
            when 6<=avg_mark<7 then update studs set fee = 300 where studs.id = cur_st;
            when 7<=avg_mark<8 then update studs set fee = 200 where studs.id = cur_st;
            when 8<=avg_mark<9 then update studs set fee = 100 where studs.id = cur_st;
            when 9<=avg_mark<=10 then update studs set fee = 50 where studs.id = cur_st;
			end case;
		end if;
    end loop l;
    close cur;
end//
delimiter ;


# no disabled in our university ---------------------------------------------------------------------------------------
drop trigger if exists stop_disabled;
delimiter //
create trigger stop_disabled AFTER UPDATE ON st_groups
FOR EACH ROW
begin
	
    declare stud_id int;
#    declare new_group_id int;
	declare is_end int default 0;
	declare cur cursor for select studs.id from studs where studs.group_id = old.id and studs.health = "hardly alive";
    declare continue handler for not found set is_end = 1;
 
#	if (select count(*) from (select 1 from st_groups where st_groups.semester = old.semester and st_groups.specialty = old.specialty limit 1)as t)  = 0
#  	then 
#	insert into st_groups (semester, specialty) values (old.semester, old.specialty);
# 	end if;
    
#	select st_groups.id into new_group_id from st_groups where st_groups.semester = old.semester and st_groups.specialty = old.specialty limit 1;
    
	if new.semester > old.semester
    then
		open cur;
		l:loop 
			fetch cur into stud_id;
			if is_end then leave l; end if;
#		   update studs set studs.group_id = new_group_id where studs.id = stud_id;
			update studs set studs.group_id = 1 where studs.id = stud_id;
		end loop l;
        close cur;
    end if;
	
end//
delimiter ;

# log --------------------------------------------------------------------------------------------------------------------------------
create table if not exists health_log
(
id int auto_increment primary key,
st_id int,
previous_value ENUM("healthy","normal","invalid","hardly alive"),
new_value ENUM("healthy","normal","invalid","hardly alive"),
constraint log_stud_fk foreign key (st_id) references studs(id) on update cascade on delete cascade
);


drop trigger if exists health_log_trigger;
delimiter //
create trigger health_log_trigger after update on studs
for each row
begin
	if new.health <> old.health
    then 
		insert into health_log (st_id, previous_value,new_value) values (new.id, old.health, new.health);
    end if;

end//
delimiter ;

# mark problematic ---------------------------------------------------------------------------------------------
drop trigger if exists mark_problematic_ins;
delimiter //
create trigger mark_problematic_ins after insert on lessons
for each row
begin
	update studs set studs.problematicQ = 1 where studs.id in(select t.id from(
	select st_id as id, avg(attended) as attendance, avg(mark) as avg_mark from lessons
	group by st_id) as t
	where t.attendance < 0.4 or t.avg_mark < 4);
end //
delimiter ;

drop trigger if exists mark_problematic_upd;
delimiter //
create trigger mark_problematic_upd after update on lessons
for each row
begin
	update studs set studs.problematicQ = 1 where studs.id in(select t.id from(
	select st_id as id, avg(attended) as attendance, avg(mark) as avg_mark from lessons
	group by st_id) as t
	where t.attendance < 0.4 or t.avg_mark < 4);
end //
delimiter ;

drop trigger if exists mark_problematic_del;
delimiter //
create trigger mark_problematic_del after delete on lessons
for each row
begin
	update studs set studs.problematicQ = 1 where studs.id in(select t.id from(
	select st_id as id, avg(attended) as attendance, avg(mark) as avg_mark from lessons
	group by st_id) as t
	where t.attendance < 0.4 or t.avg_mark < 4);
end //
delimiter ;
