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

library(EMV)

nomInput = paste(GDS,".txt",sep="")
m=read.delim(nomInput, row.names=1, comment.char="")

print("Dimension de la matrice : ")
print (dim(m))


m=data.matrix(m)
#Suppression des 0
m[which(m[]==0)]=NA

##Filtre des gènes avec trop de NA
print("Filtrage des NA")
m_na=is.na(m)
nb_na=apply(m_na,1,sum)
seuil_na = dim(m)[2]/3 # Seuil = 33 % de valeurs à NA
m = m[nb_na<seuil_na,]
nom_genes = rownames(m)
nom_ech = colnames(m)
print("Dimension de la matrice : ")
print (dim(m))
print(head(m))

if(dim(m)[1]==0){
	print ("Attention matrice vide : Trop de NA")
}else
{
	## Centrage median des échantillons
	med=apply(m,2,median,na.rm=T)
print(head(med))

	#Test pour savoir si on est en log ou pas
	moy=mean(as.matrix(m),na.rm=T)
	print(moy)
	if(moy>15) { ## NON LOG : centrage=log(ratio)
		m_norm=log2(t(m)/med)
		m_norm=t(m_norm)
	}
	ifelse 
	{	## LOG : on soustrait pour centrer
		m_norm=t(m)-med
		m_norm=t(m_norm)
print(head(m_norm))
	}
	#creation fichier texte pour appliquer le programme de coupure des clusters
	nomFile = paste(GDS,".norm.txt",sep="")
	write.table(m_norm,file=nomFile,quote=F, sep="\t", row.names=T, col.names=NA)
}

