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

###################  TO COMPLETE 
my $password="";
my $user="";
my $host="";

my $dbh=DBI->connect("DBI:mysql:database=fishAndchips;host="$host, $user, $password) or die $DBI::errstr;  

my $sth1=$dbh->prepare("INSERT INTO gene_selection (idStudy,cluster_id,gene,gb_acc) VALUES(?,?,?,?)");
my $sth2=$dbh->prepare("SELECT id FROM datasets WHERE directory = ?");

my $sth3=$dbh->prepare("INSERT INTO datasets (directory,title,specie) VALUES(?,?,?)");

my $sth4=$dbh->prepare("SELECT GPL FROM datasets WHERE id = ?");

my $sth5=$dbh->prepare("SELECT gb_acc FROM array_design WHERE array_id = ? AND gene_id = ?;");
my $sth6=$dbh->prepare("SELECT gb_acc FROM array_design WHERE array_id = ? AND oligo_id = ?;");
my $sth7=$dbh->prepare("SELECT gb_acc FROM array_design WHERE array_id = ? AND clone_id = ?;");

my $sthTest=$dbh->prepare("SELECT idStudy FROM gene_selection WHERE idStudy = ? GROUP BY idStudy;");


my $dossier=$ARGV[1];
my $dataset_list=$ARGV[0];
my @list = () ;


open(GO, $dataset_list) or die "impossible d'ouvrir $dataset_list ! \n" ;
while (<GO>)
{
  chomp;
	$_ =~ /([^\t]*)\t([^\t]*)\t([^\t]*).*/ ;
	
  push(@list, "$1");
	#$1 : SRP
	#$2 : title
	#$3 : specie
	
	$srp=$1;
	$title=$2;
	$specie=$3;
	print $srp."***".$title."***".$specie."\n";

	$sth3->execute($srp,$title,$specie);	
}
close GO ;



my $file = "" ;
foreach $file (@list){
	chomp$file;

	my $file=$srp ;

	my $dossier2 = $dossier."/".$file."/".$file."/cluster/" ;
	print "dossier 2 : ".$dossier2."\n";
	my $test = $dossier2 . "cluster_1.txt" ;
	print "TEST : ".$test."\n";



	if(-e "$test"){
		print "$file\tok\n" ;
		opendir DIR2, $dossier2;
		
		my @list_clusters = () ;
		@list_clusters = grep { $_ ne '.' and $_ ne '..' and $_ =~ /^cluster_[\d]*\.txt/} readdir DIR2 ;
		closedir DIR2 ;
		
		print join("\t",@list_clusters)."\n";

		$sth2->execute($file);
		$id = $sth2->fetchrow_array;

		$resTest=$sthTest->execute($id);
		if($resTest eq "1"){
			print "genes already in table !\n";
			next;
		}
		

		my $cluster = "" ;
		foreach $cluster (sort @list_clusters){
			print "$cluster\n" ;
			my $numero_cluster = "" ;
			($numero_cluster=$cluster) =~ s/cluster_// ;
			$numero_cluster =~ s/\.txt// ;
			open C, "$dossier2$cluster" or die "impossible douvrir $dossier2$cluster !!\n";

			my $premiereligne = <C> ;
			while(<C>){
				chomp ;
				if($_ =~ /^NAME/ ){
				}	
				else{
					$_ =~ /([^\t]*)\t.*/;

					my $gb_acc = "" ;

					$sth1->execute($id,$numero_cluster,$srp."_".$1,$gb_acc);
				}
			}
			close C ;
		}
	}

	else{
		print "$file\tbad\n" ;
	}
}

$sth1->finish();
$sth2->finish();
$sth3->finish();
$sth4->finish();
$sth5->finish();
$sth6->finish();
$sth7->finish();
$sthTest->finish();
$dbh->disconnect;
