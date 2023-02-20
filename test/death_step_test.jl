include("./helpers.jl")

testDeathModel = create_demographic_model(Daily,10_000,initKinship=true)

function age_death!(agent,model)
    age_step!(agent,model)
    death!(agent,model)
end

@testset "testing stepping functions" begin
    println("evaluating # of alive people:")
    @time nalive = length([person for person in allagents(testDeathModel) if isalive(person) ])
    idx = rand(1:nagents(testDeathModel))
    person = testDeathModel[idx]
    println("one step death!:")
    @time ret = death!(person, testDeathModel)
    @test ret == !isalive(person)
    println("exectuing one year of death+age steps on a daily basis:")
    @time run!(testDeathModel,age_death!,365)
    nalive = length([person for person in allagents(testDeathModel) if isalive(person) ])
    println("# of alive people after 1 year :$nalive")
    ndecade = 0
    while nalive > 0
        run!(testDeathModel,age_death!,365*10)
        nalive = length([person for person in allagents(testDeathModel) if isalive(person) ])
        ndecade += 1
        println("# of alive people after $(ndecade) decades :$nalive")
    end
    @test ndecade < 15
end

println("\n==========================================\n")
