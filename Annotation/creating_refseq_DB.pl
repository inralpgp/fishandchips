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

# File allowing:
# 1) to copy the RefSeq (special formatting) sequences into a new fasta file and save the information provided for the NCBI for each RefSeq
# 2) create the necessary files to make them blasts
# 3) to blast each RefSeq against the reference genomes (only cDNA)
# 4) to parse the result of the blasts and to update the table "refseq" of the database

# WARNING !!!!!!!!!!!!!!
# It is necessary beforehand to recover all the RefSeq "fish" on NCBI via a query (details of the query in "RefSeq_query_NBCI") on their website. Then to download the result, rename the result file to "Fishes_RefSeq_sequences_original.fasta", and place that file in the "RefSeq" subfolder contained in the "Species_genome_ref" folder

use DBI;


###################  TO COMPLETE 
my $password="";
my $user="";
my $host="";

$dbh=DBI->connect("DBI:mysql:database=fishAndchips;host="$host, $user, $password);		
$req=$dbh->prepare("INSERT INTO refseq(seq_id, species, gene_name, gene_details) VALUES (?, ?, ?, ?);");
$req_up=$dbh->prepare("UPDATE refseq SET ensembl_transcript=? WHERE seq_id=?;");
$retrieve=$dbh->prepare("SELECT seq_id FROM refseq WHERE ensembl_transcript IS NULL;");



# Preparation of the file that will be used to create the files for the blasts (refseq as a reference) and saves in the database information for each RefSeq
print "Working on Fishes_RefSeq_sequences_original.fasta ...\n";
open (NEWFILE, ">./Blast/First_blast/Fasta_for_databases/All_fishes_refseq.fasta");
open (FILE, "./Species_genome_ref/RefSeq/Fishes_RefSeq_sequences_original.fasta");
while(<FILE>)
{
	if($_=~m/^\n/)
	{
		next;
	}


	if($_=~m/>gi\|\d+\|ref\|(NM_.+)\.\d+\| (\w+ \w+) (.+) (\(.+\),) .+/)
	{
		$seq_id=$1;
		$species=$2;
		$gene_details=$3;
		$gene_name=$4;
	
		$gene_name=~s/\(|\),//g;

		$req->execute($seq_id, $species, $gene_name, $gene_details);

		print NEWFILE ">".$seq_id."_-_All_fishes_refseq.fasta\n";
	}
	else
	{
		print NEWFILE $_;
	}
}
close FILE;
close NEWFILE;

print "\n\n";


#=cut

# Creating the necessary files for blasts (RefSeq database)

system("./Blast/Program/ncbi-blast-2.2.25+/bin/windowmasker", "-in", "./Blast/First_blast/Fasta_for_databases/All_fishes_refseq.fasta", "-infmt", "fasta", "-mk_counts", "-parse_seqids", "-out", "./Blast/First_blast/Databases/All_fishes_refseq_seqmask.counts");

system("./Blast/Program/ncbi-blast-2.2.25+/bin/windowmasker", "-in", "./Blast/First_blast/Fasta_for_databases/All_fishes_refseq.fasta", "-infmt", "fasta", "-ustat", "./Blast/First_blast/Databases/All_fishes_refseq_seqmask.counts", "-outfmt", "maskinfo_asn1_bin", "-parse_seqids", "-out", "./Blast/First_blast/Databases/All_fishes_refseq_seqmask.asnb");

system("./Blast/Program/ncbi-blast-2.2.25+/bin/makeblastdb", "-in", "./Blast/First_blast/Fasta_for_databases/All_fishes_refseq.fasta", "-out", "./Blast/First_blast/Databases/All_fishes_refseq_db", "-dbtype", "nucl", "-parse_seqids", "-mask_data", "./Blast/First_blast/Databases/All_fishes_refseq_seqmask.asnb");

print "\n\n";

#=cut

# List of reference genomes against which the RefSeq will be blasted
@db_tab=
(
	"./Blast/First_blast/Databases/Danio_rerio_cDNA_db",
	#"./Blast/First_blast/Databases/Gadus_morhua_cDNA_db",
	"./Blast/First_blast/Databases/Gasterosteus_aculeatus_cDNA_db",
	"./Blast/First_blast/Databases/Oreochromis_niloticus_cDNA_db",
	"./Blast/First_blast/Databases/Oryzias_latipes_cDNA_db",
	"./Blast/First_blast/Databases/Takifugu_rubripes_cDNA_db",
	"./Blast/First_blast/Databases/Tetraodon_nigroviridis_cDNA_db",
	"./Blast/First_blast/Databases/Xiphophorus_maculatus_cDNA_db",
);
$db_list=join(" ", @db_tab);


# Launch MegaBlast

print "Megablast for All_fishes_refseq.fasta ...\n\n";

system("./Blast/Program/blast-2.2.25/bin/megablast", "-i", "./Blast/First_blast/Fasta_for_databases/All_fishes_refseq.fasta", "-d", "$db_list", "-F", "m L;V", "-m", "9", "-o", "./Blast/First_blast/Results/All_fishes_refseq_-_megablast.result");



# Parsing of results and update of refseq table 

print "\nParsing All_fishes_refseq_-_megablast.result ...\n\n";

$score=0;
$prec="null";
open (FILE, "./Blast/First_blast/Results/All_fishes_refseq_-_megablast.result");
while(<FILE>)
{
	chomp$_;
	
	if ( ( ($_=~m/^# /)||(eof) ) && ($prec=~m/^\w+/) && ($score != 0) )
	{
		foreach $res(keys %all_scores)
		{
			$req_up->execute($res, $seq_id_query);
			
			last;
		}	
		$score=0;
		%all_scores=();
		$seq_id_query="toto";
	}
	
	if ( ($_=~m/^\w+/) && ($prec=~m/^# /) )
	{
		@line=split("\t", $_);
		
		$seq_id_query=$line[0];
		$seq_id_query=~s/_-_.+//;
				
		$score=$line[11];
	}
	
	if ($score != 0)
	{
		@line=split("\t", $_);
		
		if($line[11]>$score)
		{
			$score=$line[11];
			
			$transcript_id=$line[1];
			$transcript_id=~s/_-_.+//;
			
			%all_scores=();
			$all_scores{$transcript_id}=$line[11];
		}
		elsif ($line[11]==$score)
		{
			$transcript_id=$line[1];
			$transcript_id=~s/_-_.+//;
		
			$all_scores{$transcript_id}=$line[11];
		}
	}

	$prec=$_;
}
close FILE;


# Recovery of RefSeq that have not been annotated
$retrieve->execute();
while($seq_id=$retrieve->fetchrow_array())
{
	push(@seq_tab, $seq_id);
}
$seq_list=join(" - ", @seq_tab);
$seq_list=$seq_list." - ";

print "Creating Discontiguous_All_fishes_refseq.fasta ...\n\n";

open (NEWFILE, ">./Blast/First_blast/Fasta_for_blast/Discontiguous_All_fishes_refseq.fasta");
open (FILE, "./Blast/First_blast/Fasta_for_databases/All_fishes_refseq.fasta");
while(<FILE>)
{
	if($_=~m/^>(.+)_-_/)
	{
		$start=0;
	
		if($seq_list=~m/$1 - /)
		{
			$start=1;
		}
	}
		
	if($start==1)
	{
		print NEWFILE $_;
	}
}
close FILE;
close NEWFILE;



print "Discontiguous megablast for All_fishes_refseq.fasta ...\n\n";

system("./Blast/Program/blast-2.2.25/bin/megablast", "-i", "./Blast/First_blast/Fasta_for_blast/Discontiguous_All_fishes_refseq.fasta", "-d", "$db_list", "-F", "m L;V", "-m", "9", "-t", "18", "-W", "11", "-A", "50", "-o", "./Blast/First_blast/Results/All_fishes_refseq_-_discontiguous.result");




print "\nParsing All_fishes_refseq_-_discontiguous.result ...\n\n";

$score=0;
$prec="null";
open (FILE, "./Blast/First_blast/Results/All_fishes_refseq_-_discontiguous.result");
while(<FILE>)
{
	chomp$_;
	
	if ( ( ($_=~m/^# /)||(eof) ) && ($prec=~m/^\w+/) && ($score != 0) )
	{
		foreach $res(keys %all_scores)
		{
			$req_up->execute($res, $seq_id_query);
			
			last;
		}	
		$score=0;
		%all_scores=();
		$seq_id_query="toto";
	}
	
	if ( ($_=~m/^\w+/) && ($prec=~m/^# /) )
	{
		@line=split("\t", $_);
		
		$seq_id_query=$line[0];
		$seq_id_query=~s/_-_.+//;
				
		$score=$line[11];
	}
	
	if ($score != 0)
	{
		@line=split("\t", $_);
		
		if($line[11]>$score)
		{
			$score=$line[11];
			
			$transcript_id=$line[1];
			$transcript_id=~s/_-_.+//;
			
			%all_scores=();
			$all_scores{$transcript_id}=$line[11];
		}
		elsif ($line[11]==$score)
		{
			$transcript_id=$line[1];
			$transcript_id=~s/_-_.+//;
		
			$all_scores{$transcript_id}=$line[11];
		}
	}

	$prec=$_;
}
close FILE;


$req -> finish;
$req_up -> finish;
$retrieve -> finish;
$dbh -> disconnect;

exit;

