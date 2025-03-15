class Teacher:
    hour_limit_pd = 5
    hour_limit_pw = 10
    assigned_hours = 0 #per week
    subj = [] #all subjects he can teach
    specialty_subj = [] #subjects he is good at


    def __init__(self, **kwargs):
        if "hour_limit_per_day" in kwargs.keys():
            self.hour_limit_pd = kwargs["hour_limit_per_day"]
        if "hour_limit_per_week" in kwargs.keys():
            self.hour_limit_pw = kwargs["hour_limit_per_week"]
        if "subj" in kwargs.keys():
            self.subj = kwargs["subj"]
        if "speciality_subj" in kwargs.keys():
            self.specialty_subj = kwargs["speciality_subj"]

    # def add_class(self,class_name):
    #     self.classes.append(class_name)
    #     self.assigned_hours += 1
