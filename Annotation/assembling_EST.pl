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

$species2=$species;
$species2=~s/ /_/;

###################  TO COMPLETE 
my $password="";
my $user="";
my $host="";

$dbh = DBI->connect("DBI:mysql:database=fishAndchips;host="$host, $user, $password);
$sth = $dbh->prepare("INSERT INTO Details_EST_assembling(contig_id, assembling, EST_id) VALUES (?, ?, ?);");
$sth2 = $dbh->prepare("INSERT INTO Annotation_contigs_assembled(species, contig_id, assembling, seq_length) VALUES (?, ?, ?, ?);");


open (FILE, "./Species_to_annotate/".$species."/est_list.txt");
@contig_list=<FILE>;
close FILE;

open (FILE, ">>./Blast/First_blast/Fasta_for_blast/".$species2."_EST_assembled.fasta");

foreach $contig_id(@contig_list)
{
	if($contig_id=~m/^\n/)
	{
		next;
	}

	chomp$contig_id;
	$contig_id=~s/\t.+//;

	$file=$contig_id.".fasta";

	mkdir "./Contig_assembler/temp_contig";
	
	system("cp", "./Species_to_annotate/".$species."/EST_per_contig/".$file, "./Contig_assembler/temp_contig/");

	system("./Contig_assembler/CAP3/cap3", "./Contig_assembler/temp_contig/".$file);



	open(CONTIGSFILE, "./Contig_assembler/temp_contig/".$file.".cap.contigs");
	@contigs_file=<CONTIGSFILE>;
	close CONTIGSFILE;

	foreach $line(@contigs_file)
	{
		$line=~s/^>/>_-_/;
		$line=~s/^>/>$contig_id/;
		print FILE $line;
	}



	open(RESFILE, "./Contig_assembler/temp_contig/".$file.".cap.ace");
	@results=<RESFILE>;
	close RESFILE;

	$contig_found=0;
	
	foreach $line(@results)
	{

		if ($line=~m/^CO/)
		{
			$contig_found=1;

			chomp$line;
			$assembling_id=$line;
			$assembling_id=~s/CO //;
			$assembling_id=~s/ .+//;

			$len=$line;
			$len=~s/CO $assembling_id //;
			$len=~s/ .+//;

			$sth2->execute($species, $contig_id, $assembling_id, $len);

		}

		if ($line=~m/^AF/)
		{
			chomp$line;
			$est_id=$line;
			$est_id=~s/AF //;
			$est_id=~s/ .+//;

			$sth->execute($contig_id, $assembling_id, $est_id);
		}
	}

	if ($contig_found==0)
	{
		$sth2->execute($species, $contig_id, "null", "0");
	}

	system("rm", "-r", "./Contig_assembler/temp_contig/");
}
close FILE;


$sth -> finish;
$sth2 -> finish;
$dbh -> disconnect;


exit;

