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
#$species="Sparus aurata";

$spe_DB=$species;
$spe_DB =~s/ /_/;

###################  TO COMPLETE 
my $password="";
my $user="";
my $host="";

$dbh = DBI->connect("DBI:mysql:database=fishAndchips;host="$host, $user, $password);
$sth= $dbh->prepare("INSERT INTO annotations_".$spe_DB."(seq_id, seq_length, species, type, clone_id, end) VALUES (?, ?, ?, ?, ?, ?);");
$sth1 = $dbh->prepare("INSERT INTO Annotation_all_sequences(seq_id, seq_length, species, type) VALUES (?, ?, ?, ?);");
$sth2 = $dbh->prepare("INSERT INTO Details_unigene_without_contig (seq_id, gene_name) VALUES (?, ?);");

$species2=$species;
$species2=~s/ /_/;


open(FILE, "./Species_to_annotate/".$species."/".$species2."_EST_sequences.fasta");
@est_seq=<FILE>;
close FILE;
print $species2."_EST_sequences.fasta loaded !\n\n";

open (FILE, ">./Blast/First_blast/Fasta_for_blast/".$species2."_EST.fasta");
foreach $line(@est_seq)
{
	if($line=~m/^>/)
	{
		chomp$line;
		$seq_id=$line;
		$seq_id=~s/>gi\|\d+\|\w+\|//;
		$seq_id=~s/\..+//;
		
		print FILE ">".$seq_id."\n";
		
		next;
	}
	
	unless ($line=~m/^\n/)
	{
		print FILE $line;
	}
}
close FILE;


open(FILE, "./Species_to_annotate/".$species."/".$species2."_EST_summary.txt");
@est_summary=<FILE>;
close FILE;
print $species2."_EST_summary.txt loaded !\n\n";

for ($i=0; $i<scalar @est_summary; ++$i)
{	
	if($est_summary[$i]=~m/ GI:/)
	{
		chomp $est_summary[$i];
		$seq_id=$est_summary[$i];
		$seq_id=~s/\..+//;
		
		chomp$est_summary[$i-1];
		$seq_length=$est_summary[$i-1];
		$seq_length=~s/ bp .+//;
		$seq_length=~s/,//;
		
		chomp$est_summary[$i-2];
		if($est_summary[$i-2]=~m/ clone /)
		{		
			$clone_id=$est_summary[$i-2];
			
			if($clone_id=~m/ similar /)
			{
				$clone_id=~s/ similar .+//;
			}
			
			$clone_id=~s/.+ clone //;
			
			if($clone_id=~m/ [35]-,? /)
			{
				$end=$clone_id;
				$end=~s/-.+//;
				$end=~s/.+ //;
				
				$clone_id=~s/ [35]-.+//;
				

				
				$sth->execute($seq_id, $seq_length, $species, "EST", $clone_id, $end);
				$sth1->execute($seq_id, $seq_length, $species, "EST");
			}
			else
			{
				$clone_id=~s/,? .+//;
			
				
				$sth->execute($seq_id, $seq_length, $species, "EST", $clone_id, "0");
				$sth1->execute($seq_id, $seq_length, $species, "EST");
			}
		}
		elsif ($est_summary[$i-2]=~m/ ([35])-,? /)
		{
			$end=$1;
			
			
			$sth->execute($seq_id, $seq_length, $species, "EST", "null", $end);
			$sth1->execute($seq_id, $seq_length, $species, "EST");
		}
		############## ONLY FOR SPARUS AURATA #######################
		elsif ( ($est_summary[$i-2]=~m/ IATS Aquamax /) || ($est_summary[$i-2]=~m/ Seabream ZAP Express /) || ($est_summary[$i-2]=~m/ Seabream cDN38 /) )
		{
			$clone_id=$est_summary[$i-2];
			$clone_id=~s/ IATS Aquamax .+//;
			$clone_id=~s/ Seabream ZAP Express .+//;
			$clone_id=~s/ Seabream cDN38 .+//;
			$clone_id=~s/^\d+\. //;
			
			$sth->execute($seq_id, $seq_length, $species, "EST", $clone_id, "0");
			$sth1->execute($seq_id, $seq_length, $species, "EST");
		}
		#######################################################################
		else
		{
			
			$sth->execute($seq_id, $seq_length, $species, "EST", "null", "0");
			$sth1->execute($seq_id, $seq_length, $species, "EST");
		}

	}
}



open(FILE, "./Species_to_annotate/".$species."/".$species2."_mRNA_sequences.fasta");
@mrna_seq=<FILE>;
close FILE;
print $species2."_mRNA_sequences.fasta loaded !\n\n";

open (FILE, ">./Blast/First_blast/Fasta_for_blast/".$species2."_mRNA.fasta");
foreach $line(@mrna_seq)
{
	if($line=~m/^>/)
	{
		chomp$line;
		$seq_id=$line;
		$seq_id=~s/>gi\|\d+\|\w+\|//;
		$seq_id=~s/\..+//;
		
		print FILE ">".$seq_id."\n";
		
		next;
	}
	
	unless ($line=~m/^\n/)
	{
		print FILE $line;
	}
}
close FILE;



open(FILE, "./Species_to_annotate/".$species."/".$species2."_mRNA_summary.txt");
@mrna_summary=<FILE>;
close FILE;
print $species2."_mRNA_summary.txt loaded !\n\n";

for ($i=0; $i<scalar @mrna_summary; ++$i)
{	
	if($mrna_summary[$i]=~m/ GI:/)
	{
		chomp $mrna_summary[$i];
		$seq_id=$mrna_summary[$i];
		$seq_id=~s/\..+//;
		
		chomp$mrna_summary[$i-1];
		$seq_length=$mrna_summary[$i-1];
		$seq_length=~s/ bp .+//;
		$seq_length=~s/,//;
		
		chomp$mrna_summary[$i-2];
		if ($mrna_summary[$i-2]=~m/ gene, /)
		{
			$gene_name=$mrna_summary[$i-2];
			$gene_name=~s/ gene, .+//;
			$gene_name=~s/.+ $species //;
			
			
			$sth2->execute($seq_id, $gene_name);
		}
		
		if ($mrna_summary[$i-2]=~m/ mRNA, /)
		{
			$gene_name=$mrna_summary[$i-2];
			$gene_name=~s/ mRNA, .+//;
			$gene_name=~s/.+ $species //;
			
			
			$sth2->execute($seq_id, $gene_name);
		}
		
		$sth->execute($seq_id, $seq_length, $species, "mRNA", "null", "0");
		$sth1->execute($seq_id, $seq_length, $species, "mRNA");	
	}
}



$sth -> finish;
$sth1 -> finish;
$sth2 -> finish;
$dbh -> disconnect;

exit;
