# simulated_annealing_knapsack.jl
# 0/1 Knapsack problem solved with Simulated Annealing.
# A truck has a maximum load capacity. We want to maximise the total value
# of items loaded without exceeding the weight limit.
#
# Run: julia simulated_annealing_knapsack.jl

using Random

# ---- Problem data ------------------------------------------------------------
# 50 items, each with a value and weight. Truck capacity: 600 kg.

const CAPACITY = 600

const VALUES  = [18, 11, 15, 18, 15,  7, 17, 15, 22, 16,
                 18, 10, 13, 15, 16, 15, 12, 13, 12, 11,
                 14, 17, 12, 15,  7, 16, 16, 12, 16, 13,
                 16, 12, 10, 11, 13, 15, 16, 15, 11, 14,
                 21, 11, 13, 10, 14, 18, 17, 14, 11, 15]

const WEIGHTS = [17, 20, 15, 12, 13, 20, 13, 13, 16, 15,
                 14, 15, 21, 13, 20, 19,  7, 11, 16, 12,
                 14, 17, 18, 16, 17, 25, 27, 15,  7, 18,
                 13, 13, 24, 18, 17, 11, 18, 13, 16, 14,
                 16, 21, 17, 14, 18, 16, 15, 11, 23, 19]

const N_ITEMS = length(VALUES)


# ---- SA parameters (tune these) ----------------------------------------------
const T_INIT      = 1000.0   # initial temperature
const T_MIN       = 1e-4     # stop when temperature drops below this
const COOLING     = 0.995    # geometric cooling rate
const MAX_ITER    = 50000    # max iterations per temperature
# ------------------------------------------------------------------------------


# ---- Objective and feasibility -----------------------------------------------

total_value(x)  = sum(VALUES[i]  * x[i] for i in 1:N_ITEMS)
total_weight(x) = sum(WEIGHTS[i] * x[i] for i in 1:N_ITEMS)
is_feasible(x)  = total_weight(x) <= CAPACITY


# ---- Generate initial feasible solution (greedy by value/weight ratio) -------

function greedy_initial_solution()
    x = zeros(Int, N_ITEMS)
    ratio = [(VALUES[i] / WEIGHTS[i], i) for i in 1:N_ITEMS]
    sort!(ratio, rev=true)
    w = 0
    for (_, i) in ratio
        if w + WEIGHTS[i] <= CAPACITY
            x[i] = 1
            w += WEIGHTS[i]
        end
    end
    return x
end


# ---- Neighbourhood move: flip one item ---------------------------------------

function random_neighbour(x::Vector{Int})
    x_new = copy(x)
    i = rand(1:N_ITEMS)
    x_new[i] = 1 - x_new[i]  # flip item i in/out
    return x_new
end


# ---- Simulated annealing main loop -------------------------------------------

function simulated_annealing()
    Random.seed!(42)

    x_current = greedy_initial_solution()
    @assert is_feasible(x_current) "Initial solution is not feasible"

    x_best = copy(x_current)
    val_current = total_value(x_current)
    val_best    = val_current

    T = T_INIT
    total_iters = 0
    accepted_worse = 0

    println("Initial solution: value=$(val_current), weight=$(total_weight(x_current))")

    while T > T_MIN
        for _ in 1:MAX_ITER
            total_iters += 1
            x_new = random_neighbour(x_current)

            # skip infeasible moves
            is_feasible(x_new) || continue

            val_new = total_value(x_new)
            Δ = val_new - val_current

            if Δ > 0
                # better solution — always accept
                x_current  = x_new
                val_current = val_new
                if val_new > val_best
                    x_best   = copy(x_new)
                    val_best = val_new
                end
            else
                # worse solution — accept with SA probability
                if rand() < exp(Δ / T)
                    x_current   = x_new
                    val_current = val_new
                    accepted_worse += 1
                end
            end
        end
        T *= COOLING
    end

    return x_best, val_best, total_iters, accepted_worse
end


# ---- Run it ------------------------------------------------------------------

println("=== Simulated Annealing — 0/1 Knapsack ===")
println("Items: $N_ITEMS | Capacity: $CAPACITY kg")
println("T_init: $T_INIT | Cooling: $COOLING\n")

x_best, val_best, iters, accepted_worse = simulated_annealing()

println("\n=== Results ===")
println("Best value:  $val_best")
println("Total weight: $(total_weight(x_best)) / $CAPACITY kg")
println("Items selected: $(sum(x_best)) / $N_ITEMS")
println("Iterations: $iters | Accepted worse: $accepted_worse")
println("\nSelected items (index, value, weight):")
for i in 1:N_ITEMS
    x_best[i] == 1 && println("  item $i: value=$(VALUES[i]), weight=$(WEIGHTS[i])")
end
