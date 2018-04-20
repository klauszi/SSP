using WAV, Plots

pyplot()


(y1,fs1) = wavread("/home/long/Dokumente/Github/SSP/Exercise1/speech1.wav")
(y2,fs2) = wavread("/home/long/Dokumente/Github/SSP/Exercise1/speech2.wav")

x1 = (1:length(y1))/fs1
x2 = (1:length(y2))/fs2

my_windowing = function(v_signal, sampling_rate, frame_length, frame_shift)
    sample_count = length(v_signal)
    window_size = Int(floor(frame_length * sampling_rate))
    shift_size = Int(floor(frame_shift * sampling_rate))
    shift_count = Int(floor((sample_count - (window_size - shift_size))/shift_size))

    m_frames = zeros(shift_size, shift_count)
    for j in 1:shift_count
        for i in 1:shift_size
            m_frames[i,j] = v_signal[shift_size*(j-1)+i]
        end
    end
    v_time_frame = frame_shift * ((1:shift_count)-1) + frame_length/2

    (m_frames, v_time_frame)
end

exercise02_plot1 = function()
    plot(x1,y1)
end

exercise02_plot2 = function()
    plot(x2,y2)
end
