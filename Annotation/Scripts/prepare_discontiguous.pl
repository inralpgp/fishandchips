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
$existing_contig=$ARGV[1];


###################  TO COMPLETE 
my $password="";
my $user="";
my $host="";

$dbh=DBI->connect("DBI:mysql:database=fishAndchips;host="$host, $user, $password);

$retrieve_est=$dbh->prepare("
SELECT `seq_id`
FROM `Annotation_all_sequences`
WHERE `seq_id` = ?
AND `blast_type` IS NULL;
");


if($existing_contig==1)
{
	$retrieve_contig=$dbh->prepare("
		SELECT DISTINCT( `contig_id` )
		FROM `Final_annotation`
		WHERE `species` = ?
		AND `blast_type` IS NULL;
	");

	$retrieve_contig->execute($species);

	while($contig_id=$retrieve_contig->fetchrow_array())
	{
		push(@contig_tab, $contig_id);
	}
	$contig_list=join(" - ", @contig_tab);
	$contig_list=$contig_list." - ";
	
	$retrieve_contig->finish;
}
else
{
	$retrieve_seq=$dbh->prepare("
		SELECT `seq_id`
		FROM `Final_annotation`
		WHERE `species` = ?
		AND `blast_type` IS NULL;
	");

	$retrieve_seq->execute($species);

	while($seq_id=$retrieve_seq->fetchrow_array())
	{
		push(@seq_tab, $seq_id);
	}
	$seq_list=join(" - ", @seq_tab);
	$seq_list=$seq_list." - ";
	
	$retrieve_seq->finish;
}



$species2=$species;
$species2=~s/ /_/;

opendir (DIR, "./Blast/First_blast/Fasta_for_blast");
@files_list=grep{$_=~m/$species2/ } readdir DIR;
closedir DIR;

foreach $file(sort @files_list)
{
	chomp $file;
			
	$newfile="Discontiguous_".$file;
	
	print "Creating ".$newfile." ...\n";
	
	$cpt=0;
	
	open (NEWFILE, ">./Blast/First_blast/Fasta_for_blast/".$newfile);
	
	open (FILE, "./Blast/First_blast/Fasta_for_blast/".$file);
	while(<FILE>)
	{
		if ( ($_=~m/^>(.+)_-_(.+)/) && ($existing_contig==1) )
		{
			$start=0;
			$contig_id=$1;
			$seq_id=$2;
			
			if($contig_list=~m/$contig_id - /)
			{
		
				if ($file=~m/EST\./)
				{
					$test=$retrieve_est->execute($seq_id);
				
					if ($test ne "0E0")
					{
						++$cpt;
						$start=1;
					}
				}
				else
				{
					++$cpt;
					$start=1;
				}
			}
		}
		
		if ( ($_=~m/^>(.+)/) && ($existing_contig==0) )
		{
			$start=0;
			$seq_id=$1;
			
			if($seq_list=~m/$seq_id - /)
			{
		
				if ($file=~m/EST\./)
				{
					$test=$retrieve_est->execute($seq_id);
				
					if ($test ne "0E0")
					{
						++$cpt;
						$start=1;
					}
				}
				else
				{
					++$cpt;
					$start=1;
				}
			}
		
		}
		
		if($start==1)
		{
			print NEWFILE $_;
		}
	}
	close FILE;
	close NEWFILE;
	
	print $cpt." sequences printed\n\n";
}


$retrieve_est->finish;
$dbh->disconnect;

exit;
