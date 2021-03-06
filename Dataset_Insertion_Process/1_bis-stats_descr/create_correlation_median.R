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

`create_correlation_median` <-
function (data,output_name,seuil=0.8)
##Correlation par rapport au profil median
{
  bottomarg = nchar(max(colnames(data))) #nombre de ligne pour la marge du bas
  prof_med = apply(data,1,median)
  correl=apply(data,2,cor,prof_med)
  pcol<-rep(1,ncol(data))
  badCor<-which(correl<seuil)
  pcol[badCor]=2
  jpeg(filename = output_name, width = 3000, height = 1800, quality = 100, bg = "white", res = NA)
  par(mar=c(bottomarg,5,3,3))
  plot(correl, type="l",xlab="", ylab="Correlation par rapport au profil median", ylim=c(0,1),cex.lab=1.5,cex.axis=1.5,xaxt="n")
  points(correl, col=pcol,xlab="",pch=19,cex=1.5, ylab="Correlation par rapport au profil median", ylim=c(0,1),cex.lab=1.5,cex.axis=1.5,xaxt="n")
  axis(1,1:dim(data)[2],labels=colnames(data),las="2",cex.axis=1.5)
  abline(h=seuil,col="red")
  abline(v=badCor,col="green")	
  dev.off()
	return(names(badCor))
}

