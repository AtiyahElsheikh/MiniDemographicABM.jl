"""
Given an ABM model with a set of uncertain model parameters each associated with a
    uniform distribution (Subject to generalization to other sort of distributions),
    compute:
    - the time-dependent approximated derivative trajectories
    - the normalized time-dependent approximated derivatives trajectories
    about their nominal values
"""

using LinearAlgebra: I

struct OATProblem <: LSAProblem end

"approximation of parameter sensitivities for a vector- (single-valued) function"
function ΔfΔp(f,p,δ::Float64,::RunMode=SingleRun();seednum)
    seednum == 0 ? Random.seed!(floor(Int,time())) : Random.seed!(seednum)
    y = f(p)
    @assert typeof(y) == Vector{Float64} || typeof(y) == Float64
    ny = length(y)
    np = length(p)
    ΔyΔp = Array{Float64,2}(undef, ny, np)
    @threads for i in 1:np
      seednum == 0 ? Random.seed!(floor(Int,time())) : Random.seed!(seednum)
      @inbounds yδ = f(p + p[i] * I[1:np,i] * δ)
      @inbounds ΔyΔp[:,i] = ( yδ - y ) / δ
    end
    return ΔyΔp, y
end

ΔfΔp(f,p,δ::Float64,::MultipleRun;seednum) = notimplemented()

"normalized parameter sensitivities"
function ΔfΔp_normalized(f,p,δ::Float64,::RunMode=SingleRun(); seednum)
    ΔyΔpNorm , y = ΔfΔp(f,p,δ;seednum)
    ny = length(y)
    @simd for i in 1:ny
        @inbounds ΔyΔpNorm[i,:] =  p .* ( ΔyΔpNorm[i,:] / y[i] )
    end
    return ΔyΔpNorm, y
end

"normalized parameter sensitivities with multiple runs"
function ΔfΔp_normalized(f,p,δ::Float64, ::MultipleRun; seednum, nruns)
    ΔyΔpNorm, y =  ΔfΔp_normalized(f,p,δ;seednum)
    ny = length(y)
    yall = Array{Float64,2}(undef,ny,nruns)
    yall[:,1] = y
    for i in 2:nruns
        tmp, yall[:,i] = ΔfΔp_normalized(f,p,δ;seednum = seednum+i-1)
        ΔyΔpNorm += tmp
    end
    yavg = sum(yall,dims = 2) / nruns
    ΔyΔpNorm /= nruns
    return ΔyΔpNorm, yall, yavg
end

function _normalize_std!(ΔyΔpNorm,σp,σy)
    ny = size(ΔyΔpNorm)[1]
    @simd for i in 1:ny
        @inbounds ΔyΔpNorm[i,:] =  σp .* ( ΔyΔpNorm[i,:] / σy[i] )
    end
    nothing
end

"""
parameter sensitivities normalized with standard diviations
    - of parameters derived from a uniform distribution
    - of model outputs computed via a design matrix
"""
function ΔfΔp_normstd(f,p,δ,::RunMode=SingleRun();
                        seednum,sampleAlg=SobolSample(),n=length(p)*length(p))
    # compute derivatives
    ΔyΔpNorm, y = ΔfΔp(f,p,δ;seednum)
    ny = length(y)
    # normalization
    σp = std(actpars)
    pmatrix = sample(n,actpars,sampleAlg)  # design matrix
    ymatrix = Array{Float64}(undef,ny,n)
     # compute σ_y
    @threads for i in 1:n
        seednum == 0 ? Random.seed!(floor(Int,time())) : Random.seed!(seednum)
        @inbounds ymatrix[:,i] = f(pmatrix[:,i])
    end
    σy = [std(ymatrix[i,:]) for i in 1:ny]
    _normalize_std!(ΔyΔpNorm,σp,σy)
    return  ΔyΔpNorm, y, ymatrix, σy, σp
end


function ΔfΔp_normstd(f,p,δ,::MultipleRun;
    seednum,nruns,sampleAlg=SobolSample(),n=length(p)*length(p))
    # ...
end

"""
OAT Result contains:
- pnom  : nominal parameter values
- ytnom : associated output trajectories of size nt x ny where
    nt: number of points
    ny: number of outputs

"""
struct OATResult
    pnom::Vector{Float64}       # nominal parameter values
    ytnom::Matrix{Float64}      # trajectories of the output
    ∂yt∂p::Array{Float64,3}     # trajectories of approximated partial derivatives
    ∂yt∂pNom::Array{Float64,3}  # normalized

    function OATResult(ft,actpars,δ)
        pnom = nominal_values(actpars)
        yt = ft(pnom)
        # ΔytΔp  = _compute_dytdp(ft,ytnon,pnom,δ)
        # ΔytΔpNom = _compute_dytdp(ft,ytnom,pnom)
        new(pnom,nothing,nothing,nothing)
    end
end
