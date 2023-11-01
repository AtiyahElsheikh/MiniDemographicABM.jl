"""
Run this script from shell as
#  julia <script-name.jl>

or within REPL

julia> include("script-name.jl")
"""

using Agents
using Distributions: Uniform

include("./simspec.jl")

#################
# Step I - model
#################
# Model declaration, initialization and stepping!
# With the functions below, simulation of the ABM model with Agents.jl can be conducted,
#   see main.jl

declare_model_properties(clock,starttime,initialPop;
    startMarriedRate=0.8,
    maxNumberOfMarriageCand=100,
    baseDieRate = 0.0001,
    maleAgeDieRate = 0.00021,
    maleAgeScaling = 14.0,
    femaleAgeDieRate = 0.00019,
    femaleAgeScaling = 15.5,
    basicDivorceRate = 0.06,
    basicMaleMarriageRate = 0.7) =
        DemographicABMProp{clock}(;starttime,initialPop,
            startMarriedRate,maxNumberOfMarriageCand,
            baseDieRate,maleAgeDieRate,maleAgeScaling,
            femaleAgeDieRate,femaleAgeScaling,
            basicDivorceRate,basicMaleMarriageRate)

function declare_initialized_UKmodel(clock,properties)
    model = UKDemographicABM(properties)
    seed!(model,floor(Int,time()))  # really random # TODO seed externally?
    declare_population!(model)
    init_kinship!(model) # the kinship among population
    init_housing!(model) # housing assoication to population
    return model
end

function agent_steps!(person,model)
    age_step!(person,model)
    death!(person,model)
    divorce!(person,model)
end

function model_steps!(model)
    metastep!(model) # incrementing time
    dobirths!(model)
    domarriages!(model)
end

#############################
# Step II - active parameters
#############################
# Define active parameters to which SA is sought

mutable struct ActiveParameter{ValType}
    lowerbound::ValType
    upperbound::ValType
    name::Symbol
    function ActiveParameter{ValType}(low,upp,id) where ValType
        @assert low <= upp
        new(low,upp,id)
    end
end
setParValue!(model,activePar,val) = setfield!(model, activePar.name, val)

const startMarriedRate = ActiveParameter{Float64}(0.01,0.99,:startMarriedRate)

# death parameters / yearly comulative (adhoc no model identification conducted)
const baseDieRate = ActiveParameter{Float64}(0.00005,0.00015,:baseDieRate)
const femaleAgeDieRate = ActiveParameter{Float64}(0.0001,0.0003,:femaleAgeDieRate)
const femaleAgeScaling = ActiveParameter{Float64}(13.0,33.0,:femaleAgeScaling)
const maleAgeDieRate = ActiveParameter{Float64}(0.0001,0.0003,:maleAgeDieRate)
const maleAgeScaling = ActiveParameter{Float64}(8.0,28.0,:maleAgeScaling)
const basicDivorceRate = ActiveParameter{Float64}(0.01,0.09,:basicDivorceRate)
const basicMaleMarriageRate = ActiveParameter{Float64}(0.1,0.9,:basicMaleMarriageRate)


##################################
# Step III - Input/Output function
##################################
## Define a simple simulation function of the form y = f(x)
##  output  : the average age of the living population
##  input   : selected model parameters w.r.t. SA is sought
##
##  using the following global constants below

const ACTIVEPARS = [ startMarriedRate, baseDieRate, femaleAgeDieRate,femaleAgeScaling,
    maleAgeDieRate, maleAgeScaling, basicDivorceRate, basicMaleMarriageRate ]
const CLOCK = Monthly
const STARTTIME = 1951
const NUMSTEPS = 12 * 100  # 100 year
const INITIALPOP = 1000

function avg_livings_age(pars)
    @assert length(pars) == length(ACTIVEPARS)
    for (i,p) in enumerate(pars)
        @assert ACTIVEPARS[i].lowerbound < p <= ACTIVEPARS[i].upperbound
    end
    properties = declare_model_properties(CLOCK,STARTTIME,INITIALPOP)
    for (i,p) in enumerate(pars)
        setParValue!(properties,ACTIVEPARS[i],p)
    end
    model = declare_initialized_UKmodel(Monthly,properties)
    # compute output
end

####################################
# Step IV - generate parameter sample
####################################
# Given the set of selected active parameters, their lower and upper bounds,
#  generate a sample parameter set using a uniform distribution


function sample_parameters()
    pars = zeros(length(ACTIVEPARS))
    for (i,ap) in enumerate(ACTIVEPARS)
        pars[i] =  rand(Uniform(ap.lowerbound,ap.upperbound))
    end
    return pars
end

## Perform SA using Morris method
