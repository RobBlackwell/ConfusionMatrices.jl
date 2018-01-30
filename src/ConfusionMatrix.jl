
struct ConfusionMatrix
    matrix
    classlabels

    function ConfusionMatrix(tn, fp, fn, tp; classlabels=nothing)
        ConfusionMatrix([tn fp ;fn tp],classlabels=classlabels)
    end

    function ConfusionMatrix(matrix::Matrix; classlabels=nothing)
        if classlabels == nothing
            _, n = size(matrix)
            classlabels = ["class $x" for x in 1:n]
        end
        new(matrix, classlabels)
    end

end

function tohtml(confusionmatrix::ConfusionMatrix)
    cm = confusionmatrix.matrix
    labels = confusionmatrix.classlabels
    
    m,n = size(cm)
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
    for col in cm[1,:]
        write(stream,"<td>$col</td>")
    end
    write(stream,"<td>$(sum(cm[1,:]))</td>") # Row total
    write(stream,"""<td>$(@sprintf("%.2f",(cm[1,1] / (sum(cm[1,:])))))</td>""") # Accuracy
    write(stream,"</tr>")
    for i in 2:length(labels)
        write(stream,"<tr>")
        write(stream,"<th>$(labels[i])</th>")
        for col in cm[i,:]
            write(stream,"<td>$col</td>")
        end
        write(stream,"<td>$(sum(cm[i,:]))</td>") # Row total
        write(stream,"""<td>$(@sprintf("%.2f",(cm[i,i] / (sum(cm[i,:])))))</td>""") # Accuracy
        write(stream,"</tr>")
    end
    write(stream,"<tr>")
    write(stream,"""<td style="background:white; border:none;"></td>""")
    write(stream,"<th>Column total</th>")
    for j in 1:length(labels)
        write(stream,"<td>$(sum(cm[:,j]))</td>")
    end
    write(stream,"<td>$(sum(cm))</td>")
    write(stream,"</tr>")
    write(stream,"<tr>")
    write(stream,"""<td style="background:white; border:none;"></td>""")
    write(stream,"<th>Reliability P(x|x&#770)</th>")
    for i in 1:length(labels)
        write(stream,"""<td>$(@sprintf("%.2f",cm[i,i] / (sum(cm[:,i]))))</td>""") # Reliability
    end
    write(stream,"""<td style="background:white; border:none;"></td>""")
    write(stream,"""<td>$(@sprintf("%.2f",(sum([cm[i, i] for i = 1:m]) / sum(cm))))</td>""")
    write(stream,"</tr>")
    write(stream,"</table>")
    String(stream)
end

Base.show(io::IO, ::MIME"text/html", c::ConfusionMatrix) =
    print(io, tohtml(c))

