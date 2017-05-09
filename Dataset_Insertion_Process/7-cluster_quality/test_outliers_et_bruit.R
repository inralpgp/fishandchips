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
# Script de test de la methode 
# de détection d'outliers et d'estimation du bruit
#
# Le script élimine les echantillons dont la frequence
# est superieure à un seuil (seuilfreq). La matrice
# réduite est à nouveau testée dans la methode
# outliers jusqu'à ne plus obtenir d'outliers.
# Remarque : attention, les numeros de colonnes
# correspondent à la matrice d'entree et ne somt
# pas les rangs de la matrice initiale si on a elimine
# des échantillons.
# Apres elimination des echantillons outliers,
# on calcule la qualite du cluster avec la methode
# pvalcorrel.
# --------------------------------------------------

source("./7-cluster_quality/outliers.R")
source("./7-cluster_quality/pval_correl.R")
source("./7-cluster_quality/Launch.R")

#gse=sub("(-A-.+)|(-GPL.+)", "", FILENAME)

chemin = paste("../WorkingDirectoryInsertionProcess/",FILENAME,"/cluster/", sep="")
inputfile = paste(CLUSTER,".cdt", sep="")
print(chemin)
#message ("chemin : ",chemin)
setwd(chemin)


mat <- read.table(inputfile, skip=3, comment.char="", sep="\t")
mat <- mat[,5:ncol(mat)]
ng <- nrow(mat)
no <- ncol(mat)
m <- matrix(0,ng,no)
for (i in 1:ng) m[i,] <- as.numeric(mat[i,])
cat("line number=",ng,"column number=",no,"\n")

seuilfreq <- 0.25
reduce <- TRUE
while(reduce) {
    reduce <- FALSE
    cat("\nsample outlier detection\n")
    cat("-------------------------------\n")
    res <- outliers(m)
    cat("lower sample",res$echbas,"lower treshold=",res$freqbas)
    
    if (res$freqbas>seuilfreq) {
      m <- m[,setdiff(1:no,c(res$echbas))]
      reduce <- TRUE
      no <- ncol(m)
      cat(" : outlier")
    }
    cat("\nupper sample",res$echhaut,"upper treshold=",res$freqhaut)
    if (res$freqhaut>seuilfreq) {
      m <- m[,setdiff(1:no,c(res$echhaut))]
      reduce <- TRUE
      no <- ncol(m)
      cat(" : outlier")
    }
    cat("\n")
    
    if(no < 4) {
    	reduce <- FALSE	
    } 

}

cat("-------------------------------------------\n")
cat("\nnoise estimation on reduced matrix\n")
cat("-------------------------------------------\n")

p <- pvalcorrel(m)
cat("pvalue=",p,"\n")





