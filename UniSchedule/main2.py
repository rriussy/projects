import time
from MultiEvolution import MultiEvolution
from Subject import Subject
from Teacher import Teacher
from Group import Group
from TeachingAssignment import TeachingAssignment
from ScheduleAssignment import ScheduleAssignment

if __name__ == '__main__':
    teachersL = [Teacher() for _ in range(10)]
    teacher_names = ["Bob", "Alice", "Martha", "Artem", "Kate", "Helen", "Peter", "Nina", "Mary", "Dora"]
    teachers = dict(zip(teacher_names, teachersL))
    teachers["Bob"].specialty_subj = ["Literature"]
    teachers["Bob"].subj = ["Literature", "History"]
    teachers["Bob"].hour_limit_pw = 20
    teachers["Helen"].subj = ["History","Literature"]
    teachers["Helen"].hour_limit_pw = 15
    teachers["Mary"].subj = ["English"]
    teachers["Mary"].hour_limit_pw = 5
    teachers["Dora"].subj = ["English"]
    teachers["Dora"].hour_limit_pw = 5
    teachers["Alice"].specialty_subj = ["Chemistry"]
    teachers["Alice"].subj = ["Chemistry"]
    teachers["Martha"].specialty_subj = ["Biology"]
    teachers["Martha"].subj = ["Biology"]
    teachers["Artem"].specialty_subj = ["Math"]
    teachers["Artem"].subj = ["Math"]
    teachers["Kate"].specialty_subj = ["Physics"]
    teachers["Kate"].subj = ["Physics"]

    classes = {"A": [Subject(subj_name="Literature", period_num=5, speciality=True, type="Lecture"),
                     Subject(subj_name="Chemistry", period_num=5, speciality=True, type="Practice"),
                     Subject(subj_name="Biology", period_num=5, speciality=True, type="Practice"),
                     Subject(subj_name="History", period_num=3, type="Lecture"),
                     Subject(subj_name="English", period_num=2)],

               "B": [Subject(subj_name="Literature", period_num=5, speciality=True, type="Lecture"),
                     Subject(subj_name="Math", period_num=5, speciality=True, type="Practice"),
                     Subject(subj_name="Physics", period_num=5, speciality=True, type="Practice"),
                     Subject(subj_name="History", period_num=3, type="Lecture"),
                     Subject(subj_name="English", period_num=2)]#,

               # "C": [Subject(subj_name="Literature", period_num=5, type="Lecture"),
               #       Subject(subj_name="Chemistry", period_num=5, speciality=True, type="Practice"),
               #       Subject(subj_name="Biology", period_num=5, speciality=True, type="Practice"),
               #       Subject(subj_name="History", period_num=3, type="Lecture"),
               #       Subject(subj_name="English", period_num=2)],
               #
               # "D": [Subject(subj_name="Literature", period_num=5, type="Lecture"),
               #       Subject(subj_name="Math", period_num=5, speciality=True, type="Practice"),
               #       Subject(subj_name="Physics", period_num=5, speciality=True, type="Practice"),
               #       Subject(subj_name="History", period_num=3, type="Lecture"),
               #       Subject(subj_name="English", period_num=2)]
               }

    groups = {"A": Group(subjects=classes["A"], group_name="A", period_num=[5, 5, 4, 4, 4, 3]),
              "B": Group(subjects=classes["B"], group_name="B", period_num=[4, 4, 4, 5, 5, 3])#,
              # "C": Group(subjects=classes["C"], group_name="C", period_num=[4, 4, 4, 5, 5, 3]),
              # "D": Group(subjects=classes["D"], group_name="D", period_num=[5, 5, 4, 4, 4, 3]),
              }
    start = time.time()
    teachers_assignment = TeachingAssignment(teachers, classes, 300, 1)

    res = teachers_assignment.evolution()
    while res[-1].fitness != 0:
        teachers_assignment = TeachingAssignment(teachers, classes, 300, 1)
        res = teachers_assignment.evolution()
    for ind in res:
        print(ind.fitness, ind.genes)
    teachers_assignment.assign(res[-1])
    # print("A:")
    # for s in classes["A"]:
    #     print(s.subj_name, ": ", s.teacher)
    # print("B:")
    # for s in classes["B"]:
    #     print(s.subj_name, ": ", s.teacher)
    # print("C:")
    # for s in classes["C"]:
    #     print(s.subj_name, ": ", s.teacher)
    # print("D:")
    # for s in classes["D"]:
    #     print(s.subj_name, ": ", s.teacher)
    schedule_assignment = MultiEvolution(groups, classes)
    schedule_create = ScheduleAssignment(groups,classes,1)
    res = schedule_assignment.evolution(5000)
    end = time.time()
    print("Time taken to create schedule: ", end - start)
    for elem in res:
        print(elem.fitness)
        for l in elem.genes:
            print(l)
        print(elem.fitness, "\n",schedule_create.to_schedule(elem))
