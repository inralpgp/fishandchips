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


#######################################
##### Fonctions ##########
#######################################

calculeNorm = function(increm, echantillon, lowessCurve, ref){
	result = echantillon[,increm]/lowessCurve[,increm]*ref
	result
}


#################################################
#    Programme lowess   		 	#
# Donnees d'importation : 	1 vecteur avec les donn�s d'un echantillon		#
#   	 et un vecteur ref qui correspond au profil median   #
#################################################

my.lowess = function(matriceW,vecRef,f){
# 	index = which(is.na(matriceW) | is.na(vecRef))
	index = which(is.finite(matriceW)==FALSE | is.finite(vecRef)==FALSE)

	index= as.numeric(index)
# 	indexVal = which(!is.na(matriceW) & !is.na(vecRef))
	indexVal = which(is.finite(matriceW)==TRUE & is.finite(vecRef)==TRUE)

	if (length(index)>=1) {
		print(paste("Presence de NA dans matriceW : ",length(index)))
		vecRef = vecRef[-index]
		matriceW2 = matriceW[-index]

		result = lowess(vecRef,matriceW2,f=f)
		temp = result$y	

		sortie = rep(NA,length(matriceW))
		sortie[indexVal]=temp	
		print(length(sortie))
	}
	
	else{ 
		result = lowess(vecRef,matriceW,f=f)
		sortie = result$y
	}
	sortie
}

traceGraph=function(increm, matData, ref, diagonal, lowessCurve=NULL,nomEchan,status,pngDir)
{
 		nom_fichier = paste(pngDir,nomEchan[increm],"_",status,".png",sep="")
		png(filename=nom_fichier)

    plot(ref,matData[,increm],log='xy', ylab=nomEchan[increm],pch=19,cex=0.8,cex.lab=1.5,cex.axis=1.5 )
    if(!is.null(lowessCurve)){
        lines(ref,exp(lowessCurve[,increm]),col=2,lwd=2)
    }
    lines(diagonal,diagonal,col=3,lwd=2)
    dev.off()
}

traceAvantApres=function(increm, matOrdonne, matNorm, nomEchan, pngDir)
{
		nom_fichier = paste(pngDir,nomEchan[increm],"_","3-AvantApres",".png",sep="")
		png(filename=nom_fichier)

    plot(matOrdonne[,increm],matNorm[,increm], log='xy', ylab=nomEchan[increm],pch=19,,cex=0.8,cex.lab=1.5,cex.axis=1.5)
    dev.off()
}



##################
# Programme principal
# 

#importation et conditionnement des donnees
# Au prelable les valeurs notes NUL ont ete remplaces par NA

#Le remplacement des valeurs vides par des NA est fait automatiquement
#Remplacement des NUL par des NA
matBruteBrut = read.delim(paste(GDS,".txt",sep=""))  ## table en character
nomGenes = matBruteBrut[,1]
#Je repasse tout en numeric ce qui remplace les NUL en NA
matBruteBrut = data.matrix(matBruteBrut[,-1])
rownames(matBruteBrut)=nomGenes
nomEchan = colnames(matBruteBrut)

print ("Dimension matBrute")
print (dim(matBruteBrut))

## Test pour savoir si les valeurs sont en LOG
# 0.01 percentiles min et max
percmin=quantile(matBruteBrut,0.02,na.rm=T)
percmax=quantile(matBruteBrut,0.999999,na.rm=T)

if(percmax<20) { # Donnees en LOG : on passe en exponentiel
print("Donnees en LOG")

	write.table(GDS,paste("/home/yann/WORKS/Fish_and_Chips/Dataset_insertion_process/1-normalization/logs/selection_GSE_log_s",serie,".txt", sep=""), quote=FALSE,append=T)		### !!!!!!!!!!! A MODIF
	matBrute=exp(matBruteBrut)
	percmax=exp(percmax)
	percmin=exp(percmin)
	matBrute[which(matBrute[]==Inf)]=exp(20)
} else 	matBrute=matBruteBrut
# matBrute=matBruteBrut

## Decalage des valeurs négatives restantes
if(percmin<0) {
	matBrute=matBrute+abs(percmin)+1 #On ajoute une constante à tout le mondee
	matBrute[which(matBrute[]<0)]=abs(percmin) #Au cas ou il reste des valeurs negatives
}


#Remplacement des 0 par des NA
matBrute[which(matBrute[]==0)]=NA


##Filtre des gènes avec trop de NA
print("Filtrage des NA")
m_na=is.na(matBrute)
nb_na=apply(m_na,1,sum)
seuil_na = dim(matBrute)[2]/3 # Seuil = 33 % de valeurs à NA
matBrute = matBrute[nb_na<seuil_na,]
print ("Dimension matBrute")
print (dim(matBrute))
#on recalcule le vecteur de noms de genes apres avoir eliminer les genes avec trop de NA
nomGenes = rownames(matBrute)


increm=c(1:dim(matBrute)[2])
lowessCurve = NULL

# Calcul du profil median et moyen
profil.median = apply(matBrute,1,median,na.rm=TRUE)
profil.mean = apply(matBrute,1,mean,na.rm=TRUE)

## Verifier que le jeu n'est pas centré sur les genes. dans ce cas, ne rien faire
#if((mean(profil.median,na.rm=TRUE)>=0 & mean(profil.median,na.rm=TRUE)<1) & (sd(profil.median,na.rm=TRUE)>=0 & sd(profil.median,na.rm=TRUE)<1) )
if((sd(profil.median,na.rm=TRUE)>=0 & sd(profil.median,na.rm=TRUE)<0.01) | (sd(profil.mean,na.rm=TRUE)>=0 & sd(profil.mean,na.rm=TRUE)<0.01) )
{	
	print("Jeu centre sur les genes !")
	write.table(GDS,paste("/home/yann/WORKS/Fish_and_Chips/Dataset_insertion_process/1-normalization/logs/poubelle_centrage_genes_s",serie,".txt", sep=""), quote=FALSE,append=T)			### !!!!!!!!!!! A MODIF
} else 
{
	######### Tri par ordre croissant des profils medians  #######
	#On ordonne la matrice par ordre croissant des profils m�ian
	ordre.profil = order(profil.median)
	
	#On range la matrice de d�art
	matOrdonne = matBrute[ordre.profil,]
	#On range le vecteur de profil median
	profilOrdonne = profil.median[ordre.profil]
	#On range le vecteur des noms de g�es
	nomGenes = as.character(nomGenes)
	nomGenes = nomGenes[ordre.profil]
	
	#################################################
	### Normalisation Lowess
	#################################################
	print("Lowess")
	normType="lowess"
	############# Lowess #######################
	
	if(dim(matBrute)[1]>10000) f=0.01 else f=0.1
	print("Taille fenetre lowess")
	print(f)
	
	lowessCurve = cbind(lowessCurve,apply(log(matOrdonne),2,my.lowess,log(profilOrdonne),f=f))
	# lowessCurve = cbind(lowessCurve,apply(matOrdonne,2,my.lowess,profilOrdonne,f=f))
		# Calcul de la matrice normalisee
	# 	matNormlog = sapply(increm, calculeNorm, log(matOrdonne), lowessCurve, log(profilOrdonne))
	matNorm = sapply(increm, calculeNorm, matOrdonne, exp(lowessCurve), profilOrdonne)
	# 	matNorm= round(exp(matNormlog),4)
	matNorm= round(matNorm,4)
	
	profilMedNorm = apply(matNorm,1,median,na.rm=TRUE)


	# ##############################
	graph=0
	pngDir="./"
	if(graph==1){	
		########## Plots ###########################
		diagonal=c(min(profilOrdonne,na.rm=T), max(profilOrdonne,na.rm=T))
		
		# Graphs avant normalisation pour tous les echantillons
		dev.set(dev.next())
		graph=sapply(increm, traceGraph, matOrdonne, profilOrdonne, diagonal, lowessCurve,nomEchan,"1-Avant", pngDir)
			
		# Graphs apres normalisation pour tous les echantillons
		dev.set(dev.next())
		graph=sapply(increm, traceGraph, matNorm, profilMedNorm, diagonal, NULL,nomEchan,"2-Apres", pngDir)
		
		#Graph valeurs brutes/valeurs normalisees
		dev.set(dev.next())
		graph=sapply(increm, traceAvantApres, matOrdonne, matNorm, nomEchan, pngDir)
	} ## If graph
		##############################


	################### Exportation des resultats
	# matFinale = data.frame(cbind(nomGenes,matNorm))
	# nomCol = c("NAME",nomEchan)
	# colnames(matFinale) = nomCol
	colnames(matNorm)=nomEchan
	
	nomFile = paste(GDS, ".",normType, ".txt", sep="")
	
	# write.table(matFinale,nomFile,sep="\t",col.names = TRUE,row.names = FALSE, quote=FALSE) 
	write.table(matNorm,nomFile,sep="\t",col.names=NA,row.names=T, quote=FALSE)
	print("Lowess OK")
}


