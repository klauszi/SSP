module SSV
using WAV, Plots
export Audio, FramedAudio, FramedSpectrum, loadAudio, saveAudio, playAudio, numSamples, numTracks, samplingRate, numFrames, numFrequencies, plotAudio, spectrogram

############################################################################
#                        A U D I O   S I G N A L                           #
############################################################################

struct Audio
    # indexed by [sample, track]
    samples       :: Array{Float64,2}

    # samples per second
    sampling_rate :: Float64

    # time of a sample in seconds
    times         :: Array{Float64}

    # title of audio
    title         :: String
end

function loadAudio(filepath :: String)
    (s,fs) = wavread(filepath)
    loadAudio(s, Float64(fs), title=filepath)
end

function loadAudio(samples       :: Array{Float64,2},
                   sampling_rate :: Float64;
                   title = ""    :: String)
    no_samples = size(samples)[1]
    times = 1/sampling_rate * (0:(no_samples-1))
    Audio(samples, sampling_rate, times, title)
end

function saveAudio(audio :: Audio,
                   filepath :: String)
    wavwrite(audio.samples, filepath, Fs = audio.sampling_rate)
end

function playAudio(audio :: Audio)
    wavplay(audio.samples, audio.sampling_rate)
end

function numSamples(audio :: Audio)
    size(audio.samples)[1]
end

function numTracks(audio :: Audio)
    size(audio.samples)[2]
end

function samplingRate(audio :: Audio)
    audio.sampling_rate
end

function plotAudio(audio :: Audio)
    plot(audio.times, audio.samples, xlab="time [s]", ylab="level", title=audio.title)
end

############################################################################
#                              F R A M E S                                 #
############################################################################

struct FramedAudio
    # indexed by [sample, track, frame]
    frames        :: Array{Float64,3}

    # samples per second
    sampling_rate :: Float64

   # average time of a frame
    mean_time     :: Array{Float64,1}

    frame_length  :: Float64
    frame_shift   :: Float64
end

function numSamples(faudio :: FramedAudio)
    size(faudio.frames)[1]
end

function numTracks(faudio :: FramedAudio)
    size(faudio.frames)[2]
end

function numFrames(faudio :: FramedAudio)
    size(faudio.frames)[3]
end

function samplingRate(faudio :: FramedAudio)
    faudio.sampling_rate
end

############################################################################
#                             S P E C T R U M                              #
############################################################################

struct FramedSpectrum
    spectrum      :: Array{Complex{Float64},3}
    sampling_rate :: Float64
    mean_time     :: Array{Float64,1}
    frequencies   :: Array{Float64}
    frame_length  :: Float64
    frame_shift   :: Float64
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
    fspec.sampling_rate
end

function spectrogram(fspec :: FramedSpectrum; track=1)
    T = fspec.mean_time
    F = fspec.frequencies
    M = fspec.spectrum[:,track,:]
    Z = 10 * log10.(max.(abs.(M).^2, 1e-15))
    histogram2d(T, F, Z, xlab="time in [s]", ylab="frequency in [Hz]", fill=true, levels=32)
end

end
