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

# Script for the parsing of ENSEMBL files containing all the information to be saved for the reference genomes
# And creation of the necessary files to realize the blasts

# WARNING !!!!!!!!!!!!!!
# It is necessary to download for each species of reference 4 files on the FTP of ENSEMBL:
# - a file ending with: "cdna.all.fa" (fasta file containing all the cDNA sequences of a species)
# - a file ending with: "dna_rm.toplevel.fa" (fasta file containing all the genomic sequences of a species)
# - a file ending with: "gtf" (file containing the "transcript" correspondence <-> "gene" for a species)
# - a file: "gene.txt" (file containing information on all the genes of a species, necessary to add to it at the beginning of name the species considered)
# Do not forget to place these 4 files in a subfolder named by the name of the species. This subfolder must be placed in the folder "genomeRefSpecies"

use DBI;

###################  TO COMPLETE 
my $password="";
my $user="";
my $host="";

$dbh=DBI->connect("DBI:mysql:database=fishAndchips;host="$host, $user, $password);		# Paramètres de connexion à modifier
$req=$dbh->prepare("INSERT INTO cDNA (transcript_id, species, gene_id, gene_name, gene_details, source, acc_num) VALUES (?, ?, ?, ?, ?, ?, ?);");

#list reference genome
@species_genome=
(
	"Danio rerio",
	"Gadus morhua",
	"Gasterosteus aculeatus",
	"Oreochromis niloticus",
	"Oryzias latipes",
	"Takifugu rubripes",
	"Tetraodon nigroviridis",
	"Xiphophorus maculatus"
);

my $dirGenRefSpe = "Species_genome_ref" ;

foreach $species(sort @species_genome)
{
	chomp$species;
	$species2=$species;
	$species2=~s/ /_/;
	


	opendir (DIR, "./".$dirGenRefSpe."/".$species);
	@files_list=grep{$_ ne '.' and $_ ne '..'} readdir DIR;
	close DIR;

	print  "liste fichier : \n".join("\n", @files_list)."\n\n";

	$gene_id="jeje";
	$gene_name="jeje";

	foreach $file(@files_list)
	{
		chomp$file;
	
		# fetch relationship gene<->transcript
		if($file=~m/\.gtf/)
		{
			print "Working on ".$file." ...\n";
			
			%gene_name_tab=();

			open (FILE, "./".$dirGenRefSpe."/".$species."/".$file);
			while(<FILE>)
			{
				chomp$_;

				if ($_=~m/gene_id "$gene_id"/)
				{
					next;
				}
				else
				{
					$gene_id=$_;
					$gene_name=$_;

					$gene_id=~s/.+gene_id "//;
					$gene_id=~s/"; .+//;

					if($gene_name=~m/gene_name/)
					{
						$gene_name=~s/.+gene_name "//;
						$gene_name=~s/";$|";.+$//;
					}
					else
					{
						$gene_name="null";
					}
					$gene_name_tab{$gene_id}=$gene_name;
				}			
			}
			close FILE;
		}
	}

	

	foreach $file(@files_list)
	{
		chomp$file;
		
		# fetch info about gene from a reference specie		
		if($file=~m/gene\.txt/)
		{
			print "Working on ".$file." ...\n";
			
			#%gene_details_tab=();

			open (FILE, "./".$dirGenRefSpe."/".$species."/".$file);
			while(<FILE>)
			{
				if($_=~m/.+\t.+\t.+\t.+\t.+\t.+\t.+\t.+\t.+\t(.+)\t(.+)\t.+\t.+\t(.+)\t.+\t.+\t.+/)
				{
					$gene_id=$3;

					if($2 eq '\N')
					{
						$gene_details_tab{$gene_id}="null///null///null";
					}
					else
					{
						$gene_detail=$2;
						$source=$2;
						$acc=$2;

						$gene_detail=~s/ \[.+\]//;

						$source=~s/.+\[Source://;
						$source=~s/;.+//;

						$acc=~s/.+;Acc://;
						$acc=~s/\]//;

						$gene_details_tab{$gene_id}=$gene_detail."///".$source."///".$acc;
						
					}
				}
			}
			close FILE;
		}
	}

	
	
	foreach $file(@files_list)
	{
		chomp$file;

		# Copy cDNA sequence from a specie 
		if($file=~m/\.cdna\.all\.fa/)
		{
			print "Working on ".$file." ...\n";

			open (NEWFILE, ">./Blast/First_blast/Fasta_for_databases/".$species2."_cDNA.fasta");

			open (FILE, "./".$dirGenRefSpe."/".$species."/".$file);
			while(<FILE>)
			{
				if($_=~m/^>(.+) .+ .+ gene:(.+)\.[0-9]+ gene.+/)
				{		
					$transcript_id=$1;
					$gene_id=$2;

					print NEWFILE ">".$transcript_id."_-_".$species2."_cDNA.fasta\n";
								
					
					if($gene_details_tab{$gene_id}=~m/(.+)\/\/\/(.+)\/\/\/(.+)/)
					{
						$gene_detail=$1;
						$source=$2;
						$acc=$3;
					}
					

					$req->execute($transcript_id, $species, $gene_id, $gene_name_tab{$gene_id}, $gene_detail, $source, $acc);
				}
				else
				{
					print NEWFILE $_;
				}
			}
			close FILE;
			close NEWFILE;
	
		}
	}

	
	print "\n\n";

	# Creation cDNA database

	system("./Blast/Program/ncbi-blast-2.2.25+/bin/windowmasker", "-in", "./Blast/First_blast/Fasta_for_databases/".$species2."_cDNA.fasta", "-infmt", "fasta", "-mk_counts", "-parse_seqids", "-out", "./Blast/First_blast/Databases/".$species2."_cDNA_seqmask.counts");

	system("./Blast/Program/ncbi-blast-2.2.25+/bin/windowmasker", "-in", "./Blast/First_blast/Fasta_for_databases/".$species2."_cDNA.fasta", "-infmt", "fasta", "-ustat", "./Blast/First_blast/Databases/".$species2."_cDNA_seqmask.counts", "-outfmt", "maskinfo_asn1_bin", "-parse_seqids", "-out", "./Blast/First_blast/Databases/".$species2."_cDNA_seqmask.asnb");

	system("./Blast/Program/ncbi-blast-2.2.25+/bin/makeblastdb", "-in", "./Blast/First_blast/Fasta_for_databases/".$species2."_cDNA.fasta", "-out", "./Blast/First_blast/Databases/".$species2."_cDNA_db", "-dbtype", "nucl", "-parse_seqids", "-mask_data", "./Blast/First_blast/Databases/".$species2."_cDNA_seqmask.asnb");

	print "\n\n";


	foreach $file(@files_list)
	{
		chomp$file;
	
		# copy genomic sequences from a specie
		if($file=~m/\.dna_rm\.toplevel\.fa/)
		{
			print "Working on ".$file." ...\n";

			open (NEWFILE, ">./Blast/First_blast/Fasta_for_databases/".$species2."_gDNA.fasta");

			open (FILE, "./".$dirGenRefSpe."/".$species."/".$file);
			while(<FILE>)
			{
				if($_=~m/^>/)
				{
					chomp$_;
					$seq_id=$_;

					$seq_id=~s/ .+//;

					print NEWFILE $seq_id."_-_".$species2."_gDNA.fasta\n";
				}
				else
				{
					print NEWFILE $_;
				}
			}
			close FILE;
			close NEWFILE;
		}
	}

	print "\n\n";
	
	# Creaion gDNA databases

	system("./Blast/Program/ncbi-blast-2.2.25+/bin/windowmasker", "-in", "./Blast/First_blast/Fasta_for_databases/".$species2."_gDNA.fasta", "-infmt", "fasta", "-mk_counts", "-parse_seqids", "-out", "./Blast/First_blast/Databases/".$species2."_gDNA_seqmask.counts");

	system("./Blast/Program/ncbi-blast-2.2.25+/bin/windowmasker", "-in", "./Blast/First_blast/Fasta_for_databases/".$species2."_gDNA.fasta", "-infmt", "fasta", "-ustat", "./Blast/First_blast/Databases/".$species2."_gDNA_seqmask.counts", "-outfmt", "maskinfo_asn1_bin", "-parse_seqids", "-out", "./Blast/First_blast/Databases/".$species2."_gDNA_seqmask.asnb");

	system("./Blast/Program/ncbi-blast-2.2.25+/bin/makeblastdb", "-in", "./Blast/First_blast/Fasta_for_databases/".$species2."_gDNA.fasta", "-out", "./Blast/First_blast/Databases/".$species2."_gDNA_db", "-dbtype", "nucl", "-parse_seqids", "-mask_data", "./Blast/First_blast/Databases/".$species2."_gDNA_seqmask.asnb");

	print "\n\n";
}

$req -> finish;
$dbh -> disconnect;


exit;

