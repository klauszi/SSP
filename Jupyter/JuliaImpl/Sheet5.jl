module Sheet5
using SSP
using Sheet1
using Sheet3
using Plots
using DSP

# Signal power
function computePower(signal::Vector{Float64})
    mean(signal .^ 2)
end

# Signal power
function computePower(audio::Audio)
    reshape(mean(audio.samples .^ 2, 1),
            numTracks(audio))
end

# Signal power
function computePower(faudio::FramedAudio)
    reshape(mean(faudio.frames .^ 2, 1),
            numTracks(faudio),
            numFrames(faudio))
end


# Mean zero crossings:
# Lower bound for the average number of times a signal, which is thought
# of as continuous, takes the value 0
function meanZeroCrossings(signal::Vector{Float64})
    signChanges = sign.(signal[1:end-1] .* signal[2:end])
    count(signChanges .< 0) / length(signal)
end

# Mean zero crossings
function meanZeroCrossings(faudio::FramedAudio)
    z = zeros(numFrames(faudio))
    for i in 1:numFrames(faudio)
        s = faudio.frames[:,1,i]
        z[i] = meanZeroCrossings(s)
    end
    z
end

# Determines whether a signal is voiced or not
function isVoiced(x; threshold=0.29)
    meanZeroCrossings(x) .< threshold
end

function filterAdaptively(b::Vector{Float64},
                          a::Vector{Float64},
                          x::Vector{Float64};
                          zi=[]::Vector{Float64})
    n = max(length(b), length(a))

    a_ = zeros(n)
    a_[1:length(a)] = a
    b_ = zeros(n)
    b_[1:length(b)] = b
    zi_ = zeros(n-1)
    zi_[1:length(zi)] = zi

    stateful = DF2TFilter(PolynomialRatio(b_, a_), zi_)
    out = filt(stateful, x)
    zo = stateful.state
    (out, zo)
end

#--------------#
# QUANTIZATION #
#--------------#

function quantiseEncoder(signal::Vector{Float64}, nBits::Int, xMax::Float64, xCenter::Float64)
    asdf
end
end
