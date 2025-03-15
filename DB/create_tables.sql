drop database if exists mmf2025;
create database if not exists mmf2025;
use mmf2025;


create table if not exists st_groups(
id INT PRIMARY KEY AUTO_INCREMENT,
specialty ENUM('km','ped','proizvod','chinese'),
semester INT 
);

create table if not exists studs(
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
problematicQ bool default false,
CONSTRAINT st_group_fkey FOREIGN KEY (group_id) REFERENCES st_groups(id) ON DELETE CASCADE ON UPDATE CASCADE
);

create table if not exists subjects(
id INT PRIMARY KEY AUTO_INCREMENT,
subj_name VARCHAR(20),
teacher VARCHAR(20),
group_id INTEGER,
CONSTRAINT subj_group_fkey FOREIGN KEY (group_id) REFERENCES st_groups(id) ON DELETE CASCADE ON UPDATE CASCADE
);

create table if not exists exams(
id INT PRIMARY KEY AUTO_INCREMENT,
subj_id INT,
exam_date DATETIME,
exam_type ENUM("small","big","retry"),
CONSTRAINT subj_exam_fkey FOREIGN KEY (subj_id) REFERENCES subjects(id) ON DELETE CASCADE ON UPDATE CASCADE
);


create table if not exists exam_results(
exam_id INT,
st_id INT,
mark INTEGER,
PRIMARY KEY (exam_id,st_id),
CONSTRAINT st_exres_fkey FOREIGN KEY (st_id) REFERENCES studs(id) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT exam_exres_fkey FOREIGN KEY (exam_id) REFERENCES exams(id) ON DELETE CASCADE ON UPDATE CASCADE
);

create table if not exists lessons(
id INT PRIMARY KEY AUTO_INCREMENT,
start_time DATETIME,
subj_id INT,
st_id INT,
attended BOOL,
mark INTEGER,
CONSTRAINT st_les_fkey FOREIGN KEY (st_id) REFERENCES studs(id) ON DELETE CASCADE ON UPDATE CASCADE,
CONSTRAINT sub_marks_fkey FOREIGN KEY (subj_id) REFERENCES subjects(id) ON DELETE CASCADE ON UPDATE CASCADE
);

create table if not exists bestStuds(
st_id INT PRIMARY KEY,
avg_mark float,
constraint st_best_fkey foreign key (st_id) references studs(id) on delete cascade on update cascade
);
create table if not exists worstStuds(
st_id INT PRIMARY KEY,
avg_mark float,
constraint st_worst_fkey foreign key (st_id) references studs(id) on delete cascade on update cascade
);
create table if not exists activeStuds(
st_id INT PRIMARY KEY,
activity_hours float,
constraint st_active_fkey foreign key (st_id) references studs(id) on delete cascade on update cascade
);
