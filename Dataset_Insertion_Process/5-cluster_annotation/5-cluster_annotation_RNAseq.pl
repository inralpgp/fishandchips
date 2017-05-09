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

use strict;

################################################################################
### Script launching Gominer annotation                                      ###
################################################################################

use DBI;
###################  TO COMPLETE 
my $password="";
my $user="";
my $host="";

my $dbh=DBI->connect("DBI:mysql:database=fishAndchips;host="$host, $user, $password) or die $DBI::errstr;


my $dir=$ARGV[1];
my $dataset_list=$ARGV[0];


my $requete_clusters_srp = "
SELECT DISTINCT (cluster_id)
FROM gene_selection
WHERE idStudy = ?
";


my $requete_clusters_gene_id = "
SELECT DISTINCT (gene)
FROM gene_selection
WHERE idStudy = ?
AND cluster_id = ?
";

my $requete_puce_gb_acc = "
SELECT DISTINCT (gb_acc)
FROM array_design
WHERE array_id = ?
";


my $quel_srp = "
SELECT directory
FROM datasets
WHERE id = ?
";







my $sth_id=$dbh->prepare("SELECT id FROM datasets WHERE directory = ?");
my $sth1=$dbh->prepare("$requete_clusters_srp");
my $sth3=$dbh->prepare("$quel_srp");
my $sth6=$dbh->prepare("$requete_clusters_gene_id");        #########
my $sth7=$dbh->prepare("$requete_puce_gb_acc");



my @annotations_tab = (
	"annotations_Danio_rerio",
	"annotations_Dicentrarchus_labrax",
	"annotations_Gadus_morhua",
	"annotations_Gillichthys_mirabilis",
	"annotations_Oncorhynchus_mykiss",
	"annotations_Salmo_salar",
	"annotations_Sparus_aurata"
);



my @list = () ;

open(GO, $dataset_list) or die "impossible d'ouvrir $dataset_list ! \n" ;
while (<GO>)
{
	chomp;
	$_ =~ /([^\t]*)\t[^\t]*\t[^\t]*.*/ ;
	
	push(@list, "$1");
	#$1 : SRP
	#$2 : study
	#$3 : specie
}
close GO ;



my $file = "" ;

open(STAT,">./5-cluster_annotation/suivi_annotation_cluster.txt") ;

foreach $file (@list){
	chomp$file;

	my $gse=$file ;

	


	print STAT "$file\t";
  

	if(-e "$dir/$file/$file/cluster/cluster_1.txt"){
		mkdir("$dir/$file/$file/cluster/annotation/", 0777);
		print STAT "existe\t";
		open(DD,">$dir/$file/$file/cluster/annotation/liste_clusters.txt");

		$sth_id->execute($file);
		my $id = $sth_id->fetchrow_array;

		$sth1->execute($id);
		while(my ($cluster) = $sth1 -> fetchrow_array){


			my %gene_tab=();
			my %symbol_tab=();
			
			$sth6->execute($id, $cluster);
			while(my ($gene_id)= $sth6 -> fetchrow_array)
			{
				$gene_tab{$gene_id}=0;
			}

			my $tab = "" ;
			foreach $tab(sort @annotations_tab)
			{
				chomp$tab;
				
				my $req=$dbh->prepare("
					SELECT Annotation_gene_symbol
					FROM ".$tab."
					WHERE seq_id = ?
				");
				
				my $gene_id = "" ;
				foreach $gene_id(sort keys %gene_tab)
				{
					chomp$gene_id;
					my $test_symbol=$req->execute($gene_id);
					
					if($test_symbol==1)
					{
						delete($gene_tab{$gene_id});
						my $symbol=$req -> fetchrow_array;
						
						$symbol=~s/ \(.*//;
						
						$symbol_tab{$symbol}=0;
					}
				}
				
				$req->finish();
			}
			
			if(scalar keys %symbol_tab > 5)
			{
				print DD "$dir/$file/$file/cluster/annotation/cluster.$cluster\n";
				print "OK\n";
			}
			else
			{
				print "Less than 6 symbols! EXCLUSION\n"
			}
			
			

			open(RES,">$dir/$file/$file/cluster/annotation/cluster.$cluster");
			my $symbol = "" ;
			foreach $symbol(sort keys %symbol_tab)
			{
				chomp$symbol;
				if ($symbol ne "")
				{
					print RES "$symbol\n";
				}
			}
			close RES ;
		}
		close DD ;
		


		print "supression caractères spéciaux....\n" ;
		system("sed -i s/\\\'//g $dir/$file/$file/cluster/annotation/*");
		system("sed -i s/\\\"//g $dir/$file/$file/cluster/annotation/*");
		print "ok\n" ;



		mkdir("$dir/$file/$file/cluster/annotation/result/", 0777);
		system("rm $dir/$file/$file/cluster/annotation/result/*"); 

		my $gominer = "" ;
		
		

		open(FILE,">$dir/$file/$file/SymbolAllGenes$file.txt");
		
		my $reqSpecie="
		SELECT specie 
		FROM datasets 
		WHERE directory = ?
		";
		my $reqSpecieSRP= $dbh->prepare("$reqSpecie");
		$reqSpecieSRP->execute($file);
		my $specie2=$reqSpecieSRP->fetchrow_array;

		
		
		my $requeteDB ="
		SELECT distinct Annotation_gene_symbol 
		FROM annotations_".$specie2." 
		WHERE seq_id LIKE '".$file."%' 
		AND Annotation_gene_symbol IS NOT NULL
		";

		my $reqAllGenes=$dbh->prepare("$requeteDB");	
		my $DB_specie = "annotations_".$specie2;
		my $file2= "'".$file."%'";

		$reqAllGenes->execute();
		my %hash_gene_symbol=();
		while(my ($gene_symbol)= $reqAllGenes->fetchrow_array){

			$hash_gene_symbol{$gene_symbol}=0;
		}
		foreach my $Gensym (sort keys %hash_gene_symbol){

			$Gensym=~s/ \(.*//;

			print FILE "$Gensym\n";
		}
		close FILE;
		
		
		$gominer = "/usr/bin/java -Xms2000M -Xmx2000M -cp ./5-cluster_annotation/gominer_nov2011.jar gov.nih.nci.lmp.gominer.GOCommand -t $dir/$file/$file/SymbolAllGenes$file.txt -h $dir/$file/$file/cluster/annotation/liste_clusters.txt -d jdbc:mysql://localhost/gominer";
		$gominer .= " -j com.mysql.jdbc.Driver -u root -p 88Chinotoroke -r $dir/$file/$file/cluster/annotation/result/ -s all -o all -e se -a all -v all -m 1 -x true -y true > $dir/$file/$file/cluster/annotation/log_annot_process.txt";	

		system("$gominer") ;
		print "fini\n" ;
		print STAT "fini\n" ;


		print "\n\n\n";
	}
	else
	{
		print STAT "no futur. Ni dieu ni maitre !\n" ;
		print "no clusters\n\n\n" ;
	}
}
$sth1->finish();
$sth3->finish();
$sth_id->finish();
$sth6->finish();
$sth7->finish();
$dbh->disconnect;

close STAT ;

