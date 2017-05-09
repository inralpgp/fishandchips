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

#AUTHOR : Yann Echasseriau

# datasets list
my $liste=$ARGV[0];
# path to the directory containing the datasets
my $downdir=$ARGV[1];
# path to the working directory   # TO MODIFIED 
my $rootdir="/Fish_and_Chips/Dataset_insertion_process/1-normalization"; 

my $serie=1;


open(C, $liste) or die "Impossible de lire la liste\n" ;

my $count=0;
#$ligne = <C> ;
while(<C>){

	# Parsing dataset file
	chomp;
	$_ =~ /([^\t]*)\t[^\t]*\t([^\t]*)\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t([^\t]*)\t.*/ ;
	my $gse = $1 ;
	my $file = $2;
	my $channel_count = $3 ;

	$count++;

	print "\n#$count\nGSE: $gse\tFile: $file\tchannel_count: $channel_count\n";
	
	# Test to find the name of the matrix to normalized 
	if(-e "$downdir/$gse/$file/$file\_RAW.txt")
	{
		$filename=$file."_RAW";
	}
	elsif(-e "$downdir/$gse/$file/$file\_PROC.txt")
	{
		$filename=$file."_PROC";
	}
	else
	{
		print "<error> fichier absent \n" ;
		print "<end>\n\n";
		next;
	}
	


	if(-e "$downdir/$gse/$file/$filename.lowess.txt"){
		print "<congratulation> Lowess deja fait\n";
	}
	elsif (-e "$downdir/$gse/$file/$filename.norm.txt"){
		print "<congratulation> Norm deja fait\n";
	}
	else
	{
		# If datastet mono channel => normalisation lowess
	
		if($channel_count eq "1"){
			system("date");
			print "lowess en cours...\n" ;
			my $RDataOutput = "$rootdir/logs/Result_norm_mono_serie$serie.R";

			open (BATCHR, ">$rootdir/Launch$serie.R") or print STDERR "Impossible de créer Launch$serie.R\n ";
			print BATCHR "setwd(\"$downdir/$gse/$file/\") \n";
			print BATCHR "GDS = \"$filename\" \n";
			print BATCHR "serie = \"$serie\" \n";
			print BATCHR "source(\"$rootdir/normalize_mono.R\") \n";
			close BATCHR;
			system("R --no-save < $rootdir/Launch$serie.R >> $RDataOutput 2>&1")== 0 or print STDERR "R script failed";
			system("date");
			if(-e "$downdir/$gse/$file/$filename.lowess.txt"){
				print "<congratulation> Lowess OK\n";
			}
			else{
				print "<error> No output file from Lowess\n";
			}
		}
		else
		{	
			# If dual channel
			
			# Dual channel with RAW matrix=> normalisation lowess
			if (-e "$downdir/$gse/$file/$file"."_RAW.txt") ### fichier en "_RAW.txt" ----> RAW DUAL CHANNEL GEO !!!
			{
				system("date");
				print "lowess en cours...\n" ;
				my $RDataOutput = "$rootdir/logs/Result_norm_bi_raw_serie$serie.R";

				open (BATCHR, ">$rootdir/Launch$serie.R") or print STDERR "Impossible de créer Launch$serie.R\n ";
				print BATCHR "setwd(\"$downdir/$gse/$file/\") \n";
				print BATCHR "GDS = \"$filename\" \n";
				print BATCHR "serie = \"$serie\" \n";
				print BATCHR "source(\"$rootdir/normalize_mono.R\") \n";
				close BATCHR;
				system("R --no-save < $rootdir/Launch$serie.R >> $RDataOutput 2>&1")== 0 or print STDERR "R script failed";
				system("date");
				if(-e "$downdir/$gse/$file/$filename.lowess.txt")
				{
					print "<congratulation> Lowess OK\n";
				}
				else
				{
					print "<error> No output file from Lowess\n";
				}
					
			}
			# Dual channel with PROC matrix=> normalisation standard
			else 	### not "_RAW.txt" ----> RAW DUAL CHANNEL AE ou PROC DUAL CHANNEL AE ou GEO
			{
				system("date");
				print "normalisation lineaire en cours...\n" ;
				my $RDataOutput = "$rootdir/logs/Result_norm_bi$serie.R";
				open (BATCHR, ">$rootdir/Launch$serie.R") or print STDERR "Impossible de créer Launch$serie.R\n ";
				print BATCHR "setwd(\"$downdir/$gse/$file/\") \n";
				print BATCHR "GDS = \"$filename\" \n";
				print BATCHR "source(\"$rootdir/normalize_bi.R\") \n";
				close BATCHR;
				system("R --no-save < $rootdir/Launch$serie.R >> $RDataOutput 2>&1")== 0 or print STDERR "R script failed";
				system("date");
				if(-e "$downdir/$gse/$file/$filename.norm.txt"){
					print "<congratulation> Normalisation OK\n";
				}
				else{
					print "<error> No output file from Normalisation\n";
				}
				

			}
		}

	}

	print "<end>\n\n";

}
close C ;
