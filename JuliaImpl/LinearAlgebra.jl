module LinearAlgebra

export sptoeplitz
function sptoeplitz{T<:Number}(row :: Array{T}) :: SparseMatrixCSC{T,Int}
    n = length(row)
    _i = []
    _j = []
    _v = []
    for i in 1:n
        push!(_i,i)
        push!(_j,i)
        push!(_v,row[1])
    end
    for offdiag in 1:n-1
        v = row[1+offdiag]
        if v != 0
            for i in 1:n-offdiag
                push!(_i,i)
                push!(_j,i+offdiag)
                push!(_v,v)
                push!(_i,i+offdiag)
                push!(_j,i)
                push!(_v,v)
            end
        end
    end
    sparse(_i,_j,_v,n,n)
end

export toeplitz
function toeplitz(row)
    Matrix(sptoeplitz(row))
end

end
