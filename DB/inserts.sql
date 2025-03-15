USE mmf2025;
SET FOREIGN_KEY_CHECKS=0;  
TRUNCATE TABLE studs; 
TRUNCATE TABLE st_groups;
TRUNCATE TABLE subjects;
TRUNCATE TABLE exams;
TRUNCATE TABLE exam_results;
TRUNCATE TABLE lessons;
SET FOREIGN_KEY_CHECKS=1; 

insert into st_groups
(specialty,semester)
values
("km",1),
("ped",2),
("chinese",1),
(null,1);


INSERT INTO studs
(st_name, st_surname,birthday, group_id, form, health, activity_hours)
VALUES
("Oleg","Pipka","2004-04-12",2,"budget","healthy",5),
("Olga","Pipka","2005-04-12",1,"paid","normal",0),
("Ira","Mmm","2005-12-21 14:12:06",1,"budget","healthy",25),
("Arseniy","Atru","2005-09-12 11:00:00",1,"budget","hardly alive",11),
("Max","Min","2004-02-01 03:26:10",1,"paid","invalid",800),
("Willy","Wonka","2004-08-01 20:21:20",2,"budget","hardly alive",1);

INSERT INTO subjects
(subj_name, teacher,group_id)
VALUES
("diffury","Gromak",1),
("km","Kushnerov",1),
("mmzi","Kushnerov",1),
("km2","Kushnerov",2),
("obj","Scheglova",2);


INSERT INTO lessons
(start_time,subj_id, st_id, attended, mark)
VALUES
("2024-12-01 08:15:00",1,2,false,10),
("2024-12-01 08:15:00",1,3,true,9),
("2024-12-01 08:15:00",1,4,true,6),
("2024-12-01 08:15:00",1,5,true,null),

("2024-12-01 09:30:00",2,2,false,null),
("2024-12-01 09:30:00",2,3,true,null),
("2024-12-01 09:30:00",2,4,true,2),
("2024-12-01 09:30:00",2,5,false,null),

("2024-12-01 11:15:00",3,2,false,null),
("2024-12-01 11:15:00",3,3,true,8),
("2024-12-01 11:15:00",3,4,true,2),
("2024-12-01 11:15:00",3,5,false,null),

("2024-12-01 08:15:00",2,2,false,null),
("2024-12-01 08:15:00",2,3,true,9),
("2024-12-01 08:15:00",2,4,true,3),
("2024-12-01 08:15:00",2,5,true,null),

("2024-12-01 11:15:00",1,2,false,null),
("2024-12-01 11:15:00",1,3,true,8),
("2024-12-01 11:15:00",1,4,true,4),
("2024-12-01 11:15:00",1,5,true,null),

("2024-12-01 13:00:00",4,1,true, null),
("2024-12-01 13:00:00",4,6,true, 7),
("2024-12-01 14:30:00",5,1,false, null),
("2024-12-01 14:30:00",5,6,false, null);

INSERT INTO exams
(subj_id, exam_date, exam_type)
VALUES
(1, "2024-01-05","big"),
(2, "2024-01-09","big"),
(3, "2024-01-15","big"),
(4, "2024-01-05","big"),
(5, "2024-01-15","big"),
(1,"2024-01-25","retry"),
(1,"2024-02-15","retry");

insert into exam_results
(exam_id,st_id,mark)
values
(1,2,12),
(1,3,3),
(1,4,-3),
(1,5,2),

(2,2,6),
(2,3,1),
(2,4,9),
(2,5,5),

(3,2,10),
(3,3,3),
(3,4,4),
(3,5,6),
(6,4,7),
(6,5,3),
(7,5,2);