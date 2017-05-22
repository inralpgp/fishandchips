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

use DBI;

$species=$ARGV[0];


$spe_DB = $species;
$spe_DB =~s/ /_/;

%species_conversion=
(
	"Oncorhynchus mykiss"=>"Omy",
	"Salmo salar"=>"Ssa",
	"Gadus morhua"=>"Gmr"
);

###################  TO COMPLETE 
my $password="";
my $user="";
my $host="";

$dbh = DBI->connect("DBI:mysql:database=fishAndchips;host="$host, $user, $password);
$sth = $dbh->prepare("INSERT INTO annotations_".$spe_DB."(seq_id, species, type, clone_id, end, contig_id) VALUES (?, ?, ?, ?, ?, ?);");
$sth1 = $dbh->prepare("INSERT INTO Annotation_all_sequences(seq_id, species, type, contig_id) VALUES (?, ?, ?, ?);");
$sth2=$dbh->prepare("INSERT INTO Details_unigene_contigs (contig_id, title, gene_name, gene_id, unigene_expression) VALUES (?, ?, ?, ?, ?);");


open(FILE, "./Species_to_annotate/".$species."/".$species_conversion{$species}.".data");
@data=<FILE>;
close FILE;

print $species_conversion{$species}.".data loaded !\n\n";

open (REFSEQFILE, ">./Species_to_annotate/".$species."/refseq_list.txt");
open (MRNAFILE, ">./Species_to_annotate/".$species."/mrna_list.txt");
open (TSAFILE, ">./Species_to_annotate/".$species."/tsa_list.txt");
open (ESTFILE, ">./Species_to_annotate/".$species."/est_list.txt");

$first_refseq=0;
$first_mrna=0;
$first_tsa=0;
$first_est=0;

$gene="null";
$gene_id="null";
$express="null";


foreach $line (@data)
{
	if ($line=~m/^ID/)
	{
		chomp$line;
		$contig_id=$line;
		$contig_id=~s/ID +//;
		next;
	}
	
	if ($line=~m/^TITLE/)
	{
		chomp$line;
		$title=$line;
		$title=~s/TITLE +//;
		next;
	}
	
	if ($line=~m/^GENE /)
	{
		chomp$line;
		$gene=$line;
		$gene=~s/GENE +//;
		next;
	}
	
	if ($line=~m/^GENE_ID/)
	{
		chomp$line;
		$gene_id=$line;
		$gene_id=~s/GENE_ID +//;
		next;
	}
	
	if ($line=~m/^EXPRESS/)
	{
		chomp$line;
		$express=$line;
		$express=~s/EXPRESS +//;
		next;
	}
	
	
	
	if ($line=~m/^SEQUENCE/)
	{
		chomp$line;
		$line=~s/.+ACC=//;

		if ($line=~m/^NM_/)
		{
			if ($first_refseq==0)
			{
				print REFSEQFILE "\n".$contig_id;
				$first_mrna=1;
			}
			
			$line=~s/\..+//;
			print REFSEQFILE "\t".$line;
			
			$sth->execute($line, $species, "RefSeq", "null", "0", $contig_id);
			$sth1->execute($line, $species, "RefSeq", $contig_id);
		}
		elsif ( ($line=~m/SEQTYPE=mRNA/) && ($line=~m/PID=/) )
		{
			if ($first_mrna==0)
			{
				print MRNAFILE "\n".$contig_id;
				$first_mrna=1;
			}
			
			$line=~s/\..+//;
			print MRNAFILE "\t".$line;
			
			$sth->execute($line, $species, "mRNA", "null", "0", $contig_id);
			$sth1->execute($line, $species, "mRNA", $contig_id);
		}
		elsif ($line=~m/SEQTYPE=mRNA/)
		{
			if ($first_tsa==0)
			{
				print TSAFILE "\n".$contig_id;
				$first_tsa=1;
			}
			
			$line=~s/\..+//;
			print TSAFILE "\t".$line;
			
			$sth->execute($line, $species, "TSA", "null", "0", $contig_id);
			$sth1->execute($line, $species, "TSA", $contig_id);
		}
		elsif ($line=~m/SEQTYPE=EST/) 
		{
			if ($first_est==0)
			{
				print ESTFILE "\n".$contig_id;
				$first_est=1;
			}

			$gb_id=$line;
			$gb_id=~s/\..+//;
			print ESTFILE "\t".$gb_id;

			$clone_id="null";
			$end=0;

			if ($line=~m/CLONE=/)
			{
				$clone_id=$line;
				$clone_id=~s/.+CLONE=//;
				$clone_id=~s/; .+//;
			}

			if ($line=~m/END=/)
			{
				$end=$line;
				$end=~s/.+END=//;
				$end=~s/'; .+//;
			}

			$sth->execute($gb_id, $species, "EST", $clone_id, $end, $contig_id);
			$sth1->execute($gb_id, $species, "EST", $contig_id);
		}
		
		next;
	}
	
	if ($line=~m/\/\//)
	{
		$first_refseq=0;
		$first_mrna=0;
		$first_tsa=0;
		$first_est=0;
		
		$sth2->execute($contig_id, $title, $gene, $gene_id, $express);
	
		$contig_id="";
		$title="";
		$gene="null";
		$gene_id="null";
		$express="null";
	}
}
close REFSEQFILE;
close MRNAFILE;
close TSAFILE;
close ESTFILE;


$sth -> finish;
$sth1 -> finish;
$sth2 -> finish;
$dbh -> disconnect;

exit;
