#! /bin/usr/perl -w
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
#$species="Oncorhynchus mykiss";

%species_conversion=
(
	"Oncorhynchus mykiss"=>"Omy",
	"Salmo salar"=>"Ssa",
	"Gadus morhua"=>"Gmr"
);



$species2=$species;
$species2=~s/ /_/;

###################  TO COMPLETE 
my $password="";
my $user="";
my $host="";


$dbh = DBI->connect("DBI:mysql:database=fishAndchips;host="$host, $user, $password);
$sth1 = $dbh->prepare("UPDATE annotations_".$species2." SET seq_length=? WHERE seq_id=?;");
$sth2 = $dbh->prepare("UPDATE Annotation_all_sequences SET seq_length=? WHERE seq_id=?;");






open(FILE, "./Species_to_annotate/".$species."/".$species_conversion{$species}.".seq.all");
@data=<FILE>;
close FILE;

print $species_conversion{$species}.".seq.all loaded !\n\n";






open (RNAFILE, "./Species_to_annotate/".$species."/mrna_list.txt");
@rna_listing=<RNAFILE>;
close RNAFILE;

open (ESTFILE, "./Species_to_annotate/".$species."/est_list.txt");
@est_listing=<ESTFILE>;
close ESTFILE;

open (TSAFILE, "./Species_to_annotate/".$species."/tsa_list.txt");
@tsa_listing=<TSAFILE>;
close TSAFILE;

open (REFSEQFILE, "./Species_to_annotate/".$species."/refseq_list.txt");
@refseq_listing=<REFSEQFILE>;
close REFSEQFILE;

unless(defined ($refseq_listing[0]))
{
	unlink "./Species_to_annotate/".$species."/refseq_list.txt";
}
else
{
	open (REFSEQFASTA, ">./Blast/First_blast/Fasta_for_blast/".$species2."_RefSeq.fasta");
}

open (RNAFASTA, ">./Blast/First_blast/Fasta_for_blast/".$species2."_mRNA.fasta");
open (TSAFASTA, ">./Blast/First_blast/Fasta_for_blast/".$species2."_TSA.fasta");
open (ESTFASTA, ">./Blast/First_blast/Fasta_for_blast/".$species2."_EST.fasta");

mkdir "./Species_to_annotate/".$species."/EST_per_contig";

$prec_contig="null";
open(CONTIGFILE, ">./Species_to_annotate/".$species."/EST_per_contig/".$prec_contig.".fasta");

$est_line=1;
$tsa_line=1;
$rna_line=1;
$refseq_line=0;
$start="null";

foreach $data_line(@data)
{
	if ($start ne "null")
	{
		if ( ($data_line=~m/^\n/) || ($data_line=~m/^>/) )
		{
			$start="null";
		}
		else
		{
			if ($start eq "rna")
			{
				print RNAFASTA $data_line;
			}
			if ($start eq "refseq")
			{
				print REFSEQFASTA $data_line;
			}
			if ($start eq "tsa")
			{
				print TSAFASTA $data_line;
			}
			if ($start eq "est")
			{
				print ESTFASTA $data_line;
				print CONTIGFILE $data_line;
			}
		}
	}


	if($data_line=~m/^>/)
	{
		$start="null";
	
		chomp$data_line;
		
		$contig=$data_line;
		$contig=~s/.+ug=//;
		$contig=~s/ \/.+//;
		
		$acc_id=$data_line;
		$acc_id=~s/.+gb=//;
		$acc_id=~s/ \/.+//;
		
		$seq_len=$data_line;
		$seq_len=~s/.+len=//;

		$sth1->execute($seq_len, $acc_id);
		$sth2->execute($seq_len, $acc_id);

	}
}


close RNAFASTA;
close TSAFASTA;
close ESTFASTA;
close CONTIGFILE;

if (-e "./Species_to_annotate/".$species."/refseq_list.txt")
{
	close REFSEQFASTA;
	unlink "./Species_to_annotate/".$species."/refseq_list.txt";
}

unlink "./Species_to_annotate/".$species."/mrna_list.txt";
unlink "./Species_to_annotate/".$species."/tsa_list.txt";
unlink "./Species_to_annotate/".$species."/EST_per_contig/null.fasta";

$sth1 -> finish;
$sth2 -> finish;
$dbh -> disconnect;

exit;
