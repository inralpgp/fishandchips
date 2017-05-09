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


my $requete_clusters_gse = "
SELECT DISTINCT (cluster_id)
FROM gene_selection
WHERE id = ?
";

my $requete_clusters_gb_acc = "
SELECT DISTINCT (gb_acc)
FROM gene_selection
WHERE id = ?
AND cluster_id = ?
";

my $requete_puce_gb_acc = "
SELECT DISTINCT (gb_acc)
FROM array_design
WHERE array_id = ?
";

my $quel_gpl = "
SELECT GPL
FROM datasets
WHERE id = ?
";

my $sth_id=$dbh->prepare("SELECT id FROM datasets WHERE directory = ?");
my $sth1=$dbh->prepare("$requete_clusters_gse");
my $sth3=$dbh->prepare("$quel_gpl");
my $sth6=$dbh->prepare("$requete_clusters_gb_acc");
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
	$_ =~ /([^\t]*)\t[^\t]*\t([^\t]*)\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t([^\t]*)\t([^\t]*)\t.*/ ;
  push(@list, "$2");
  #$0 : path
  #$1 : GSE
  #$2 : GSE-GPL (file)
  #$3 : channel number
  #$4 : sample number
  
}
close GO ;

my $file = "" ;

open(STAT,">./5-cluster_annotation/suivi_annotation_cluster.txt") ;

foreach $file (@list)
{
	chomp$file;

	my $gse=$file ;
	$gse=~s/(-A-.+)|(-GPL.+)//;
	$gse=~s/a$|b$|c$|d$//;
	

  print "$file\n";
  
  
  print STAT "$file\t";
  
  if(-e "$dir/$gse/$file/cluster/cluster_1.txt")
  {
    mkdir("$dir/$gse/$file/cluster/annotation/", 0777);
    print STAT "existe\t";

    open(DD,">$dir/$gse/$file/cluster/annotation/liste_clusters.txt");

    $sth_id->execute($file);
    my $id = $sth_id->fetchrow_array;
    
    $sth1->execute($id);
    while(my ($cluster) = $sth1 -> fetchrow_array)
    {
    	print "cluster ".$cluster."\t";
    
    	my %gb_tab=();
    	my %symbol_tab=();
    	
    	$sth6->execute($id, $cluster);
    	while(my ($gb_acc)= $sth6 -> fetchrow_array)
    	{
    		$gb_tab{$gb_acc}=0;
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
		
		my $gb_acc = "" ;
		foreach $gb_acc(sort keys %gb_tab)
		{
			chomp$gb_acc;
			my $test_symbol=$req->execute($gb_acc);
			
			if($test_symbol==1)
			{
				delete($gb_tab{$gb_acc});
				my $symbol=$req -> fetchrow_array;
				
				$symbol=~s/ \(.*//;
				
				$symbol_tab{$symbol}=0;
			}
		}
		
		$req->finish();
	}
	
	if(scalar keys %symbol_tab > 5)
	{
		print DD "$dir/$gse/$file/cluster/annotation/cluster.$cluster\n";
		print "OK\n";
	}
	else
	{
		print "Less than 6 symbols! EXCLUSION\n"
	}

      	open(RES,">$dir/$gse/$file/cluster/annotation/cluster.$cluster");
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
    
    
    	print "Writing symbol for array\n";
    
    	$sth3->execute($id);
   	my $gpl = $sth3 -> fetchrow_array ;
    
    	my %gb_tab=();
    	my %symbol_tab=();
    	
    	$sth7->execute($gpl);
    	while(my ($gb_acc)= $sth7 -> fetchrow_array)
    	{
    		$gb_tab{$gb_acc}=0;
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
		
		my $gb_acc = "" ;
		foreach $gb_acc(sort keys %gb_tab)
		{
			chomp$gb_acc;
			my $test_symbol=$req->execute($gb_acc);
			
			if($test_symbol==1)
			{
				delete($gb_tab{$gb_acc});
				my $symbol=$req -> fetchrow_array;
				
				$symbol=~s/ \(.+//;
				
				$symbol_tab{$symbol}=0;
			}
		}
		
		$req->finish();
	}
    	open(PUCE,">$dir/$gse/$file/cluster/annotation/puce.txt") ;
    	my $symbol = "" ;
    	foreach $symbol(sort keys %symbol_tab)
	{
		chomp$symbol;
        	if ($symbol ne "")
        	{
        		print PUCE "$symbol\n";
        	}
    	  }
    	close PUCE ;
    	print STAT "processing\t" ;

	print "supression caractères spéciaux....\t" ;
	system("sed -i s/\\\'//g $dir/$gse/$file/cluster/annotation/*");
	system("sed -i s/\\\"//g $dir/$gse/$file/cluster/annotation/*");
	print "ok\n" ;



    mkdir("$dir/$gse/$file/cluster/annotation/result/", 0777);
    system("rm $dir/$gse/$file/cluster/annotation/result/*"); 


    my $gominer = "" ;
    $gominer = "/usr/lib/jvm/java-1.6.0-openjdk/bin/java -Xms2000M -Xmx2000M -cp ./5-cluster_annotation/gominer_nov2011.jar gov.nih.nci.lmp.gominer.GOCommand -t $dir/$gse/$file/cluster/annotation/puce.txt -h $dir/$gse/$file/cluster/annotation/liste_clusters.txt -d jdbc:mysql://localhost/gominer";
    $gominer .= " -j com.mysql.jdbc.Driver -u root -p nantes44 -r $dir/$gse/$file/cluster/annotation/result/ -s all -o all -e se -a all -v all -m 1 -x true -y true > $dir/$gse/$file/cluster/annotation/log_annot_process.txt";	

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

