
function [m_frames, v_time_frame ] = my_windowing(v_signal, sampling_rate, frame_length , frame_shift)
window_length = frame_length * sampling_rate;
shift_length = frame_shift * sampling_rate;
n = length(v_signal);
shifts = floor((n - window_length + shift_length) / shift_length);
m_frames =  zeros(shift_length, shifts);
for i = 1:shifts
    for j = 1:shift_length
        m_frames(j,i) = v_signal((i-1)*shift_length + j);
    end
end
v_time_frame = frame_shift * (1:shifts) - frame_shift/2;
end

