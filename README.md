# ConfusionMatrices


```
using ConfusionMatrices
data = [121 1;3 200]
cm = ConfusionMatrix(data, classlabels=["Cats","Dogs"])
h = reprmime("text/html", cm)
```

<table><tr><th style="background:white; border:none;" colspan="2" rowspan="2"></th><th colspan="2" style="background:none; text-align:center">Predicted class x&#770</th></tr><tr><th>Cats</th><th>Dogs</th><th>Row total</th><th>Accuracy  P(x&#770|x)</th></tr><tr><th rowspan="2" style="height:6em;"><div style="display: inline-block; -ms-transform: rotate(-90deg); -webkit-transform: rotate(-90deg); transform: rotate(-90deg);;">Actual<br />
class x</div></th><th>Cats</th><td>121</td><td>1</td><td>122</td><td>0.99</td></tr><tr><th>Dogs</th><td>3</td><td>200</td><td>203</td><td>0.99</td></tr><tr><td style="background:white; border:none;"></td><th>Column total</th><td>124</td><td>201</td><td>325</td></tr><tr><td style="background:white; border:none;"></td><th>Reliability P(x|x&#770)</th><td>0.98</td><td>1.00</td><td style="background:white; border:none;"></td><td>0.99</td></tr></table>
