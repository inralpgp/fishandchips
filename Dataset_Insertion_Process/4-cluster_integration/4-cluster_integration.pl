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
# connexion to fishandchips database
###################  TO COMPLETE 
my $password="";
my $user="";
my $host="";

my $dbh=DBI->connect("DBI:mysql:database=fishAndchips;host="$host, $user, $password) or die $DBI::errstr; 

my $sth1=$dbh->prepare("INSERT INTO gene_selection (id,cluster_id,gene,gb_acc) VALUES(?,?,?,?)");
my $sth2=$dbh->prepare("SELECT id FROM datasets WHERE directory = ?");

my $sth3=$dbh->prepare("INSERT INTO datasets (directory,GSE,GPL,row_count,channel_count,pubmed_id,title,summary,design,sample_number,sample_species) VALUES(?,?,?,?,?,?,?,?,?,?,?)");

my $sth4=$dbh->prepare("SELECT GPL FROM datasets WHERE id = ?");

my $sth5=$dbh->prepare("SELECT gb_acc FROM array_design WHERE array_id = ? AND gene_id = ?;");
my $sth6=$dbh->prepare("SELECT gb_acc FROM array_design WHERE array_id = ? AND oligo_id = ?;");
my $sth7=$dbh->prepare("SELECT gb_acc FROM array_design WHERE array_id = ? AND clone_id = ?;");

my $sthTest=$dbh->prepare("SELECT id FROM gene_selection WHERE id = ? GROUP BY id;");


my $dossier=$ARGV[1];
my $dataset_list=$ARGV[0];
my @list = () ;


open(GO, $dataset_list) or die "impossible d'ouvrir $dataset_list ! \n" ;
while (<GO>)
{

  chomp;
	$_ =~ /([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t([^\t]*).*/ ;
	
  push(@list, "$3");
	#$0 : path
	#$1 : GSE
	#$2 : GPL
	#$3 : Directory (GSE-GPL, file)
	#$4 : Title
	#$5 : Summary
	#$6 : Design
	#$7 : PubMed ID
	#$8 : GPL row count
	#$9 : channel count
	#$10 : Sample number
	#$11 : Sample species
	#print $id_number."\n".$0."\n".$1."\n".$2."\n".$3."\n".$4."\n".$5."\n".$6."\n".$7."\n".$8."\n".$9."\n".$10."\n".$11."\n\n\n";

	$gse_number=$1;
	$gpl_number=$2;
	$directory=$3;
	$title=$4;
	$summary=$5;
	$design=$6;
	$pubmed_id=$7;
	$row_count=$8;
	$channel_count=$9;
	$sample_number=$10;
	$sample_species=$11;

	# insertion of informations about the datasets in DB, table datasets
	$sth3->execute($directory,$gse_number,$gpl_number,$row_count,$channel_count,$pubmed_id,$title,$summary,$design,$sample_number,$sample_species);	
}
close GO ;



my $file = "" ;
foreach $file (@list)
{
	chomp$file;

	my $gse=$file ;
	$gse=~s/(-A-.+)|(-GPL.+)//;
	$gse=~s/a$|b$|c$|d$//;
	

  my $dossier2 = $dossier."/$gse/$file/cluster/" ;
	my $test = $dossier2 . "cluster_1.txt" ;


  # if one or more cluster exists for a dataset
  if(-e "$test")
  {
    print "$file\tok\n" ;
    opendir DIR2, $dossier2;
    
    # retrieve info about clusters
    my @list_clusters = () ;
    @list_clusters = grep { $_ ne '.' and $_ ne '..' and $_ =~ /^cluster_[\d]*\.txt/} readdir DIR2 ;
    closedir DIR2 ;

    # retrieve infos about dataset
    $sth2->execute($file);
    $id = $sth2->fetchrow_array;
    
    # test if gene from a cluster are already in DB
    $resTest=$sthTest->execute($id);
    if($resTest eq "1")
    {
    	print "genes already in table !\n";
    	next;
    }
    
    # retrieve ID array
    my $array = "" ;
    $sth4->execute($id);
    $array = $sth4->fetchrow_array;

    # insertion genes from cluster in DB
    my $cluster = "" ;
    foreach $cluster (sort @list_clusters)
    {
      print "$cluster\n" ;
      my $numero_cluster = "" ;
      ($numero_cluster=$cluster) =~ s/cluster_// ;
	  $numero_cluster =~ s/\.txt// ;
      open C, "$dossier2$cluster" or die "impossible douvrir $dossier2$cluster !!\n";
      
      
	  my $premiereligne = <C> ;
      while(<C>)
      {
        chomp ;
		$_ =~ /([^\t]*)\t.*/;
		
		# retrieve GB accession
		my $gb_acc = "" ;
		$res_gene_id=$sth5->execute($array,$1);

		if($res_gene_id eq "0E0")
		{
			$res_oligo_id=$sth6->execute($array,$1);
	
			if($res_oligo_id eq "0E0")
			{
				$sth7->execute($array,$1);
				$gb_acc = $sth7->fetchrow_array;
			}
			else
			{
				$gb_acc = $sth6->fetchrow_array;
			}
		}
		else
		{
			$gb_acc = $sth5->fetchrow_array;
		}

		# insertion dataset id , cluster umber, gene ID
        	$sth1->execute($id,$numero_cluster,$1,$gb_acc);
      }
      close C ;
    }

  }

  else
  {
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
