using Test

include("../main.jl")

@testset "greeting" begin
    @test greeting() == "Hello, Julia!"
end
