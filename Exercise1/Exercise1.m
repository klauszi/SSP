[y1,Fs1] = audioread('speech1.wav');
[y2,Fs2] = audioread('speech2.wav');
x1 = [1:length(y1)] / Fs1;
x2 = [1:length(y2)] / Fs2;

plot(x1,y1);
plot(x2,y2);


[m_frames, v_time_frame ] = my_windowing(y1, Fs1, 32e-3 , 16e-3);