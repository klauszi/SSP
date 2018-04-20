include("02-block-processing.jl")

convolution_matrix = function(n,t)
    t_ = abs(t)
    M = vcat(spdiagm(ones(n-t_),t_),zeros(t_,n))
    t >= 0 ? M : M'
end

autocor = function(x,t)
    n = length(x)
    t = abs(t)
    if t <= n
        x'*convolution_matrix(length(x),t)*x / n
    else
        0
    end
end


fundamental_frequency_estimates = function(y,fs)
    (frames, time_frame) = my_windowing(y,fs,32e-3,16e-3)

    ac = zeros(frames)
    freq = zeros(time_frame)
    lb = Int(floor(fs/400))
    ub = Int(floor(fs/80))
    for j in 1:size(frames)[2]
        x = frames[:,j]
        for i in 1:size(frames)[1]
            ac[i,j] = autocor(x,i-1)
        end
        freq[j] = fs/(lb-1+indmax(ac[lb:ub,j]))
    end

    return (frames, time_frame, freq)
end

(_,t1,freq1) = fundamental_frequency_estimates(y1,fs1)
(_,t2,freq2) = fundamental_frequency_estimates(y2,fs2)

exercise03_plot1 = function()
    plot([t1,x1],[freq1/400,y1*10])
end

exercise03_plot2 = function()
    plot([t2,x2],[freq2/400,y2*10])
end
