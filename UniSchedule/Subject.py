class Subject:
    subj_name = ""
    period_num = 0 #number of periods per week
    specialty = False # means this subj should be taught at a higher level
    teacher = None # name
    type = "Other" #lecture or practice

    def __init__(self, **kwargs):
        self.subj_name = kwargs["subj_name"]
        self.period_num = kwargs["period_num"]
        if "speciality" in kwargs.keys():
            self.specialty = kwargs["speciality"]
        if "teacher" in kwargs.keys():
            self.teacher = kwargs["teacher"]
        if "type" in kwargs.keys():
            self.type = kwargs["type"]

    def __repr__(self):
        return self.subj_name


