# dijkstra.jl
# Dijkstra's shortest path algorithm implemented from scratch.
# Finds minimum-cost paths from a source node to all reachable nodes.
#
# Run: julia dijkstra.jl

# Graph as adjacency list: node => [(neighbour, cost), ...]
function build_example_graph()
    return Dict(
        "A" => [("B", 10), ("C", 3)],
        "B" => [("C", 1),  ("D", 2)],
        "C" => [("B", 4),  ("D", 8), ("E", 2)],
        "D" => [("E", 7)],
        "E" => [("D", 9)],
    )
end

"""
    dijkstra(graph, source)

Dijkstra's algorithm from `source`. Returns a Dict of shortest distances
to all reachable nodes.

Uses a sorted vector as priority queue. For large graphs swap for a
proper min-heap via DataStructures.jl.
"""
function dijkstra(graph::Dict, source::String)
    dist    = Dict{String, Union{Int, Nothing}}(n => nothing for n in keys(graph))
    visited = Dict{String, Int}()

    dist[source] = 0
    current, current_dist = source, 0

    while true
        for (neighbour, edge_cost) in graph[current]
            haskey(visited, neighbour) && continue
            new_dist = current_dist + edge_cost
            if dist[neighbour] === nothing || new_dist < dist[neighbour]
                dist[neighbour] = new_dist
            end
        end

        visited[current] = current_dist
        delete!(dist, current)
        isempty(dist) && break

        candidates = [(n, d) for (n, d) in dist if d !== nothing]
        isempty(candidates) && break
        current, current_dist = sort(candidates, by = x -> x[2])[1]
    end

    return visited
end

# ---- Run --------------------------------------------------------------------
graph = build_example_graph()
println("=== Dijkstra shortest paths from A ===")
result = dijkstra(graph, "A")
for (node, dist) in sort(collect(result), by = x -> x[1])
    println("  A → $node : $dist")
end
