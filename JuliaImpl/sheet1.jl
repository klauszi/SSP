# include("SSV.jl")

module Sheet1
using SSV

############################################################################
#                        P R E R E Q U I S I T E S                         #
############################################################################


function my_windowing(audio :: Audio;
                      frame_length = 32e-3 :: Float64,
                      frame_shift  = 16e-3 :: Float64)
    # number of samples per frame
    num_spf = floor(Int, frame_length * samplingRate(audio))
    # number of samples per shift
    num_sps = floor(Int, frame_shift * samplingRate(audio))
    # number of frames
    num_f   = 1 + floor(Int, (numSamples(audio) - num_spf)/num_sps)

    m_frames = zeros(num_spf, numTracks(audio), num_f)
    mean_time = zeros(num_f)
    for i in 1:num_f
        interval        = num_sps*(i-1) + (1:num_spf)
        m_frames[:,:,i] = audio.samples[interval,:]
        mean_time[i]    = frame_shift*(i-1) + frame_length/2
    end

    FramedAudio(m_frames, samplingRate(audio), mean_time, frame_length, frame_shift)
end
end
