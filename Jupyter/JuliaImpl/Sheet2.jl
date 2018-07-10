module Sheet2
using SSP, Plots, DSP
export my_stft, plot_stft, my_inverse_stft, my_spectrogram

############################################################################
#                        E X E R C I S E   O N E                           #
############################################################################

function myHann(n)
    N = n % 2 == 0 ? n + 1 : n
    Windows.hanning(N)[1:n]
end

function hann(n; periodic=false::Bool)
    periodic ? Windows.hanning(n+1)[1:n] : Windows.hanning(n)
end

function my_stft(faudio::FramedAudio)
    num_spf     = numSamples(faudio)
    truncation  = floor(Int, numSamples(faudio) / 2) + 1
    K = 1:truncation
    frequencies = (K-1) * samplingRate(faudio) / numSamples(faudio)

    dft_frames = zeros(Complex{Float64},
                       truncation,
                       numTracks(faudio),
                       numFrames(faudio))
    for i in 1:numFrames(faudio)
        frame    = faudio.frames[:,:,i]
        spectrum = fft(frame)
        dft_frames[:,:,i] = spectrum[1:truncation,:]
    end

    FramedSpectrum(dft_frames, samplingRate(faudio), faudio.mean_time,
                   frequencies, faudio.spf, faudio.sps,
                   numSamples(faudio))
end

############################################################################
#                        E X E R C I S E   T W O                           #
############################################################################

function applyWindow(x :: FramedAudio, window = n -> sqrt.(myHann(n)))
    x = deepcopy(x)
    sw = window(numSamples(x))
    for i in 1:numFrames(x)
        x.frames[:,:,i] = x.frames[:,:,i] .* repmat(sw, 1, numTracks(x))
    end
    x
end

function my_spectrogram(fspec :: FramedSpectrum; track=1, maxfreq=Inf)
    T = fspec.mean_time
    frequencyRange = fspec.frequencies .<= maxfreq
    F = fspec.frequencies[frequencyRange]
    M = fspec.spectrum[frequencyRange,track,:]
    Z = 10 * log10.(max.(abs.(M).^2, 1e-15))
    histogram2d(T, F, Z, xlab="time in [s]", ylab="frequency in [Hz]", fill=true, levels=32)
end

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
                framedSpectrum.spf, framedSpectrum.sps)
end


function my_inverse_windowing(faudio :: FramedAudio)
    signal  = zeros(faudio.spf + faudio.sps * (numFrames(faudio) - 1), numTracks(faudio))
    for i in 1:numFrames(faudio)
        frame                = faudio.frames[:,:,i]
        interval             = faudio.sps * (i-1) + (1:faudio.spf)
        signal[interval, :] += frame
    end

    loadAudio(signal, samplingRate(faudio))
end

# function applyFilter(x :: FramedSpectrum, the_filter = n -> sqrt.(myHann(n)))
#     x = deepcopy(x)
#     sw = the_filter(numFrequencies(x))
#     for i in 1:numFrames(x)
#         x.spectrum[:,:,i] = x.spectrum[:,:,i] .* repmat(sw, 1, numTracks(x))
#     end
#     x
# end
end
