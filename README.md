# Optimisation Algorithms

Implementations of classic optimisation and combinatorial algorithms in Julia. Built as supplementary material alongside coursework in operations research and metaheuristics.

Each algorithm is implemented from scratch (no external solver libraries, only Julia standard library)

---

## Algorithms

### 1. Dijkstra's Shortest Path
Single-source shortest path on a weighted directed graph. Step-by-step implementation showing the unvisited set Q and visited set S at each iteration.

### 2. Genetic Algorithm: N-Queens
Solves the N-Queens problem using a genetic algorithm with tournament selection, ordered crossover, and swap mutation. Also includes a brute-force solver for small N (≤ 8) for comparison.

### 3. A\* Search
Heuristic shortest path search using the haversine distance as an admissible heuristic on a geographic graph. Finds optimal routes between nodes with lat/lon coordinates.

### 4. Simulated Annealing: 0/1 Knapsack
Solves a 50-item, 600 kg capacity knapsack problem with simulated annealing. Greedy initial solution, single-flip neighbourhood moves, geometric cooling schedule.

---

## Structure

```
optimisation-algorithms/
├── dijkstra/
│   └── dijkstra.jl
├── genetic_algorithm/
│   └── n_queens_genetic.jl
├── astar/
│   └── astar.jl
└── simulated_annealing/
    └── simulated_annealing_knapsack.jl
```

---

## How to run

```bash
julia dijkstra/dijkstra.jl
julia genetic_algorithm/n_queens_genetic.jl
julia astar/astar.jl
julia simulated_annealing/simulated_annealing_knapsack.jl
```

No packages required beyond Julia standard library (`Random`).
