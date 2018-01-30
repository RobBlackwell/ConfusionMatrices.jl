module ConfusionMatrices

using StatsBase

export ConfusionMatrix, CombinedConfusionMatrix

include("ConfusionMatrix.jl")
include("CombinedConfusionMatrix.jl")

end # module
