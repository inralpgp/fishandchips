# --------------------------------------------------
# Script de test de la methode 
# de d�tection d'outliers et d'estimation du bruit
#
# Le script �limine les echantillons dont la frequence
# est superieure � un seuil (seuilfreq). La matrice
# r�duite est � nouveau test�e dans la methode
# outliers jusqu'� ne plus obtenir d'outliers.
# Remarque : attention, les numeros de colonnes
# correspondent � la matrice d'entree et ne somt
# pas les rangs de la matrice initiale si on a elimine
# des �chantillons.
# Apres elimination des echantillons outliers,
# on calcule la qualite du cluster avec la methode
# pvalcorrel.
# --------------------------------------------------

source("./2-clusterisationEDC/outliers_correction/outliers.R")

gse=sub("(-A-.+)|(-GPL.+)", "", FILENAME)
gse=sub("a$|b$|c$|d$", "", FILENAME)


chemin = paste("../Downloads-Update-2013.02.18/",gse,"/",FILENAME,"/cluster/", sep="") # !!!!!!!!!!!! A MODIFIER !!!!!!!!!!!!!!!!!!!!!!
inputfile = paste(CLUSTER,".txt", sep="")
setwd(chemin)


##### SI A PARTIR DU FICHIER TXT ######
mat <- as.matrix(read.table(inputfile, comment.char="", sep="\t"))

sample_list=as.vector(as.matrix(mat[1,2:ncol(mat)]))
mat <- mat[2:nrow(mat),]

gene_list=as.vector(as.matrix(mat[1:nrow(mat),1]))
mat <- mat[,2:ncol(mat)]

ng <- nrow(mat)
no <- ncol(mat)
m <- matrix(0,ng,no)

for (i in 1:ng) m[i,] <- as.numeric(mat[i,])

#######################################



seuilfreq <- 0.25
reduce <- TRUE
while(reduce) {
reduce <- FALSE
res <- outliers(m)


if (res$freqbas>seuilfreq) {
  m <- m[,setdiff(1:no,c(res$echbas))]
  reduce <- TRUE
  no <- ncol(m)
  cat("\tdetection outlier")
  
  print_res=cbind(gene_list, sample_list[c(res$echbas)])
  write.table(print_res, file = paste("../outliers/round_", round, ".txt", sep=""), append=TRUE, quote=FALSE, sep="\t", row.names = FALSE, col.names = FALSE)
 
}

if (res$freqhaut>seuilfreq) {
  m <- m[,setdiff(1:no,c(res$echhaut))]
  reduce <- TRUE
  no <- ncol(m)
  cat("\tdetection outlier")
  
  print_res=cbind(gene_list, sample_list[c(res$echhaut)])
  write.table(print_res, file = paste("../outliers/round_", round, ".txt", sep=""), append=TRUE, quote=FALSE, sep="\t", row.names = FALSE, col.names = FALSE)

}

}
cat("\n")





