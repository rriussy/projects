import copy
import itertools
import random
from prettytable import PrettyTable

from ScheduleIndividual import ScheduleIndividual


class ScheduleAssignment:
    population = []
    pop_size = 0
    groups = dict() #group name - group object
    classes = dict() #group name - subjects
    sections=dict() #id - subj


    mut_size=3
    tour_size = 3

    solutions_amount = 1
    max_lectures = 2
    max_practices = 2

    def __init__(self, groups:dict, classes:dict, pop_size:int, **kwargs):
        self.classes = classes
        self.groups = groups
        self.pop_size = pop_size
        if "mut_size" in kwargs.keys():
            self.mut_size = kwargs["mut_size"]
        if "tour_size" in kwargs.keys():
            self.tour_size = kwargs["tour_size"]
        if "solutions_amount" in kwargs.keys():
            self.solutions_amount = kwargs["solutions_amount"]
        if "solutions_amount" in kwargs.keys():
            self.solutions_amount = kwargs["solutions_amount"]
        if "max_practices" in kwargs.keys():
            self.max_practices = kwargs["max_practices"]

        i=0
        total = 0
        sec_nums = []
        for key in classes.keys(): # for each group
            sec_nums.append(0)
            for subj in classes[key]:
                period_num = subj.period_num
                while period_num>0:
                    self.sections[i] = subj
                    period_num-=1
                    sec_nums[-1]+=1
                    i+=1
            while i < total + sum(self.groups[key].period_num):
                self.sections[i] = "Window"
                sec_nums[-1]+=1
                i+=1
            total = i
        self.population=[ScheduleIndividual(sec_nums) for _ in range(pop_size)]
        self.calc_schedule()


    def calc_schedule(self):
        for ind in self.population:
            self.calc_one_schedule(ind)

    def calc_one_schedule(self, ind):
        ind.schedule.clear()
        for j in range(len(ind.genes)): # for each group
            line = ind.genes[j]
            day = 0
            prd = 0
            periods = self.groups[list(self.groups.keys())[j]].period_num
            for i in line:  # for each section
                if periods[day] <= prd:
                    prd = 0
                    day += 1
                if day ==6:
                    print("smt went wrong")
                    break
                subj = self.sections[i]
                if subj == "Window":
                    prd+=1
                    continue
                t_name = subj.teacher
                if t_name in ind.schedule.keys():
                    ind.schedule[t_name].append([day,prd])
                    prd+=1
                else:
                    ind.schedule[t_name]=[[day,prd]]
                    prd+=1

    def calc_fitness(self):
        for ind in self.population:
            self.calc_one_fitness(ind)

    def calc_one_fitness(self,ind):
        fitness = 0
        for tch in ind.schedule.keys():
            sch = ind.schedule[tch]
            sch.sort()
            elem = sch[0]
            for otherelem in sch[1::]:
                if otherelem == elem: #intersection in teacher schedule
                    fitness -= 1
                else:
                    if elem[0] == otherelem[0] and otherelem[1] - elem[1]!=1: # window in teacher schedule
                        fitness -=1
                    elem = otherelem
        for j in range(len(ind.genes)):  # group number
            line = ind.genes[j]
            day = 0
            prd = 0
            sbj_day = dict()
            sbj_str = ""
            lecture_count = 0
            practice_count = 0
            group = list(self.groups.keys())[j]  # group name
            periods = self.groups[group].period_num
            for i in line:  # id of a section

                if periods[day] <= prd:  # the end of the day
                    fitness -= prd - periods[day]  # specified amount of subj per day
                    for k in sbj_day.keys():  # only MAX lessons of each subj per day
                        if sbj_day[k] > self.groups[group].max_sub_pd:
                            fitness -= sbj_day[k] - self.groups[group].max_sub_pd
                    fitness -= sbj_str.strip("Window").count("Window")
                    if lecture_count > self.max_lectures:
                        fitness -=1
                    if practice_count > self.max_practices:
                        fitness-=1
                    lecture_count = 0
                    practice_count = 0
                    sbj_str = ""
                    prd = 0
                    day += 1
                    sbj_day.clear()
                if day == 7:
                    break

                subj = self.sections[i]
                if subj == "Window":
                    sbj_str += "Window"
                    prd+=1
                    continue
                sbj_str += "+"
                if subj.subj_name in sbj_day.keys():
                    sbj_day[subj.subj_name] += 1
                else:
                    sbj_day[subj.subj_name] = 1
                prd += 1
                if subj.type == "Practice":
                    practice_count +=1
                if subj.type == "Lecture":
                    lecture_count +=1
            fitness -= sbj_str.strip("Window").count("Window")
            if lecture_count > self.max_lectures:
                fitness -= 1
            if practice_count > self.max_practices:
                fitness -= 1
        ind.fitness = fitness

    def sort(self):
        def partition(array, low, high):
            pivot = array[high]
            i = low - 1
            for j in range(low, high):
                if array[j].fitness <= pivot.fitness:
                    i = i + 1
                    (array[i], array[j]) = (array[j], array[i])
            (array[i + 1], array[high]) = (array[high], array[i + 1])
            return i + 1

        def quickSort(array, low, high):
            if low < high:
                pi = partition(array, low, high)
                quickSort(array, low, pi - 1)
                quickSort(array, pi + 1, high)
        quickSort(self.population, 0, len(self.population) - 1)

    def select_parents(self):
        ft = [ind.fitness for ind in self.population]
        s = min(ft)
        ft = [(x-s)+1 for x in ft]
        chosen = random.choices(self.population, weights=ft, k=2)
        while chosen[0] == chosen[1]:
            chosen = random.choices(self.population, weights=ft, k=2)
        return chosen

    def crossover(self, dad, mom):
        son = copy.deepcopy(dad)

        all_genes = []
        for line in range(len(dad.genes)):
            crPoint1 = random.randrange(0,len(dad.genes[line]))
            crPoint2 = random.randrange(crPoint1+1,len(dad.genes[line])+1)
            genes = copy.copy(mom.genes[line])
            substr = dad.genes[line][crPoint1:crPoint2]
            momsubstr = mom.genes[line][crPoint1:crPoint2]
            momsubstr = [x for x in momsubstr if x not in substr]
            for i in range(len(genes)):
                if genes[i] in substr and not (crPoint1 <= i < crPoint2):
                    genes[i] = random.choice(momsubstr)
                    momsubstr.remove(genes[i])
            genes[crPoint1:crPoint2] = substr
            all_genes.append(genes)
        son.genes = all_genes
        self.calc_one_schedule(son)
        self.calc_one_fitness(son)
        return son

    def mutation(self,ind):
        gamma = self.mut_size
        results = []
        perms = []
        chosen_ind = []
        for line in range(len(ind.genes)):
            chosen_ind.append(random.sample(list(range(len(ind.genes[line]))),gamma))
            perms.append(list(itertools.permutations(chosen_ind[line])))
        all_p = list(itertools.product(*perms))
        for pms in all_p: #((1,2,3),(4,5,6))
            mutated = copy.deepcopy(ind)
            for line in range(len(pms)): #1,2
                for i in range(len(mutated.genes[line])):
                    if i in chosen_ind[line]:
                        mutated.genes[line][i] = ind.genes[line][pms[line][chosen_ind[line].index(i)]]
            self.calc_one_schedule(mutated)
            self.calc_one_fitness(mutated)
            results.append(mutated)
        return max(results,key=lambda x: x.fitness)

    def tournament(self, **kwargs):
        if "k" in kwargs.keys():
            k = kwargs["k"]
        else:
            k = self.pop_size
        new_pop = [self.population[-1]]
        while len(new_pop)!=k:
            batch = random.sample(self.population,self.tour_size)
            best = max(batch,key=lambda x: x.fitness)
            new_pop.append(best)
        return new_pop

    def evolution(self, gen=10000):
        best_ft = 0
        count = 0
        self.calc_schedule()
        self.calc_fitness()
        self.sort()
        for g in range(gen):
            if self.population[-self.solutions_amount].fitness == 0:
                print("solutions found in gen ", g)
                self.found_sol = g
                return [self.population[-self.solutions_amount]]
            if best_ft == self.population[-1].fitness:
                count +=1
            else:
                count = 0
            best_ft = self.population[-1].fitness

            #print(self.population[-1].fitness, self.population[-1].genes)
            for _ in range(self.pop_size):
                dad,mom = self.select_parents()
                son = self.crossover(dad,mom)
                chance = random.randrange(100)
                if chance < 30:
                    son = self.mutation(son)
                self.population.append(son)
            self.calc_schedule()
            self.calc_fitness()
            self.sort()
            self.population = self.population[-len(self.population)//2::]

            #self.population = self.tournament()
            #self.sort()
            print("Gen: ", g, "Best fitness: ", self.population[-1].fitness)
            if count == 2000:
                print("terminated")
                break
            if g % 100 == 0:
                print(self.population[-5::])
        return self.population[-self.solutions_amount::]

    def to_schedule(self, ind):
        tables = dict()
        for j in range(len(ind.genes)):  # group number
            line = ind.genes[j]
            day = 0
            prd = 0
            sbj_day = dict()
            group = list(self.groups.keys())[j]  # group name
            tb = PrettyTable()
            days = ["Mon","Tue","Wed","Thu","Fri","Sat"]

            cur_data = []
            periods = self.groups[group].period_num
            max_pd = max(periods)
            for i in line:# id of a section

                if periods[day] <= prd:
                    cur_data = cur_data + [" " for _ in range(max_pd-len(cur_data)+1)]
                    tb.add_column(days[day],cur_data)
                    cur_data = []
                    prd = 0
                    day += 1
                    sbj_day.clear()
                if day == 7:
                    print("smt went wrong")
                    break
                if self.sections[i] == "Window":
                    cur_data.append("Window")
                    prd += 1
                else:
                    subj = self.sections[i]
                    prd+=1
                    cur_data.append([subj.subj_name,subj.teacher,subj.type])
            cur_data = cur_data + [" " for _ in range(max_pd - len(cur_data) + 1)]
            tb.add_column(days[day], cur_data)
            tables[group] = tb
        return tables


