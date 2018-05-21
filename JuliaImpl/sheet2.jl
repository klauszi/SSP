# include("SSV.jl")
# include("sheet1.jl")

module Sheet2
using SSV, Plots, DSP
export my_stft, plot_stft, my_inverse_stft

############################################################################
#                        E X E R C I S E   O N E                           #
############################################################################

function sqrt_hann(n)
    Windows.hanning(n)
end

function my_stft(framedAudio :: FramedAudio)
    num_spf     = numSamples(framedAudio)
    truncation  = floor(Int, numSamples(framedAudio) / 2) + 1
    frequencies = samplingRate(framedAudio)/numSamples(framedAudio) * (1:truncation)

    dft_frames = zeros(Complex{Float64},
                       truncation,
                       numTracks(framedAudio),
                       numFrames(framedAudio))
    for i in 1:numFrames(framedAudio)
        frame    = framedAudio.frames[:,:,i]
        spectrum = fft(frame)
        dft_frames[:,:,i] = spectrum[1:truncation,:]
    end

    FramedSpectrum(dft_frames, samplingRate(framedAudio), framedAudio.mean_time,
                   frequencies, framedAudio.frame_length, framedAudio.frame_shift,
                   numSamples(framedAudio))
end

############################################################################
#                        E X E R C I S E   T W O                           #
############################################################################

# see `spectrogram` function in SSV module

############################################################################
#                        E X E R C I S E   T H R E E                       #
############################################################################

function my_inverse_stft(framedSpectrum :: FramedSpectrum)

    if numSamples(framedSpectrum) % 2 == 0
        spectra = cat(1, framedSpectrum.spectrum, framedSpectrum.spectrum[end-1:-1:2,:,:])
    else
        spectra = cat(1, framedSpectrum.spectrum, framedSpectrum.spectrum[end:-1:2,:,:])
    end

    signal_frames = zeros(numSamples(framedSpectrum),
                          numTracks(framedSpectrum),
                          numFrames(framedSpectrum));
    for i in 1:numFrames(framedSpectrum)
        frame = spectra[:,:,i]
        signal_frames[:,:,i] = real.(ifft(frame))
    end
    FramedAudio(signal_frames, samplingRate(framedSpectrum), framedSpectrum.mean_time,
                framedSpectrum.frame_length, framedSpectrum.frame_shift)
end

function apply_window(x :: FramedAudio, window = sqrt_hann)
    x = deepcopy(x)
    sw = window(numSamples(x))
    for i in 1:numFrames(x)
        x.frames[:,:,i] = x.frames[:,:,i] .* repmat(sw, 1, numTracks(x))
    end
    x
end

function my_inverse_windowing(framedAudio :: FramedAudio)
    # number of samples per frame
    num_spf = numSamples(framedAudio)
    # number of samples per shift
    num_sps = floor(Int, framedAudio.frame_shift * samplingRate(framedAudio))

    signal  = zeros(num_spf + num_sps * numFrames(framedAudio), numTracks(framedAudio))
    for i in 1:numFrames(framedAudio)
        frame                = framedAudio.frames[:,:,i]
        interval             = num_sps*(i-1) + (1:num_spf)
        signal[interval, :] += frame
    end

    loadAudio(signal, samplingRate(framedAudio))
end


function apply_filter(x :: FramedSpectrum, the_filter = sqrt_hann)
    x = deepcopy(x)
    sw = the_filter(numFrequencies(x))
    for i in 1:numFrames(x)
        x.spectrum[:,:,i] = x.spectrum[:,:,i] .* repmat(sw, 1, numTracks(x))
    end
    x
end

end
