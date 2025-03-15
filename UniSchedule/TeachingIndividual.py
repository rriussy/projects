import copy
import random

class TeachingIndividual():
    genes = []
    teachers=dict()
    fitness = 0

    def __init__(self, names, teachers, subjects, gene_len):
        self.genes = random.choices(names, k=gene_len)
        self.teachers = copy.deepcopy(teachers)
        for i in range(len(self.genes)):
            self.teachers[self.genes[i]].assigned_hours += subjects[i].period_num

    def calc_assigned_hours(self,subjects):
        for i in range(len(self.genes)):
            self.teachers[self.genes[i]].assigned_hours = 0
        for i in range(len(self.genes)):
            self.teachers[self.genes[i]].assigned_hours += subjects[i].period_num
