
struct CombinedConfusionMatrix
    matrices
    classlabels

    function CombinedConfusionMatrix(matrices;
                                                    classlabels=nothing)
        if classlabels == nothing
            _, n = size(matrices[1])
            classlabels = ["class $x" for x in 1:n]
        end

        new(matrices, classlabels)
    end

end

function checkedscore(a,b)
    b==0? 0:a/b
end

function score(c)
    m,n = size(c)
    sum([c[i,i] for i in 1:m])
end

function expandmatrix(matrix::Matrix)

    m, n = size(matrix)

    result = Matrix{Number}(m+2, n+2)

    result .= 0


    for row in 1 : m
        for col in 1: n
            result[row,col] = matrix[row,col]
        end

        result[row, n+1] = sum(matrix[row,:])
        rowscore = checkedscore(matrix[row,row], sum(matrix[row,:]))
        result[row, n+2] = rowscore
    end

    for col in 1: n
        result[m+1, col] = sum(matrix[:,col])
        colscore = checkedscore( matrix[col,col], sum(matrix[:,col]))
        result[m+2, col] = colscore
    end

    result[m+1, n+1] = sum(matrix)

    totalscore =   score(matrix) / sum(matrix)
    result[m+2, n+2] = totalscore

    result

end

function tohtml(confusionmatrix::CombinedConfusionMatrix)

    cms = confusionmatrix.matrices
    labels = confusionmatrix.classlabels
    
    cm = cms[1]
    m,n = size(cms[1])
    
    cms2 = expandmatrix.(cms)
    d = Float64.(cat(3, cms2...))
    sems = mapslices(StatsBase.sem, d, 3)
    means = mapslices(StatsBase.mean, d, 3)
    
    stream = IOBuffer()
    write(stream,"""<table>""")
    write(stream,"<tr>")
    write(stream,"""<th style="background:white; border:none;" colspan="2" rowspan="2"></th>""")
    write(stream,"""<th colspan="$m" style="background:none; text-align:center">Predicted class x&#770</th>""")
    write(stream,"</tr>")
    write(stream,"<tr>")
    for label in labels
        write(stream,"<th>$(label)</th>")
    end
    write(stream,"<th>Row total</th>")
    write(stream,"<th>Accuracy  P(x&#770|x)</th>")
    write(stream,"</tr>")
    write(stream,"<tr>")
    write(stream,"""<th rowspan="$m" style="height:6em;">""")
    write(stream,"""<div style="display: inline-block; -ms-transform: rotate(-90deg); -webkit-transform: rotate(-90deg); transform: rotate(-90deg);;">Actual<br />
class x</div>""")
    write(stream,"</th>")
    write(stream,"<th>$(labels[1])</th>")
    for j in 1:n
        write(stream,"""<td>$(@sprintf("%.2f",means[1,j])) &plusmn; $(@sprintf("%.2f",sems[1,j]))</td>""")
    end
    write(stream,"""<td>$(@sprintf("%.2f",means[1,n+1])) &plusmn; $(@sprintf("%.2f",sems[1,n+1]))</td>""") # Row total
    write(stream,"""<td>$(@sprintf("%.2f",means[1,n+2])) &plusmn; $(@sprintf("%.2f",sems[1,n+2]))</td>""") # Accuracy
    write(stream,"</tr>")
    for i in 2:length(labels)
        write(stream,"<tr>")
        write(stream,"<th>$(labels[i])</th>")
        for j in 1:n
            write(stream,"""<td>$(@sprintf("%.2f",means[i,j])) &plusmn; $(@sprintf("%.2f",sems[i,j]))</td>""")
        end
        write(stream,"""<td>$(@sprintf("%.2f",means[i,n+1])) &plusmn; $(@sprintf("%.2f",sems[i,n+1]))</td>""") # Row total
        write(stream,"""<td>$(@sprintf("%.2f",means[i,n+2])) &plusmn; $(@sprintf("%.2f",sems[i,n+2]))</td>""") # Accuracy
        write(stream,"</tr>")
    end
    write(stream,"<tr>")
    write(stream,"""<td style="background:white; border:none;"></td>""")
    write(stream,"<th>Column total</th>")
    for j in 1:length(labels)
        write(stream,"""<td>$(@sprintf("%.2f",means[m+1,j])) &plusmn; $(@sprintf("%.2f",sems[m+1,j]))</td>""")
    end
    write(stream,"""<td>$(@sprintf("%.2f",means[m+1,n+1])) &plusmn; $(@sprintf("%.2f",sems[m+1,n+1]))</td>""")
    write(stream,"</tr>")
    write(stream,"<tr>")
    write(stream,"""<td style="background:white; border:none;"></td>""")
    write(stream,"<th>Reliability P(x|x&#770)</th>")
    for j in 1:length(labels)
        write(stream,"""<td>$(@sprintf("%.2f",means[m+2,j])) &plusmn; $(@sprintf("%.2f",sems[m+2,j]))</td>""") # Reliability
    end
    write(stream,"""<td style="background:white; border:none;"></td>""")
    write(stream,"""<td>$(@sprintf("%.2f",means[m+2,n+2])) &plusmn; $(@sprintf("%.2f",sems[m+2,n+2]))</td>""")
    write(stream,"</tr>")
    write(stream,"</table>")
    String(stream)
end

Base.show(io::IO, ::MIME"text/html", c::CombinedConfusionMatrix) =
    print(io, tohtml(c))

