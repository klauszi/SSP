using WAV, Plots

pyplot()


(y1,fs1) = wavread("/home/long/Dokumente/Github/SSP/Exercise1/speech1.wav")
(y2,fs2) = wavread("/home/long/Dokumente/Github/SSP/Exercise1/speech2.wav")

x1 = (1:length(y1))/fs1
x2 = (1:length(y2))/fs2

my_windowing = function(v_signal, sampling_rate, frame_length, frame_shift)
    samples_per_frame = Int(floor(frame_length * sampling_rate))
    samples_per_shift = Int(floor(frame_shift * sampling_rate))
    shift_count = Int(floor((length(v_signal) - (samples_per_frame - samples_per_shift))/samples_per_shift))

    m_frames = zeros(samples_per_shift, shift_count)
    for j in 1:shift_count
        for i in 1:samples_per_shift
            m_frames[i,j] = v_signal[samples_per_shift*(j-1)+i]
        end
    end
    v_time_frame = frame_length/2 + frame_shift * (0:(shift_count-1))

    (m_frames, v_time_frame)
end

exercise02_plot1 = function()
    plot(x1,y1)
end

exercise02_plot2 = function()
    plot(x2,y2)
end
