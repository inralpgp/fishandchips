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
$blast_step=$ARGV[1];	# "First" ou "Reciprocal"
$blast_type=$ARGV[2];	# "Megablast" ou "Discontiguous"



$species2=$species;
$species2=~s/ /_/;


###################  TO COMPLETE 
my $password="";
my $user="";
my $host="";

$dbh=DBI->connect("DBI:mysql:database=fishAndchips;host="$host, $user, $password);

$query_contig=$dbh->prepare("UPDATE Annotation_contigs_assembled SET reciprocal_blast_id=?, reciprocal_blast_identity=?, `reciprocal_blast_e-value`=? WHERE species=? AND blast_type=? AND first_blast_id=?;");

$query_contig2=$dbh->prepare("UPDATE Annotation_contigs_assembled SET reciprocal_blast_id=?, reciprocal_blast_identity=?, `reciprocal_blast_e-value`=? WHERE species=? AND blast_type=? AND first_blast_id=? AND `contig_id`=?;");

$query_seq=$dbh->prepare("UPDATE Annotation_all_sequences SET reciprocal_blast_id=?, reciprocal_blast_identity=?, `reciprocal_blast_e-value`=? WHERE species=? AND type=? AND blast_type=? AND first_blast_id=?;");

$query_seq2=$dbh->prepare("UPDATE Annotation_all_sequences SET reciprocal_blast_id=?, reciprocal_blast_identity=?, `reciprocal_blast_e-value`=? WHERE species=? AND type=? AND blast_type=? AND first_blast_id=? AND `seq_id`=?;");




opendir (RESDIR, "./Blast/Reciprocal_blast/Results");
@files_list=grep{$_=~m/$blast_step/ and $_=~m/$blast_type/ and $_=~m/$species2/ } readdir RESDIR;
closedir RESDIR;

foreach $file(sort@files_list)
{
	chomp$file;
	print "\nParsing ".$file." ...\n";
	
	$seq_type=$file;
	$seq_type=~s/$species2\_//;
	$seq_type=~s/_-_.+//;
	

	%all_scores=();
	$score=0;
	$prec=0;

	open (FILE, "./Blast/Reciprocal_blast/Results/".$file);
	while(<FILE>)
	{
		chomp$_;


		if ( ($score != 0) && ($_!~m/^# /) )
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

	
		if ( ( ($_=~m/^# /)||(eof) ) && ($prec=~m/^\w+/) && ($score != 0) )
		{


			foreach $res(keys %all_scores)
			{
				@res_tab=split("\t", $res);
				$seq_id=$res_tab[0];
				$seq_id=~s/_-_.+//;

				print $seq_id."\n";

				if ($file=~m/EST_assembled/)
				{
					$contig_id=$res_tab[1];
					$contig_id=~s/_-_.+//;
					
					if ($blast_type eq "discontiguous")
					{
						#print $contig_id."\t".$res_tab[2]."\t".$res_tab[10]."\t".$species."\t".$blast_type."\t".$seq_id."\t".$contig_id."\n";
						$query_contig2->execute($contig_id, $res_tab[2], $res_tab[10], $species, $blast_type, $seq_id, $contig_id);
					}
					else
					{
						if (scalar keys %all_scores == 1)
						{
							#print $contig_id."\t".$res_tab[2]."\t".$res_tab[10]."\t".$species."\t".$blast_type."\t".$seq_id."\n";
							$query_contig->execute($contig_id, $res_tab[2], $res_tab[10], $species, $blast_type, $seq_id);
					
						}
						elsif (scalar keys %all_scores >1)
						{

							#print $contig_id."\t".$res_tab[2]."\t".$res_tab[10]."\t".$species."\t".$blast_type."\t".$seq_id."\t".$contig_id."\n";
							$query_contig2->execute($contig_id, $res_tab[2], $res_tab[10], $species, $blast_type, $seq_id, $contig_id);
						}
					}
				}
				else
				{
					$res_id=$res_tab[1];
					$res_id=~s/.+_-_//;
					
					if ($blast_type eq "discontiguous")
					{
						#print $res_id."\t".$res_tab[2]."\t".$res_tab[10]."\t".$species."\t".$seq_type."\t".$blast_type."\t".$seq_id."\t".$res_id."\n";
						$query_seq2->execute($res_id, $res_tab[2], $res_tab[10], $species, $seq_type, $blast_type, $seq_id, $res_id);
					}
					else
					{
						if (scalar keys %all_scores == 1)
						{

							#print $res_id."\t".$res_tab[2]."\t".$res_tab[10]."\t".$species."\t".$seq_type."\t".$blast_type."\t".$seq_id."\n";
							$query_seq->execute($res_id, $res_tab[2], $res_tab[10], $species, $seq_type, $blast_type, $seq_id);
						}
						elsif (scalar keys %all_scores >1)
						{
							#print $res_id."\t".$res_tab[2]."\t".$res_tab[10]."\t".$species."\t".$seq_type."\t".$blast_type."\t".$seq_id."\t".$res_id."\n";
							$query_seq2->execute($res_id, $res_tab[2], $res_tab[10], $species, $seq_type, $blast_type, $seq_id, $res_id);
						}
					}
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
			$all_scores{$_}=$line[11];
		}

		$prec=$_;
	}
	close FILE;
}

print "\n\n";	


$query_contig->finish;
$query_contig2->finish;
$query_seq->finish;
$query_seq2->finish;
$dbh->disconnect;


exit;
