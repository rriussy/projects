import copy
import random

from TeachingIndividual import TeachingIndividual


class TeachingAssignment:
    population = []
    all_teachers = dict()
    teacher_names = []
    all_classes = dict()    #group: subjects
    all_classes_arr = []    #all subject objects
    solutions_amount = 1
    monitor = True  # True for monitoring evolution

    def __init__(self, all_teachers, all_classes, size, solutions_amount=1,monitor=True):
        self.all_teachers = all_teachers
        self.teacher_names = list(all_teachers.keys())
        self.all_classes = all_classes
        self.solutions_amount = solutions_amount
        self.monitor = monitor
        for cl in all_classes.keys():
            self.all_classes_arr.extend(all_classes[cl])
        self.population = [TeachingIndividual(self.teacher_names, all_teachers, self.all_classes_arr, len(self.all_classes_arr))
                           for _ in range(size)]

    def show(self):
        print("---")
        for ind in self.population:
            print(ind.fitness, ind.genes)

    def calc_fitness(self):
        for ind in self.population:
            ind.calc_assigned_hours(self.all_classes_arr)
            fitness = 0
            seen = set()
            for i in range(len(ind.genes)):
                name = ind.genes[i]
                if ((self.all_classes_arr[i].subj_name not in ind.teachers[name].specialty_subj)
                        and self.all_classes_arr[i].specialty):
                    fitness -= 1
                if self.all_classes_arr[i].subj_name not in ind.teachers[name].subj:
                    fitness -= 5
                if name not in seen and ind.teachers[name].assigned_hours > ind.teachers[name].hour_limit_pw:
                    fitness -= (ind.teachers[name].assigned_hours - ind.teachers[name].hour_limit_pw)
                    seen.add(name)
            ind.fitness = fitness

    # def calc_fitness(self):
    #     for ind in self.population:
    #         fitness = 3*(sum([subj.period_num for subj in self.all_classes_arr]) -
    #                    min([tch.hour_limit_per_week for tch in self.all_teachers.values()]))
    #         seen = set()
    #         for i in range(len(ind.genes)):
    #             name = ind.genes[i]
    #             seen.add(name)
    #             if ind.teachers[name].speciality_subj == self.all_classes_arr[i] and self.all_classes_arr[
    #                 i].speciality:
    #                 fitness += 5
    #             if name not in seen and ind.teachers[name].assigned_hours > ind.teachers[name].hour_limit_per_week:
    #                 #print(fitness, ind.teachers[name].assigned_hours, ind.teachers[name].hour_limit_per_week,3*(ind.teachers[name].assigned_hours - ind.teachers[name].hour_limit_per_week),fitness - 3*(ind.teachers[name].assigned_hours - ind.teachers[name].hour_limit_per_week))
    #                 fitness -= 3*(ind.teachers[name].assigned_hours - ind.teachers[name].hour_limit_per_week)
    #         ind.fitness = fitness




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
        ft = [(x - s) + 1 for x in ft]
        chosen = random.choices(self.population, weights=ft, k=2)
        while chosen[0] == chosen[1]:
            chosen = random.choices(self.population, weights=ft, k=2)
        return chosen
    # def select_parents(self):
    #     return (self.population[-1],self.population[-2])

    def crossover(self, dad, mom):
        son = copy.deepcopy(dad)
        daughter = copy.deepcopy(mom)
        for i in range(len(son.genes)):
            chance = random.randint(0, 1)
            if chance == 1:
                son.genes[i] = mom.genes[i]
                daughter.genes[i] = dad.genes[i]
        return son, daughter

    def mutation(self, child, prob=50):
        chance = random.randrange(0, 100)
        if chance < prob:
            point = random.randrange(len(child.genes))
            child.genes[point] = random.choice(self.teacher_names)
        return child

    def evolution(self, gen=5000):
        best_ft = 0
        count = 0
        self.calc_fitness()
        self.sort()
        for g in range(gen):
            if best_ft == self.population[-1].fitness:
                count += 1
            else:
                count = 0
            best_ft = self.population[-1].fitness
            dad,mom = self.select_parents()
            son, daughter = self.crossover(dad,mom)
            self.mutation(son)
            self.mutation(daughter)
            self.population.extend([son,daughter])
            self.calc_fitness()
            self.sort()
            self.population = self.population[2::]
            if count == 2000:
                print("terminated")
                break
            if self.population[-self.solutions_amount].fitness == 0:
                print("solutions found in gen ", g)
                self.found_sol = g
                return self.population[-self.solutions_amount:]
            if g%100 == 0 and self.monitor:
                print("Gen: ",g," Best fitness: ", self.population[-1].fitness)
        return self.population[-self.solutions_amount::]

    def assign(self,solution):
        for i in range(len(self.all_classes_arr)):
            self.all_classes_arr[i].teacher = solution.genes[i]
        self.all_teachers = solution.teachers
