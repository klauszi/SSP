module Sheet1
using SSP

function my_windowing(audio :: Audio;
                      frame_length = 32e-3 :: Float64,
                      frame_shift  = 16e-3 :: Float64)
    # number of samples per frame
    num_spf = floor(Int, frame_length * samplingRate(audio))
    # number of samples per shift
    num_sps = floor(Int, frame_shift * samplingRate(audio))
    # number of frames
    num_f   = 1 + floor(Int, (numSamples(audio) - num_spf)/num_sps)

    mean_time = frame_shift*(0:num_f-1) + frame_length/2
    m_frames = zeros(num_spf, numTracks(audio), num_f)
    for i in 1:num_f
        interval        = num_sps*(i-1) + (1:num_spf)
        m_frames[:,:,i] = audio.samples[interval,:]
    end

    FramedAudio(m_frames, samplingRate(audio), mean_time, num_spf, num_sps)
end

function autocor(x; truncate=false::Boolean)
    ac = xcorr(x,x)/length(x)
    truncate ? ac[length(x):end] : ac
end

function fundamentalFrequencyEstimator(faudio::FramedAudio; track=1)

    # ff estimate per frame
    freq = zeros(numFrames(faudio))

    for j in 1:numFrames(faudio)
        # for simplicity we only analyse the first track
        signal = faudio.frames[:,track,j]
        freq[j] = fundamentalFrequencyEstimator(signal, samplingRate(faudio))
    end

    return (faudio.mean_time, freq)
end

function fundamentalFrequencyEstimator(signal::Array{Float64},
                                       samplingRate::Float64)
    # 80Hz:400Hz frequency window
    lowerBound = floor(Int, samplingRate / 400)
    upperBound =  ceil(Int, samplingRate / 80)

    ϕ = autocor(signal, truncate=true)
    ϕ[1:lowerBound] = -Inf
    ϕ[upperBound:end] = -Inf
    samplingRate / findmax(ϕ)[2]
end
end
