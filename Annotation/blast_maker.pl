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

$species=$ARGV[0];
$blast_step=$ARGV[1];
$blast_type=$ARGV[2];


##### PARAMETERS FOR MEGABLAST #####
# threshold e-value : -e	(ex: 2*10^-34 -> -e 2e-34)
# threshold bit score : -s	(ex: not under 200 -> -s 200)
# threshold %identity : -p	(ex: not under 80% -> -p 80)


$species2=$species;
$species2=~s/ /_/;


if ($blast_step eq "first")
{
	@db_tab=
	(
		"./Blast/First_blast/Databases/All_fishes_refseq_db",
		"./Blast/First_blast/Databases/Danio_rerio_cDNA_db",
		"./Blast/First_blast/Databases/Danio_rerio_gDNA_db",
		#"./Blast/First_blast/Databases/Gadus_morhua_cDNA_db",
		#"./Blast/First_blast/Databases/Gadus_morhua_gDNA_db",
		"./Blast/First_blast/Databases/Gasterosteus_aculeatus_cDNA_db",
		"./Blast/First_blast/Databases/Gasterosteus_aculeatus_gDNA_db",
		"./Blast/First_blast/Databases/Oreochromis_niloticus_cDNA_db",
		"./Blast/First_blast/Databases/Oreochromis_niloticus_gDNA_db",
		"./Blast/First_blast/Databases/Oryzias_latipes_cDNA_db",
		"./Blast/First_blast/Databases/Oryzias_latipes_gDNA_db",
		"./Blast/First_blast/Databases/Takifugu_rubripes_cDNA_db",
		"./Blast/First_blast/Databases/Takifugu_rubripes_gDNA_db",
		"./Blast/First_blast/Databases/Tetraodon_nigroviridis_cDNA_db",
		"./Blast/First_blast/Databases/Tetraodon_nigroviridis_gDNA_db",
		"./Blast/First_blast/Databases/Xiphophorus_maculatus_cDNA_db",
		"./Blast/First_blast/Databases/Xiphophorus_maculatus_gDNA_db"
	);
	$db_list=join(" ", @db_tab);

	$db_list_without_refseq=$db_list;
	$db_list_without_refseq=~s/.+_refseq_db //;

	opendir (DIR, "./Blast/First_blast/Fasta_for_blast");
	
	if ($blast_type eq "megablast")
	{
		@files_list=grep{$_=~m/$species2/ } readdir DIR;
		closedir DIR;
	
		foreach $fasta_file(@files_list)
		{
			chomp$fasta_file;
			print "First ".$blast_type." for ".$fasta_file." ...\n\n";
		
			$newfile=$fasta_file;
			$newfile=~s/\.fasta//;

			if ($fasta_file=~m/RefSeq/)
			{
				system("./Blast/Program/blast-2.2.25/bin/megablast", "-i", "./Blast/First_blast/Fasta_for_blast/".$fasta_file, "-d", "$db_list_without_refseq", "-F", "m L;V", "-m", "9", "-o", "./Blast/First_blast/Results/".$newfile."_-_".$blast_step."_-_megablast.result");
			}
			else
			{
				system("./Blast/Program/blast-2.2.25/bin/megablast", "-i", "./Blast/First_blast/Fasta_for_blast/".$fasta_file, "-d", "$db_list", "-F", "m L;V", "-m", "9", "-o", "./Blast/First_blast/Results/".$newfile."_-_".$blast_step."_-_megablast.result");
			}
		}
	}
	elsif ($blast_type eq "discontiguous")
	{
		@files_list=grep{$_=~m/Discontiguous_$species2/} readdir DIR;
		closedir DIR;
	
		foreach $fasta_file(@files_list)
		{
			chomp$fasta_file;
			print "First discontiguous megablast for ".$fasta_file." ...\n\n";
		
			$newfile=$fasta_file;
			$newfile=~s/Discontiguous_//;
			$newfile=~s/\.fasta//;

			system("./Blast/Program/blast-2.2.25/bin/megablast", "-i", "./Blast/First_blast/Fasta_for_blast/".$fasta_file, "-d", "$db_list_without_refseq", "-F", "m L;V", "-m", "9", "-t", "18", "-W", "11", "-A", "50", "-e", "1e-10", "-p", "70", "-o", "./Blast/First_blast/Results/".$newfile."_-_".$blast_step."_-_discontiguous.result");
		}
	}
}
elsif ($blast_step eq "reciprocal")
{
	opendir (DIR, "./Blast/Reciprocal_blast/Fasta_for_blast");
	@files_list=grep{$_=~m/$species2/ and $_=~m/$blast_type/} readdir DIR;
	closedir DIR;
	
	foreach $fasta_file(@files_list)
	{
		chomp$fasta_file;
		
		$file=$fasta_file;
		$file=~s/_-_first_-_megablast_-_result\.fasta//;
		$file=~s/_-_first_-_discontiguous_-_result\.fasta//;
		
		unless(-e "./Blast/Reciprocal_blast/Databases/".$file."_seqmask.counts")
		{
			print "Creating database ".$file." ...\n\n";

			system("./Blast/Program/ncbi-blast-2.2.25+/bin/windowmasker", "-in", "./Blast/First_blast/Fasta_for_blast/".$file.".fasta", "-infmt", "fasta", "-mk_counts", "-parse_seqids", "-out", "./Blast/Reciprocal_blast/Databases/".$file."_seqmask.counts");

			system("./Blast/Program/ncbi-blast-2.2.25+/bin/windowmasker", "-in", "./Blast/First_blast/Fasta_for_blast/".$file.".fasta", "-infmt", "fasta", "-ustat", "./Blast/Reciprocal_blast/Databases/".$file."_seqmask.counts", "-outfmt", "maskinfo_asn1_bin", "-parse_seqids", "-out", "./Blast/Reciprocal_blast/Databases/".$file."_seqmask.asnb");

			system("./Blast/Program/ncbi-blast-2.2.25+/bin/makeblastdb", "-in", "./Blast/First_blast/Fasta_for_blast/".$file.".fasta", "-out", "./Blast/Reciprocal_blast/Databases/".$file."_db", "-dbtype", "nucl", "-parse_seqids", "-mask_data", "./Blast/Reciprocal_blast/Databases/".$file."_seqmask.asnb");

			print "\n\n";
		}

		if(-e "./Blast/Reciprocal_blast/Databases/".$file."_db.nal")
		{
			open (FILE, "./Blast/Reciprocal_blast/Databases/".$file."_db.nal");
			@file_content=<FILE>;
			close FILE;

			chomp$file_content[4];
			$db_list=$file_content[4];
			$db_list=~s/DBLIST //;
		}
		else
		{
			$db_list="./Blast/Reciprocal_blast/Databases/".$file."_db";
		}

		
		print "Reciprocal ".$blast_type." for ".$fasta_file." ...\n\n";
		
		if ($blast_type eq "megablast")
		{
			system("./Blast/Program/blast-2.2.25/bin/megablast", "-i", "./Blast/Reciprocal_blast/Fasta_for_blast/".$fasta_file, "-d", "$db_list", "-F", "m L;V", "-m", "9", "-o", "./Blast/Reciprocal_blast/Results/".$file."_-_".$blast_step."_-_megablast.result");
		}
		elsif ($blast_type eq "discontiguous")
		{
			system("./Blast/Program/blast-2.2.25/bin/megablast", "-i", "./Blast/Reciprocal_blast/Fasta_for_blast/".$fasta_file, "-d", "$db_list", "-F", "m L;V", "-m", "9", "-t", "18", "-W", "11", "-A", "50", "-e", "1e-10", "-p", "70", "-o", "./Blast/Reciprocal_blast/Results/".$file."_-_".$blast_step."_-_discontiguous.result");
		}
	
	}

}


exit;
