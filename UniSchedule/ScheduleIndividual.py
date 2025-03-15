import random


class ScheduleIndividual:
    #matrix of indices, each line representing schedule for one group
    #genes = []
    #fitness = 0
    #schedule = dict()  # teacher_name: list of [day, period_num]

    def __init__(self, sec_nums):
        self.genes = []
        self.fitness = 0
        self.schedule = dict()
        for num, i in enumerate(sec_nums):
            temp_list = list(range(sum(sec_nums[:num]), sum(sec_nums[:num]) + i))
            random.shuffle(temp_list)
            self.genes.append(temp_list)

    def __repr__(self):
        s = "Fitness: "+ str(self.fitness) + " Genes: "+str(self.genes)+'\n'
        return s

