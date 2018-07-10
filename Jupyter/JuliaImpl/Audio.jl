using WAV

struct Audio
    # indexed by [sample, track]
    samples      :: Array{Float64,2}

    # samples per second
    samplingRate :: Float64

    # timestamp of the first sample
    t0           :: Float64
end

function times(audio::Audio)
    I = 1:numSamples(audio)
    audio.t0 + (I-1)/samplingRate(audio)
end

function loadAudio(filepath :: String)
    (s,fs) = wavread(filepath)
    loadAudio(s, Float64(fs))
end

function loadAudio(samples      :: Array{Float64,1},
                   samplingRate :: Float64)
    loadAudio(reshape(samples,length(samples),1), samplingRate)
end

function loadAudio(samples      :: Array{Float64,2},
                   samplingRate :: Float64)
    Audio(samples, samplingRate, 0.0)
end

function saveAudio(audio :: Audio,
                   filepath :: String)
    wavwrite(audio.samples, filepath, Fs = audio.samplingRate)
end

function playAudio(audio :: Audio)
    wavplay(audio.samples, audio.samplingRate)
end

function mapTracks(f, # Vector{Float} -> Vector{Float}
                  audio::Audio)
    mappedSamples = zeros(audio.samples)
    for i in 1:numTracks(audio)
        mappedSamples[:,i] = f(audio.samples[:,i])
    end
    loadAudio(mappedSamples, audio.samplingRate)
end

function mapSamples(f, # Matrix{Float} -> Matrix{Float}
                    audio::Audio)
    loadAudio(f(audio.samples), audio.samplingRate)
end

function numSamples(audio :: Audio)
    size(audio.samples)[1]
end

function numTracks(audio :: Audio)
    size(audio.samples)[2]
end

function samplingRate(audio :: Audio)
    audio.samplingRate
end

function plotAudio(audio :: Audio)
    plot(times(audio), audio.samples, xlab="time [s]", ylab="level")
end

function duration(audio :: Audio)
    numSamples(audio)/samplingRate(audio)
end

function concat(audios::Audio...; samplingRate=audios[1].samplingRate)
    if length(audios) == 0
        throw("concat: empty list of Audios")
    end

    loadAudio(vcat(map(audio -> audio.samples, audios)...), samplingRate)
end
