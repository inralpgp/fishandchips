### Script qui fait le KNN pour remplacer les valeurs manquantes, et qui prépare les matrices pour la coupure des clusters

library(EMV)
print ("dye :")
print(dye)

if(dye==1)
{
	nomInput = paste(GDS,".lowess.txt",sep="")
}else
{
	if ( file.exists(paste(GDS,".lowess.txt",sep="")) )
	{
		nomInput = paste(GDS,".lowess.txt",sep="")
	}else
	{
		nomInput = paste(GDS,".norm.txt",sep="")
	}
}

print(nomInput)
data=read.delim(nomInput, comment.char="")

m=data
rownames(m)=m[,1]
m=data.matrix(m[,-1])

print("Dimension de la matrice : ")
print (dim(m))

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


## Renvoie une liste avec 2 elements : $data et $distance
#$data contient la matrice avec les valeurs manquantes remplacées
print("KNN...")
result_knn= knn(as.matrix(m), k=10, correlation=FALSE)
m = result_knn$data


##### Sauvegarde des remplacements effectués par KNN #####
temp_raw=m
nom_ech2=c()
for(i in 1:(length(nom_ech)+1))
{
	if(i==1)
	{
		nom_ech2[i]=""
	}else
	{
		nom_ech2[i]=nom_ech[i-1]
	}
}
temp_raw=cbind(nom_genes, temp_raw)
colnames(temp_raw)=nom_ech2
write.table(temp_raw,file=nomInput,quote=F, sep="\t", row.names=F, col.names=T)
rm(temp_raw, nom_ech2)




#knn pert le nom des genes et des ech
rownames(m)=nom_genes
colnames(m)=nom_ech


#####filtrage des valeurs faibles
print("Filtrage des valeurs faibles")
centile = quantile(m,probs=0.1)
centile = 2*centile
nb_sup_centile = apply(m>centile,1,sum) #nombre de val > à 2*10eme centile par gènes
seuil_centile = dim(m)[2]/10 # Seuil = 10 % des valeurs
m = m[nb_sup_centile>seuil_centile,]
#On recalcule le nom des genes puiqu'on en a supprime
nom_genes = rownames(m)
print("Dimension de la matrice : ")
print (dim(m))



######### RATIO ET PASSAGE EN LOG (pour les raw dual channel) DES DONNES NORMALISEES #########

if ( (dye==2) && (file.exists(paste(GDS,".lowess.txt",sep=""))) )
{
	if(file.exists("config_ratio.txt"))
	{
		config_ratio=read.table("config_ratio.txt", comment.char="")
		print("Ratio using config_ratio.txt")
	}
	

	col_list=c()
	for(i in 1:length(colnames(m)))
	{
		col_list[i]=sub("_\\.\\._.+", "", colnames(m)[i])
	}
	col_list=unique(col_list)


	for(i in 1:length(col_list))
	{
		cy3_col=NULL
		cy5_col=NULL
		temp_m=NULL
	
		for(j in 1:length(colnames(m)))
		{
			if( grepl("_\\.\\._cy3", colnames(m)[j], ignore.case=TRUE) && grepl(col_list[i], colnames(m)[j]) )
			{
				cy3_col=j
				next
			}

			if( grepl("_\\.\\._cy5", colnames(m)[j], ignore.case=TRUE) && grepl(col_list[i], colnames(m)[j]) )
			{
				cy5_col=j
				next
			}
		}
		
		if( (class(cy3_col)=="integer") && (class(cy3_col)=="integer") )
		{
			if(file.exists("config_ratio.txt"))
			{
	    			
				for(k in 1:length(config_ratio[,1]))
				{

					if( grepl(config_ratio[k,1], col_list[i]) && grepl("cy3", config_ratio[k,2], ignore.case=TRUE) )
					{
						temp_m=(m[1:length(rownames(m)),cy3_col])/(m[1:length(rownames(m)),cy5_col])
						break
					}
					
					if( grepl(config_ratio[k,1], col_list[i]) && grepl("cy5", config_ratio[k,2], ignore.case=TRUE) )
  					{
						temp_m=(m[1:length(rownames(m)),cy5_col])/(m[1:length(rownames(m)),cy3_col])
						break
					}
				}
			}else
			{	
				temp_m=(m[1:length(rownames(m)),cy3_col])/(m[1:length(rownames(m)),cy5_col])
				#temp_m=(m[1:length(rownames(m)),cy5_col])/(m[1:length(rownames(m)),cy3_col]) 	# POUR LES INVERSION !!
			}
			temp_m=matrix(temp_m)
			colnames(temp_m)=col_list[i]

			if(i==1)
			{
				new_m=temp_m
			}else
			{
				new_m=cbind(new_m, temp_m)
			}
		}
	}

	m=new_m
	m=log2(m)
}

#######################################################################




#### Centrage median des genes 
if(dim(m)[1]==0) print ("Attention matrice vide !") else 
{
	if(dye==1) {
		#centrage median et log 
		#car matrice issue de "1-normalization/normalize_mono.R" (LOWESS) donc PAS de log précedemment 
		prof_med = apply(m,1,median)
		m = m/prof_med
		m=log2(m)
		
		nomCol=c("NAME",colnames(m))
		m=cbind(nom_genes,m)
		colnames(m) = nomCol
		
		#creation fichier texte pour appliquer le programme de coupure des clusters
		new_name=sub("_.+", "", GDS)
		nomFile = paste(new_name,".lowess.knn.txt",sep="")
		write.table(m,file=nomFile,quote=F, sep="\t", row.names=F, col.names=T)
	}
	else 
	{
		#centrage median 
		#(les données ont été précedemment loguées par "1-normalization/normalize_bi.R" ou juste après les ratio)
		nomCol=c("NAME",colnames(m))
		m=cbind(nom_genes,m)
		colnames(m) = nomCol
		
		#creation fichier texte pour appliquer le programme de coupure des clusters
		new_name=sub("_.+", "", GDS)
		nomFile = paste(new_name,".norm.knn.txt",sep="")
		write.table(m,file=nomFile,quote=F, sep="\t", row.names=F, col.names=T)
	}
}






######### RATIO (pour les raw dual channel) DES DONNEES RAW #########

if ( (dye==2) && (grepl("_RAW", GDS)) )
{
	rm(m, new_m, temp_m)

	nomInput_raw = paste(GDS,".txt",sep="")
	print(nomInput_raw)
	m=read.delim(nomInput_raw, comment.char="")
	
	rownames(m)=m[,1]
	nom_genes = rownames(m)
	m=data.matrix(m[,-1])
	
	col_list=c()
	for(i in 1:length(colnames(m)))
	{
		col_list[i]=sub("_\\.\\._.+", "", colnames(m)[i])
	}
	col_list=unique(col_list)

	for(i in 1:length(col_list))
	{
		cy3_col=NULL
		cy5_col=NULL
		temp_m=NULL
	
		for(j in 1:length(colnames(m)))
		{
			if( grepl("_\\.\\._cy3", colnames(m)[j], ignore.case=TRUE) && grepl(col_list[i], colnames(m)[j]) )
			{
				cy3_col=j
				next
			}

			if( grepl("_\\.\\._cy5", colnames(m)[j], ignore.case=TRUE) && grepl(col_list[i], colnames(m)[j]) )
			{
				cy5_col=j
				next
			}
		}	
		
		if( (class(cy3_col)=="integer") && (class(cy3_col)=="integer") )
		{

			if(file.exists("config_ratio.txt"))
			{
	    			
				for(k in 1:length(config_ratio[,1]))
				{
					if( grepl(config_ratio[k,1], col_list[i]) && grepl("cy3", config_ratio[k,2], ignore.case=TRUE) )
					{
						temp_m=(m[1:length(rownames(m)),cy3_col])/(m[1:length(rownames(m)),cy5_col])
						break
					}

					if( grepl(config_ratio[k,1], col_list[i]) && grepl("cy5", config_ratio[k,2], ignore.case=TRUE) )
  					{
						temp_m=(m[1:length(rownames(m)),cy5_col])/(m[1:length(rownames(m)),cy3_col])
						break
					}
				}
			}else
			{	
				#temp_m=(m[1:length(rownames(m)),cy5_col])/(m[1:length(rownames(m)),cy3_col])		# POUR LES INVERSION !!
				temp_m=(m[1:length(rownames(m)),cy3_col])/(m[1:length(rownames(m)),cy5_col])
			}
			temp_m=matrix(temp_m)
			colnames(temp_m)=col_list[i]

			if(i==1)
			{
				new_m=temp_m
			}else
			{
				new_m=cbind(new_m, temp_m)
			}
		}
		
	}

	m=new_m
	
	nomCol=c("NAME",colnames(m))
	m=cbind(nom_genes,m)
	colnames(m) = nomCol
		
	#creation fichier texte pour appliquer le programme de coupure des clusters
	GDS=sub("_RAW", "", GDS)
	nomFile_raw = paste(GDS,".txt",sep="")
	write.table(m,file=nomFile_raw,quote=F, sep="\t", row.names=F, col.names=T)
}





