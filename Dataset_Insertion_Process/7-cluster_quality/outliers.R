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
# Script de la methode de d?tection d'outliers
# En entree :
# les seuils (minbas, maxbas) et (minhaut, maxhaut)
# representent les echantillons retenus pour estimer
# le rang interquantile apres tri par moyenne croissante
# des valeurs par echantillons.
# En sortie :
# echbas : numero de colonne dans la matrice m 
#          correspondant a l'echantillon de moyenne la
#          plus basse.
# freqbas : frequence de valeurs outliers pour echbas
# echhaut et freqhaut : meme principe pour la moyenne
#          la plus haute. 
# --------------------------------------------------

outliers <- function(m,minbas=1/8,maxbas=1/4,minhaut=3/4,maxhaut=7/8) {
  no <- ncol(m)
  ng <- nrow(m)
  moy <- rep(0,no)
  for (i in 1:no) {
    moy[i] <- mean(m[,i])
  }
  
  ordm <- order(moy)
  ###########################################################################  TEST MIN VALUE 
  refmin <- floor(no*minbas)
  if (refmin==1) refmin <- 2
  
  refmax <- floor(no*maxbas)
  if (refmax<refmin) refmax <- refmin
  
  ref <- refmin:refmax
  v <- as.vector(m[,ordm[ref]])
  nv  <- length(v)
  ord <- order(v)
  iq1 <- floor(nv*0.25)
  iq3 <- floor(nv*0.75)
  q1  <- v[ord[iq1]]
  q3 <- v[ord[iq3]]
  iqr <- q3-q1
  seuil <- 1.5*iqr
  
  cnt <- 0
  ebas <- ordm[1]
  for (i in 1:ng) {
    if ((m[i,ebas]) < (q1-seuil)) {
      cnt <- cnt+1
    }
  }
  
  sbas <- cnt/ng
  #******************************************************************************************  
  
  
  ###########################################################################  TEST MAX VALUE  
  refmin <- floor(no*minhaut)
  refmax <- floor(no*maxhaut)
  if (refmax==no) refmax <- no-1
  if (refmin>refmax) refmin <- refmax
  ref <- refmin:refmax
  v <- as.vector(m[,ordm[ref]])
  nv  <- length(v)
  ord <- order(v)
  iq1 <- floor(nv*0.25)
  iq3 <- floor(nv*0.75)
  q1  <- v[ord[iq1]]
  q3 <- v[ord[iq3]]
  iqr <- q3-q1
  seuil <- 1.5*iqr
  
  
  cnt <- 0
  ehaut <- ordm[no]
  
  if(is.na(m[i,ehaut])){
    valx <-0
  }
  else{
    valx<-(m[i,ehaut])
  }
  
  for (i in 1:ng) {
    if ((valx) > (q3+seuil)){
      cnt <- cnt+1
    }
    
    #if ((m[i,ehaut]) > (q3+seuil)){
    #  cnt <- cnt+1
    #}  
    
  }
  #******************************************************************************************    
  
  shaut <- cnt/ng
  list(echbas=ebas,freqbas=sbas,echhaut=ehaut,freqhaut=shaut)
}

