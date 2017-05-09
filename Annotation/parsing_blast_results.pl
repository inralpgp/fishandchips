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
$blast_step=$ARGV[1];
$blast_type=$ARGV[2];

$species2=$species;
$species2=~s/ /_/;


###################  TO COMPLETE 
my $password="";
my $user="";
my $host="";


$dbh=DBI->connect("DBI:mysql:database=fishAndchips;host="$host, $user, $password);

$query_seq=$dbh->prepare('UPDATE Annotation_all_sequences SET blast_type=?, first_blast_id=?, first_blast_identity=?, `first_blast_e-value`=? WHERE seq_id=?;');
$query_contig=$dbh->prepare('UPDATE Annotation_contigs_assembled SET blast_type=?, first_blast_id=?, first_blast_identity=?, `first_blast_e-value`=? WHERE contig_id=? AND assembling=?;');


opendir (RESDIR, "./Blast/First_blast/Results");
@files_list=grep{$_=~m/$blast_step/ and $_=~m/$blast_type/ and $_=~m/$species2/ } readdir RESDIR;
closedir RESDIR;


foreach $file(sort@files_list)
{
	chomp$file;
	print "\nParsing ".$file." ...\n";
	

	%all_seq_for_fasta=();
	%all_scores=();
	$score=0;
	$prec=0;

	open (FILE, "./Blast/First_blast/Results/".$file);
	while(<FILE>)
	{
		chomp$_;
	
		if ( ( ($_=~m/^# /)||(eof) ) && ($prec=~m/^\w+/) && ($score != 0) )
		{
			foreach $res(keys %all_scores)
			{
				unless($res=~m/_gDNA\.fasta/)
				{
					@res_tab=split("\t", $res);
				
					$first_blast_id=$res_tab[1];
					$first_blast_id=~s/_-_.+//;
					
					print $res_tab[0]."\n";
					
					if($file=~m/EST_assembled/)
					{
						$contig_id=$res_tab[0];
						$contig_id=~s/_-_.+//;
						
						$assembling=$res_tab[0];
						$assembling=~s/.+_-_//;
					
						
						$query_contig->execute($blast_type, $first_blast_id, $res_tab[2], $res_tab[10], $contig_id, $assembling);
					}
					else
					{
						$seq_id=$res_tab[0];
						$seq_id=~s/.+_-_//;
						
						
						$query_seq->execute($blast_type, $first_blast_id, $res_tab[2], $res_tab[10], $seq_id);
					}
				
				
					$seq_name=$res_tab[1];
					$seq_name=" >".$seq_name;
				
					$seq_file=$res_tab[1];
					$seq_file=~s/.+_-_//;
			
					if(exists $all_seq_for_fasta{$seq_file})
					{
						$seq_for_fasta=$all_seq_for_fasta{$seq_file};
						$seq_for_fasta=$seq_for_fasta.$seq_name;
						$all_seq_for_fasta{$seq_file}=$seq_for_fasta;
					}
					else
					{
						$all_seq_for_fasta{$seq_file}=$seq_name;
					}
					
					last;
				}
			}
			
			$score=0;
			%all_scores=();
		}
	

		if ( ($_=~m/^\w+/) && ($prec=~m/^# /) )
		{
			@line=split("\t", $_);
			$seq_id_query=$line[0];
			$seq_id_query=~s/.+_-_//;
		
			$score=$line[11];
		}
	
		if ($score != 0)
		{
			@line=split("\t", $_);
		
			if($line[11]>$score)
			{
				$score=$line[11];
				%all_scores=();
				$all_scores{$_}=$line[11];
			}
			elsif ($line[11]==$score)
			{
				$all_scores{$_}=$line[11];
			}
		}

		$prec=$_;
	}
	close FILE;
	
	
	unless($file=~m/_EST_-_$blast_step/)
	{	
		$file=~s/\.result/_-_result\.fasta/;
	
		open (NEWFASTA, ">./Blast/Reciprocal_blast/Fasta_for_blast/".$file);
		foreach $file_to_open(sort keys %all_seq_for_fasta)
		{
			print "Searching sequences in ".$file_to_open." ...\n";
	
			open (FILE, "./Blast/First_blast/Fasta_for_databases/".$file_to_open);
			while(<FILE>)
			{
				if($_=~m/^>/)
				{
					$found=0;
					chomp$_;
			
					if($all_seq_for_fasta{$file_to_open}=~m/ $_/)
					{
						$found=1;
						print NEWFASTA $_."\n";
					}
					next;
				}
		
				if($found==1)
				{
					print NEWFASTA $_;
				}
			}
			close FILE;
		}
		close NEWFASTA;
		
	}
}

print "\n\n";	


$query_contig->finish;
$query_seq->finish;
$dbh->disconnect;


exit;
