# n_queens_genetic.jl
# N-Queens problem solved with a genetic algorithm.
# Also includes a brute-force solver for small N (≤ 8) for comparison.
#
# Run: julia n_queens_genetic.jl
# Tune: change N, POPULATION_SIZE, MUTATION_PROB, TOURNAMENT_SIZE below

using Random

# ---- Parameters (change these) -----------------------------------------------
const N               = 8      # number of queens (board size)
const POPULATION_SIZE = 200    # number of chromosomes in population
const MUTATION_PROB   = 0.3    # probability of mutation per child
const TOURNAMENT_SIZE = 5      # candidates compared in tournament selection
const MAX_ITER        = 10000  # iteration limit
# ------------------------------------------------------------------------------

const MAX_FITNESS = N * (N - 1)  # max non-attacking pairs (no clashes at all)


# ---- Representation ----------------------------------------------------------
# A chromosome is a permutation of 1:N — queen in column i is on row chromosome[i].
# Using permutations guarantees no row conflicts, only diagonal ones matter.

function random_chromosome()
    c = collect(1:N)
    shuffle!(c)
    return c
end

function fitness(chromosome::Vector{Int})
    clashes = 0
    for i in 1:N, j in 1:N
        if i != j
            dx = abs(i - j)
            dy = abs(chromosome[i] - chromosome[j])
            dx == dy && (clashes += 1)
        end
    end
    return MAX_FITNESS - clashes
end


# ---- Genetic operators -------------------------------------------------------

function tournament_selection(population::Vector{Vector{Int}}, fitnesses::Vector{Int})
    best = rand(1:length(population))
    for _ in 1:TOURNAMENT_SIZE
        candidate = rand(1:length(population))
        fitnesses[candidate] > fitnesses[best] && (best = candidate)
    end
    return population[best]
end

function ordered_crossover(parent1::Vector{Int}, parent2::Vector{Int})
    a, b = sort(sample(1:N, 2, replace=false))
    child = zeros(Int, N)
    child[a:b] = parent1[a:b]
    # fill remaining positions in order from parent2
    remaining = [x for x in parent2 if x ∉ child[a:b]]
    pos = [i for i in 1:N if i < a || i > b]
    child[pos] = remaining
    return child
end

function mutate!(chromosome::Vector{Int})
    if rand() < MUTATION_PROB
        i, j = sort(sample(1:N, 2, replace=false))
        chromosome[i], chromosome[j] = chromosome[j], chromosome[i]
    end
end


# ---- Main GA loop ------------------------------------------------------------

function genetic_algorithm()
    population = [random_chromosome() for _ in 1:POPULATION_SIZE]
    fitnesses  = [fitness(c) for c in population]

    for iter in 1:MAX_ITER
        # Check for solution
        best_idx = argmax(fitnesses)
        if fitnesses[best_idx] == MAX_FITNESS
            println("Solution found at iteration $iter")
            println("Board: $(population[best_idx])")
            print_board(population[best_idx])
            return population[best_idx], iter
        end

        # Select, crossover, mutate two children per iteration
        p1 = tournament_selection(population, fitnesses)
        p2 = tournament_selection(population, fitnesses)
        c1 = ordered_crossover(p1, p2)
        c2 = ordered_crossover(p2, p1)
        mutate!(c1); mutate!(c2)

        # Replace worst two in population
        worst1 = argmin(fitnesses)
        population[worst1] = c1
        fitnesses[worst1]  = fitness(c1)
        worst2 = argmin(fitnesses)
        population[worst2] = c2
        fitnesses[worst2]  = fitness(c2)
    end

    println("No solution found in $MAX_ITER iterations.")
    return nothing, MAX_ITER
end


# ---- Brute force (for small N) -----------------------------------------------

function brute_force_queens(n::Int)
    n > 10 && error("Brute force is too slow for N > 10")
    solutions = Vector{Int}[]
    for perm in permutations(collect(1:n))
        fitness_val = 0
        for i in 1:n, j in 1:n
            if i != j
                dx = abs(i - j)
                dy = abs(perm[i] - perm[j])
                dx == dy && (fitness_val += 1)
            end
        end
        fitness_val == 0 && push!(solutions, perm)
    end
    return solutions
end

# Simple permutations generator
function permutations(arr)
    length(arr) == 0 && return [[]]
    result = Vector{Vector{eltype(arr)}}()
    for (i, x) in enumerate(arr)
        rest = [arr[j] for j in 1:length(arr) if j != i]
        for p in permutations(rest)
            push!(result, [x; p])
        end
    end
    return result
end


# ---- Visualisation -----------------------------------------------------------

function print_board(chromosome::Vector{Int})
    n = length(chromosome)
    println("\nBoard (Q = queen, . = empty):")
    for row in 1:n
        line = ""
        for col in 1:n
            line *= chromosome[col] == row ? " Q " : " . "
        end
        println(line)
    end
    println()
end


# ---- Run it ------------------------------------------------------------------

println("=== $N-Queens — Genetic Algorithm ===")
println("Population: $POPULATION_SIZE | Mutation prob: $MUTATION_PROB | Tournament size: $TOURNAMENT_SIZE\n")
Random.seed!(42)
solution, iters = genetic_algorithm()

if N <= 8
    println("\n=== Brute force solutions for N=$N ===")
    sols = brute_force_queens(N)
    println("Found $(length(sols)) solutions")
end
