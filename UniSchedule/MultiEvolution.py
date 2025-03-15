from ScheduleAssignment import ScheduleAssignment


class MultiEvolution:
    pops = []
    solutions_amount = 1
    migr_size = 10

    def __init__(self, groups, classes, pop_size=100, pop_amount=3, migration_size=10):
        self.pops = []
        self.migr_size = migration_size
        for _ in range(pop_amount):
            self.pops.append(ScheduleAssignment(groups, classes, pop_size))

    def evolution(self, gens=5000):
        for counter in range(gens):
            fitnesses = []
            for i in range(len(self.pops)):
                j = (i+1)%len(self.pops)
                self.pops[i].evolution(1)
                fitnesses.append(self.pops[i].population[-1].fitness)
                self.pops[j].population.extend(self.pops[i].tournament(k =self.migr_size))
            print(fitnesses)
            if 0 in fitnesses:
                print("solution found in gen ", counter)
                self.found_sol = counter
                return [self.pops[fitnesses.index(0)].population[-1]]
        return [pop.population[-1] for pop in self.pops]

