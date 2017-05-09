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

# Launcher to send the entire procedure for annotating GenBank sequences
# Realization via "MegaBlast" and "Discontiguous MegaBlast" on the species of references ENSEMBL, with the method of "reciprocal best hit", with sequences of references cDNA and genomic sequences

# INPUT PARAMETERS
# Table of species to annotate, with indication of the presence of contig (1) or not (0)
my %species_list=
(
	#"Oryzias latipes"=>0,
	"Oncorhynchus mykiss"=>0,
	#"Salmo salar"=>1,
	#"Gadus morhua"=>1,
	#"Dicentrarchus labrax"=>0,
	#"Sparus aurata"=>0
	#"Gillichthys mirabilis"=>0
);



foreach $species(sort keys %species_list)
{
	system("perl","filledDB_annotation_RNAseq.pl","$species");

	#~ # ------------------------------------   MEGABLAST   ------------------------------------- #

	system("perl", "blast_maker_RNAseq.pl", $species, "first", "megablast");
	system("perl", "parsing_blast_results_RNAseq.pl", $species, "first", "megablast");
	system("perl", "blast_maker_RNAseq.pl", $species, "reciprocal", "megablast");
	system("perl", "R_parsing_blast_results_RNAseq.pl", $species, "reciprocal", "megablast");
	system("perl", "annotation_RNAseq.pl", $species, "megablast", $species_list{$species});


	system("perl", "prepare_discontiguous_RNAseq.pl", $species, $species_list{$species});


	#~ # ------------------------------   DISCONTIGOUS MEGABLAST   ------------------------------ #

	system("perl", "blast_maker_RNAseq.pl", $species, "first", "discontiguous");
	system("perl", "parsing_blast_results_RNAseq.pl", $species, "first", "discontiguous");
	system("perl", "blast_maker_RNAseq.pl", $species, "reciprocal", "discontiguous");
	system("perl", "R_parsing_blast_results_RNAseq.pl", $species, "reciprocal", "discontiguous");
	system("perl", "annotation_RNAseq.pl", $species, "discontiguous", $species_list{$species});
	
	# finalisation of the annotation
	system("perl", "updating_final_annot_RNAseq.pl",$species);
}


exit;

