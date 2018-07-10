module Levinson
# Julia implementation for converting between lpc coefficients, reflection coefficients and log-area rations
# Code follows the Python implementation found in
# - https://github.com/cokelaer/spectrum/blob/master/src/spectrum/levinson.py
# - https://github.com/cokelaer/spectrum/blob/master/src/spectrum/linear_prediction.py

function LEVINSON{R <: AbstractFloat, K <: Union{R,Complex{<:R}}}(r::Vector{K}; order=length(r)-1::Int, allow_singularity=false::Bool)
    T0 = real(r[1])
    T = r[2:end]
    M = length(T)
    assert(order <= M)

    A = zeros(K, M)
    ref = zeros(K, M)

    P = T0

    for k in 1:M
        save = T[k]
        if k == 1
            temp = -save / P
        else
            for j in 1:k-1
                save = save + A[j] * T[k-j]
            end
            temp = -save / P
        end
        P = P * (1. - abs(temp)^2)
        if P <= 0 && !allow_singularity
            throw("singular matrix")
        end
        println(typeof(A), " ", typeof(temp))
        A[k] = temp
        ref[k] = temp
        if k == 1
            continue
        end
        khalf = div(k,2)
        for j in 1:khalf
            kj = k - j
            save = A[j]
            A[j] = save + temp * conj(A[kj])
            if j != kj
                A[kj] += temp * conj(save)
            end
        end
    end

    A, P, ref
end

function rlevinson{R <: AbstractFloat, K <: Union{R, Complex{R}}}(a::Vector{K}, efinal::R)
    assert(a[1] == 1.0)

    p = length(a)

    if p < 2
        throw("Polynomial should have at least two coefficients")
    end

    U = zeros(K, p, p)
    U[:, p] = conj(a[end:-1:1])

    p = p - 1
    e = zeros(R, p)

    e[end] = efinal

    for k in p:-1:2
        a, e[k-1] = levdown(a, e[k])
        U[:, k] = vcat(conj(a[end:-1:1]), zeros(K, p-k+1))
    end

    e0 = e[1] / (1.0 - abs(a[2]^2))
    U[1,1] = 1.0
    kr = conj(U[1,2:end])

    R_ = zeros(Complex{R}, 1)
    R0 = e0
    R_[1] = -conj(U[1,2])*R0

    for k in 2:p
        r = -dot(conj(U[1:k-1, k]), R_[1:k-1]) - kr[k]*e[k-1]
        append!(R_, r)
    end

    prepend!(R_, e0)
    R_, U, kr, e
end

function levdown{R <: AbstractFloat, K <: Union{R, Complex{R}}}(anxt::Vector{K}, enxt::R)
    if anxt[1] != 1
        throw("At least one of the reflection coefficients is equal to one.")
    end
    anxt = anxt[2:end]

    knxt = anxt[end]
    if knxt == 1.0
        throw("At least one of the reflection coefficients is equal to one.")
    end

    acur = (anxt[1:end-1] - knxt * conj(anxt[end-1:-1:1])) / (1. - abs(knxt)^2)
    ecur = enxt / (1. - dot(conj(knxt), knxt))

    prepend!(acur, 1.0)

    return acur, ecur
end

function levup{R <: AbstractFloat, K <: Union{R, Complex{R}}}(acur::Vector{K}, knxt::Vector{K}, ecur::R)
    if acur[1] != 1.0
        throw("At least one of he reflection coefficients is equal to one.")
    end

    acur = acur[2:end]

    anxt = vcat(acur, [0.0]) + knxt .* vcat(conj(acur[end:-1:1]), [1.0])

    enxt = (1. - norm(knxt)^2) * ecur

    prepend!(anxt, 1.0)

    anxt, enxt
end


function poly2rc{R <: AbstractFloat, K <: Union{R, Complex{R}}}(a::Vector{K}, efinal::R)
    results = rlevinson(a, efinal)
    results[3]
end


function rc2poly{R <: AbstractFloat, K <: Union{R, Complex{R}}}(kr::Vector{K}, r0::R)
    p = length(kr)
    a = [1.0, kr[1]]
    e = zeros(p)
    e0 = r0

    e[1] = e0 * (1. - abs(kr[1])^2)

    for k in 2:p
        a, e[k] = levup(a, [kr[k]], e[k-1])
    end

    efinal = e[end]
    a, efinal
end

function rc2lar{R <: AbstractFloat}(k::Vector{R})
    if maximum(abs.(k)) >= 1
        throw("All reflection coefficients should have magnitude less than unity.")
    end
    return -2.0 * atanh.(-k)
end

function lar2rc{R <: AbstractFloat}(g::Vector{R})
    - tanh.(g/2)
end

end
