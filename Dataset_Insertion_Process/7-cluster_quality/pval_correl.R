# Copyright {2017} INRA (Institut National de Recherche Agronomique - FRANCE) 
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# --------------------------------------------------
# Script de la methode d'estimation de la qualite du 
# cluster. 
# 
# En entree : la matrice
# nsamples : le nombre de genes consid�r� 
#            dont on calcule toutes les paires
#            de correlation
# ntimes   : le nombre de fois qu'on calcule
#            sur n nouveaux samples.
# En sortie :
# la pvalue de correlation
# (moyenne des moyennes geometriques sur les nsamples)
# --------------------------------------------------

pvalcorrel <- function(mat,nsamples=100,ntimes=10) {
res <- 0
ng <- nrow(mat)
if (ng<=nsamples) {
res <- pvalcor(mat)
}
else {
for (k in 1:ntimes) {
sple <- sample(1:nrow(mat))
p <- pvalcor(mat[sple[1:nsamples],])
res <- res+p
}
res <- res/ntimes
}
res
}

pvalcor <- function(mat) {
nr <- nrow(mat)
np <- ncol(mat)
nb <- 0
meanpval <- 0
for (i in 1:(nr-1))
for (j in (i+1):nr) {
c <- cor.test(mat[i,],mat[j,],alternative="greater")
p <- c$p.value

if(is.na(p)) {
p=1
cat("p is NA, bad cluster\n")
}
if (p==0) p <- 10E-20
meanpval <- meanpval+log10(p)
nb <- nb+1
}
meanpval <- meanpval/nb
res <- 10^meanpval
res
}


