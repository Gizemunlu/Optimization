using JuMP, Clp, Printf

dt = [40 60 75 25 ]  # talep edilen yelkenli sayısı

m = Model(with_optimizer(Clp.Optimizer))

#variables
@variable(m, 0 <= x[0:4] <= 40)     # Sailboats produced with regular labor.
@variable(m, y[0:4] >= 0)           # Sailboats produced wkh overtime labor.
@variable(m, ci[1:4] >= 0 )         # Increase in production.
@variable(m, cd[1:4] >= 0 )         # Decrease in production.
@variable(m, hi[1:4] >= 0 )         # Boats held in inventory.
@variable(m, hd[1:4] >= 0 )         # Unmet boats held in inventory.

#constraints
@constraint(m, hi[4] >= 10 )
@constraint(m, hd[4] <= 0 )
@constraint(m, ci[1] - cd[1] == x[1] + y[1] - 50)
@constraint(m,  hi[1]- hd[1] == 10 + x[1] + y[1] - dt[1])
@constraint(m, stream[t in 2:4], (ci[t] - cd[t]) == x[t] + y[t] - (x[t-1] + y[t-1]))
@constraint(m, flow[t in 2:4], (hi[t] - hd[t]) == hi[t-1] - hd[t-1] + x[t] + y[t] - dt[t])

#objective
@objective(m, Min, 400*sum(x)+ 450*sum(y) + 20*sum(hi) + 400*sum(ci) + 500*sum(cd) + 100*sum(hd))   # minimize costs

optimize!(m)



@printf("Boats to build regular labor: %d %d %d %d\n", value(x[1]), value(x[2]), value(x[3]), value(x[4]))
@printf("Boats to build extra labor: %d %d %d %d\n", value(y[1]), value(y[2]), value(y[3]), value(y[4]))
@printf("H+ values: %d %d %d %d \n", value(hi[1]), value(hi[2]), value(hi[3]), value(hi[4]))
@printf("H- values: %d %d %d %d \n", value(hd[1]), value(hd[2]), value(hd[3]), value(hd[4]))
@printf("C+ values: %d %d %d %d \n", value(ci[1]), value(ci[2]), value(ci[3]), value(ci[4]) )
@printf("C- values: %d %d %d %d \n", value(cd[1]), value(cd[2]), value(cd[3]), value(cd[4]))
@printf("Objective cost: %f\n", objective_value(m))
