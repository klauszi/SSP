using Plots

struct FramedSpectrum
    spectrum      :: Array{Complex{Float64},3}
    samplingRate :: Float64
    mean_time     :: Array{Float64,1}
    frequencies   :: Array{Float64}
    spf           :: Int
    sps           :: Int
    num_samples   :: Int
end

function numTracks(fspec :: FramedSpectrum)
    size(fspec.spectrum)[2]
end

function numFrequencies(fspec :: FramedSpectrum)
    size(fspec.spectrum)[1]
end

function numSamples(fspec :: FramedSpectrum)
    fspec.num_samples
end

function numFrames(fspec :: FramedSpectrum)
    size(fspec.spectrum)[3]
end

function samplingRate(fspec :: FramedSpectrum)
    fspec.samplingRate
end
