# Load package.
devtools::load_all()

# Create true model.
model <- ggm$create(nodes = 10, density = .5, proportion.positive.edges = .5)

# Plot model.
graph <- igraph::graph_from_adjacency_matrix(model, mode = "undirected", weighted = TRUE, diag = FALSE)
plot(graph)
igraph::edge_density(graph)

# Run method
result <- run.method(
    model = model,
    range = c(300, 1700),
    replications = 10,
    measure = "sen",
    target = .8,
    statistic = "power",
    criterion = .8,
    n.samples = 30,
    tolerance = 50,
    boots = 1e4,
    monotone = TRUE,
    non.increasing = FALSE,
    runs = 10
)
