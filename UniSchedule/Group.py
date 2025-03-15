import copy


class Group:
    period_num = [5,5,5,5,5,0]
    max_sub_pd = 1
    subjects = dict() #subj name - num of periods pw
    group_name = ""
    schedule = []

    def __init__(self, **kwargs):
        if "period_num" in kwargs.keys():
            self.period_num= kwargs["period_num"]
        if "recess_period" in kwargs.keys():
            self.recess_period = kwargs["recess_period"]
        if "max_sub_pd" in kwargs.keys():
            self.max_sub_pd = kwargs["max_sub_pd"]
        if "subjects" in kwargs.keys(): #is a list of subj objects
            for s in kwargs["subjects"]:
                self.subjects[s.subj_name] = s.period_num
        if "group_name" in kwargs.keys():
            self.group_name = kwargs["group_name"]
        self.schedule = [[0 for _ in range(self.period_num[i])] for i in range(len(self.period_num))]

