# astar.jl
# A* search algorithm implemented from scratch.
# Finds the shortest path between two nodes using a heuristic to guide search.
#
# Run: julia astar.jl
#
# The original implementation ran on a real Spain road network loaded from a
# binary file. This version uses a simple weighted graph with lat/lon coordinates
# so the haversine heuristic is preserved and the algorithm is identical.

using Printf

# ---- Graph representation ----------------------------------------------------

struct Node
    id::Int
    name::String
    lat::Float64
    lon::Float64
    neighbours::Vector{Tuple{Int, Float64}}  # (node_id, edge_cost)
end

# Build a small example graph with real-ish coordinates (Spanish cities)
function build_example_graph()
    nodes = Dict{Int, Node}(
        1 => Node(1, "Madrid",    40.4168, -3.7038, [(2, 632.0), (3, 391.0)]),
        2 => Node(2, "Barcelona", 41.3851,  2.1734, [(1, 632.0), (4, 162.0)]),
        3 => Node(3, "Seville",   37.3891, -5.9845, [(1, 391.0), (5, 214.0)]),
        4 => Node(4, "Girona",    41.9794,  2.8214, [(2, 162.0), (5, 1100.0)]),
        5 => Node(5, "Malaga",    36.7213, -4.4213, [(3, 214.0), (4, 1100.0), (1, 513.0)]),
    )
    return nodes
end


# ---- Haversine heuristic -----------------------------------------------------
# Straight-line distance between two nodes using lat/lon (admissible heuristic)

function haversine(lat1, lon1, lat2, lon2)
    R = 6371.0  # Earth radius in km
    φ1, φ2 = deg2rad(lat1), deg2rad(lat2)
    Δφ = deg2rad(lat2 - lat1)
    Δλ = deg2rad(lon2 - lon1)
    a = sin(Δφ/2)^2 + cos(φ1) * cos(φ2) * sin(Δλ/2)^2
    return R * 2 * atan(sqrt(a), sqrt(1 - a))
end

function heuristic(nodes::Dict, current_id::Int, goal_id::Int)
    n = nodes[current_id]
    g = nodes[goal_id]
    return haversine(n.lat, n.lon, g.lat, g.lon)
end


# ---- A* algorithm ------------------------------------------------------------

"""
    astar(nodes, start_id, goal_id)

A* search from start to goal. Returns (path, total_cost) or (nothing, Inf).

f(n) = g(n) + h(n)
  g(n) = actual cost from start to n
  h(n) = haversine distance from n to goal (admissible heuristic)
"""
function astar(nodes::Dict, start_id::Int, goal_id::Int)
    # g_cost[node] = best known cost from start
    g_cost = Dict{Int, Float64}(start_id => 0.0)
    parent = Dict{Int, Union{Int, Nothing}}(start_id => nothing)

    # Open set: nodes to explore, sorted by f = g + h
    open_set = Set{Int}([start_id])
    closed_set = Set{Int}()

    iter = 0
    while !isempty(open_set)
        iter += 1

        # Pick node in open set with lowest f cost
        current = argmin(n -> g_cost[n] + heuristic(nodes, n, goal_id), collect(open_set))

        if current == goal_id
            # Reconstruct path
            path = Int[]
            node = goal_id
            while node !== nothing
                pushfirst!(path, node)
                node = get(parent, node, nothing)
            end
            println("  Found in $iter iterations")
            return path, g_cost[goal_id]
        end

        delete!(open_set, current)
        push!(closed_set, current)

        for (neighbour_id, edge_cost) in nodes[current].neighbours
            neighbour_id in closed_set && continue

            tentative_g = g_cost[current] + edge_cost

            if !haskey(g_cost, neighbour_id) || tentative_g < g_cost[neighbour_id]
                g_cost[neighbour_id] = tentative_g
                parent[neighbour_id] = current
                push!(open_set, neighbour_id)
            end
        end
    end

    return nothing, Inf  # no path found
end


# ---- Run it ------------------------------------------------------------------

nodes = build_example_graph()

println("=== A* Shortest Path ===")
println("Graph nodes:")
for (id, node) in sort(collect(nodes), by = x -> x[1])
    @printf("  %d: %-12s (%.4f, %.4f)\n", id, node.name, node.lat, node.lon)
end
println()

# Find paths between a few pairs
pairs = [(1, 4), (3, 2), (5, 1)]
for (start, goal) in pairs
    println("--- $(nodes[start].name) → $(nodes[goal].name) ---")
    path, cost = astar(nodes, start, goal)
    if path !== nothing
        route = join([nodes[n].name for n in path], " → ")
        @printf("  Path: %s\n", route)
        @printf("  Cost: %.1f km\n\n", cost)
    else
        println("  No path found\n")
    end
end
