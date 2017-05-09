#!/usr/bin/perl -w
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

#AUTHOR : Yann Echasseriau, Ambre-Aurore Josselin




### PARAMETRES to modified before launching  ###
my $downDir=""; # path to the working dir
my $dataset_list=""; #path to dataset file datasets.txt


print "########################################################################\n";
print "                             STEP 0\n";
print "########################################################################\n";
#system("perl", "./0-selection_20000/0-selection_20000.pl", $dataset_list,$downDir);



print "########################################################################\n";
print "                             STEP 2\n";
print "########################################################################\n";
system("perl", "./2-clusterisationEDC/2-clusterisationEDC_RNAseq.pl", $dataset_list);

#system("perl", "./3-clustering/3-clustering.pl", $dataset_list, $downDir);

print "########################################################################\n";
print "                             STEP 3 bis\n";
print "########################################################################\n";
system("perl", "./3_bis-clustering_clusters/3_bis-clustering_clusters_RNAseq.pl", $dataset_list, $downDir);

print "########################################################################\n";
print "                             STEP 4\n";
print "########################################################################\n";
system("perl", "./4-cluster_integration/4-cluster_integration_RNAseq.pl", $dataset_list, $downDir);

print "########################################################################\n";
print "                             STEP 5\n";
print "########################################################################\n";
system("perl", "./5-cluster_annotation/5-cluster_annotation_RNAseq.pl", $dataset_list, $downDir); 

print "########################################################################\n";
print "                             STEP 6\n";
print "########################################################################\n";
system("perl", "./6-parse_result_gominer/6-parse_result_gominer_RNAseq.pl", $dataset_list, $downDir);

print "########################################################################\n";
print "                             STEP 7\n";
print "########################################################################\n";
system("perl", "./7-cluster_quality/7-cluster_quality_RNAseq.pl", $dataset_list, $downDir);

print "########################################################################\n";
print "                             STEP 8\n";
print "########################################################################\n";
system("perl", "./8-dataset_mean_quality/8-dataset_mean_quality_RNAseq.pl", $dataset_list);

print "########################################################################\n";
print "                             STEP 9\n";
print "########################################################################\n";
system("perl", "./9-orthologies/9-orthologies_RNAseq.pl", $dataset_list);

print "########################################################################\n";
print "                             STEP 10\n";
print "########################################################################\n";
system("perl","./10_textMining/10_textMining.pl", $dataset_list, $downDir);

exit;
