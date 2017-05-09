#!/usr/bin/perl
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

######################################################################
####Script testing correlation and pval of clusters , infos saved in DB ######
######################################################################

use DBI ;
###################  TO COMPLETE 
my $password="";
my $user="";
my $host="";

my $dbh=DBI->connect("DBI:mysql:database=fishAndchips;host="$host, $user, $password) or die $DBI::errstr;
my $sth1=$dbh->prepare("INSERT INTO quality_cluster_new (id,cluster_id,quality) VALUES(?,?,?)");
my $sth2=$dbh->prepare("SELECT id FROM datasets WHERE directory = ?");

my @files = () ;
my $dir=$ARGV[1];
my $dataset_list=$ARGV[0];


open(GO, $dataset_list) or die "impossible d'ouvrir $dataset_list ! \n" ;
while (<GO>)
{
	chomp;
	$_ =~ /([^\t]*)\t[^\t]*\t[^\t]*.*/ ;
	
	push(@files, "$1");
	#$1 : SRP
	#$2 : study
	#$3 : specie
}
close GO ;

my $file = "" ;


foreach $file (@files)
{
	chomp$file;
	
	my $gse=$file ;


	if(-e "$dir/$file/$file/cluster/cluster_1.txt")
	{
		print "\n";
		system("date");
	
		print "$file\t";
		$sth2->execute($file);
		my $id = $sth2->fetchrow_array;

		print "$file\tok\n" ;
		
		opendir DIR2, "$dir/$file/$file/cluster/";
		my @list_clusters = () ;
		@list_clusters = grep { $_ ne '.' and $_ ne '..' and $_ =~ /^cluster_[\d]*\.txt/} readdir DIR2 ;
		closedir DIR2 ;

		my $cluster = "" ;

		foreach $cluster (sort @list_clusters)
		{

			open (BATCHR, ">./7-cluster_quality/Launch.R") or print STDERR "Impossible de creer Launch.R\n ";
			print BATCHR "FILENAME = \"$file\"\n" ;
			print BATCHR "print(FILENAME)\n" ;

			print "$cluster\n" ;
			my $cluster_file = "" ;
			($cluster_file=$cluster) =~ s/\.txt// ;
			print BATCHR "CLUSTER = \"$cluster_file\"\n" ;	
			close BATCHR ;
			($numero_cluster=$cluster_file) =~ s/cluster_// ;
			system("R --vanilla --slave < ./7-cluster_quality/test_outliers_et_bruit.R > $dir/$file/$file/cluster/$cluster_file.R.log")== 0 or print STDERR "R script failed\n\n";
			my $test1 = 0 ;
			if(-e "$dir/$file/$file/cluster/$cluster_file.R.log")
			{
			
				open(TOTO, "$dir/$file/$file/cluster/$cluster_file.R.log") or die "impossible d'ouvrir $cluster_file.txt\n" ;
				while(<TOTO>)
				{
					chomp;
					if($_ =~ /^pvalue=/) 
					{
						$_ =~ /pvalue= (.*) /;
						$sth1->execute($id,$numero_cluster,$1);
						$test1 = 1 ;
						last ;
					}
					
				}
				close TOTO ;
				if($test1 eq 0)
				{
					$sth1->execute($id,$numero_cluster,"NULL");
				}

			print "OKI\n";
			}
    	}
	}
	else {
		print "Pas de cluster pour $file !\n";
	}
}

exit;
