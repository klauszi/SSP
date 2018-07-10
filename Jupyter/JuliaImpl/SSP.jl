module SSP
using WAV, Plots

include("Audio.jl")
export Audio, loadAudio, saveAudio, playAudio, mapTracks, mapSamples, times, numSamples, numTracks, samplingRate, plotAudio, duration, concat

include("FramedAudio.jl")
export FramedAudio, mapFrames, mapTracks, mapSamples, numSamples, numTracks, samplingRate, numFrames, plotAudio

include("FramedSpectrum.jl")
export FramedSpectrum, numTracks, numFrequencies, numFrames, numSamples, samplingRate


end
