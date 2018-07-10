module Sheet3

using Plots, SSP

# generate a sparse Toeplitz matrix
function sptoeplitz{T<:Number}(row :: Array{T}) :: SparseMatrixCSC{T,Int}
    n = length(row)
    _i = []
    _j = []
    _v = []
    for i in 1:n
        push!(_i,i)
        push!(_j,i)
        push!(_v,row[1])
    end
    for offdiag in 1:n-1
        v = row[1+offdiag]
        if v != 0
            for i in 1:n-offdiag
                push!(_i,i)
                push!(_j,i+offdiag)
                push!(_v,v)
                push!(_i,i+offdiag)
                push!(_j,i)
                push!(_v,v)
            end
        end
    end
    sparse(_i,_j,_v,n,n)
end

# Generate a Toeplitz matrix
function toeplitz(row)
    Matrix(sptoeplitz(row))
end


# Select subinterval from an Audio
function between(audio::Audio, t0::Float64, t1::Float64)
    s0 = floor(Int, t0 * samplingRate(audio))
    s1 = floor(Int, t1 * samplingRate(audio))
    t0_ = s0 / samplingRate(audio)
    Audio(audio.samples[s0:s1,:], samplingRate(audio), t0_)
end


# Compute the LP coefficients of a signal
function lpc(signal :: Vector{Float64}; m=12::Int)
    n = length(signal)
    ϕ = xcorr(signal, signal)[n:n+m-1]
    y = xcorr(signal, signal)[n+1:n+m]
    M = toeplitz(ϕ)
    a = -M \ y
    a
end

# Compute the LP coefficients of an Audio
function lpc(audio::Audio; m=12::Int, track=1::Int)
    lpc(audio.samples[:,track], m=m)
end

# Compute the LP coefficients for each frame of a FramedAudio
function lpc(faudio::FramedAudio; m=12::Int, track=1::Int)
    as = zeros(numFrames(faudio), m)
    for i in 1:numFrames(faudio)
        as[i,:] = lpc(faudio.frames[:,track,i], m=m)
    end
    as
end

# Evaluate a polynomial with given coefficients
function polynomial(coeffs::Vector{Float64}, z::Complex{Float64})
    sum(map(i -> coeffs[i]*z^(i-1), 1:length(coeffs)))
end

# Frequency response given ARMA coefficients `b` and `a`
function freqz(b::Vector{Float64}, a::Vector{Float64}, n::Int; whole=false::Bool)
    f = z -> polynomial(b, 1/z) / polynomial(a, 1/z)
    I = linspace(0, whole ? 2*pi : pi, n+1)[1:n]
    f.(exp.(1.0im * I))
end

# Compute the pre-emphasis of an `Audio`
function my_preemphasis(audio::Audio; alpha=0.95)
    s = audio.samples[:,1]
    y = zeros(length(s)-1)
    for i in 1:length(y)
        y[i] = s[i+1] - alpha*s[i]
    end
    loadAudio(y,samplingRate(audio))
end
end
