struct FramedAudio
    # indexed by [sample, track, frame]
    frames        :: Array{Float64,3}

    # samples per second
    samplingRate :: Float64

    # average time of a frame
    mean_time     :: Array{Float64,1}

    # samples per frame
    spf           :: Int

    # samples per shift
    sps           :: Int
end

function mapFrames(f, # Audio -> Audio
                   faudio::FramedAudio)
    mappedFrames = zeros(faudio.frames)
    for i in 1:numFrames(faudio)
        a = f(loadAudio(faudio.frames[:,:,i], samplingRate))
        mappedFrames[:,:,i] = a.samples
    end
    mappedFrames
end

function mapTracks(f,
                   faudio::FramedAudio)
    mapFrames(a -> mapTracks(f,a), faudio)
end

function mapSamples(f,
                    faudio::FramedAudio)
    mapFrames(a -> mapSamples(f,a), faudio)
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
    faudio.samplingRate
end

function plotFramedAudio(faudio::FramedAudio)
    asdf
    plot(audio.times, audio.samples, xlab="time [s]", ylab="level")
end
