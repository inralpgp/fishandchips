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

# Ce script prépare tous les arguments nécessaire au lancement des stats avec R

# Chargement des scripts pour réaliser les stats descriptives
source ("./1_bis-stats_descr/create_stats_des.R")
source ("./1_bis-stats_descr/create_correlation_median.R")

args <- commandArgs(TRUE)

files_list=args

# Lancemment des stats pour :
# 1 : la matrice brute
# 2: la matrice lowess
for(i in 2:length(files_list))
{

  print(files_list[i])

  # chargmment de la matrice
  raw_mat=read.delim(files_list[i], comment.char="", row.names=1)
  raw_mat[ is.na(raw_mat) ] <- 0
  
  file=sub(".+/", "", files_list[i])
  
  # Réalisation de l'image des stats
  output_file=paste(files_list[1], "/", sub(".txt", "_stats.jpg", file), sep="")
  create_stats_des(raw_mat, output_file)
  
  # Réalisation de l'image des pour les corrélations
  output_file=paste(files_list[1], "/", sub(".txt", "_corr.jpg", file), sep="")
  create_correlation_median(raw_mat, output_file)
}

q(save="no")

