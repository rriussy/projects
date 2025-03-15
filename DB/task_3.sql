use mmf2025;

DROP TRIGGER exam_restr;
DELIMITER //
create trigger exam_restr BEFORE INSERT ON exam_results
FOR EACH ROW
BEGIN 
	IF 
		(select exam_type from exams where id = new.exam_id) = "big" and
		NEW.st_id IN (
		select studs.id
		from studs 
		left join subjects on subjects.group_id = studs.group_id
		left join exams on subjects.id = exams.subj_id
		left join exam_results on exams.id = exam_results.exam_id
		where exams.exam_type = "small" and (exam_results.mark <4 or exam_results.mark is null))
    THEN
		SET NEW.mark = NULL;
	END IF;
END//
DELIMITER ;
