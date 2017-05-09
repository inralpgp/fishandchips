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
#use strict;


######################################################################
####Script parsing results from Gominer, and put the five best results in DB 
 ######
######################################################################

use DBI;
###################  TO COMPLETE 
my $password="";
my $user="";
my $host="";

my $dbh=DBI->connect("DBI:mysql:database=fishAndchips;host="$host, $user, $password) or die $DBI::errstr;

my $sth1=$dbh->prepare("INSERT INTO cluster (id,cluster_id,GO_ID,GO_term,number_puce,number_cluster,p_value,R) VALUES(?,?,?,?,?,?,?,?)");
my $sth2=$dbh->prepare("SELECT id FROM datasets WHERE directory = ?");

my @files = () ;
my $dir=$ARGV[1];
my $dataset_list=$ARGV[0];


open(GO, $dataset_list) or die "impossible d'ouvrir $dataset_list ! \n" ;
while (<GO>)
{
  chomp;
	$_ =~ /([^\t]*)\t[^\t]*\t([^\t]*)\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t([^\t]*)\t([^\t]*)\t.*/ ;
  push(@files, "$2");
  
  #$0 : path
  #$1 : GSE
  #$2 : GSE-GPL (file)
  #$3 : channel number
  #$4 : sample number
}
close GO ;

my $file = "" ;

foreach $file (@files)
{
	chomp$file;
	
	
	my $gse=$file ;
	$gse=~s/(-A-.+)|(-GPL.+)//;
	$gse=~s/a$|b$|c$|d$//;

  print "$gse\t$file\t";

  
  
  if(-e "$dir/$gse/$file/cluster/annotation/")
  {
  
    if(-e "$dir/$gse/$file/cluster/annotation/formated_result/")
    {
    	system("rm -R $dir/$gse/$file/cluster/annotation/formated_result/");
    }
  
    mkdir("$dir/$gse/$file/cluster/annotation/formated_result/", 0777);

    my $dossier="$dir/$gse/$file/cluster/annotation/result/";
    

    unless(-e $dossier)
    {
    	print "Directory \"result\" NOT EXISTING !\n";
    	next;
    }

    opendir DIR, $dossier;
    my @list = grep { $_ ne '.' and $_ ne '..' and $_ =~ /^cluster/} readdir DIR ;
    closedir DIR;
    
    my $fichier = "" ;
    foreach $fichier (@list)
    {
      my $number = "" ;
      $fichier =~ /^cluster\.(\d*)_.*/ ;
      $number = $1 ;
      
      my $ligne = "" ;
      my @tab = () ;
      my $compteur = 0 ;
      open(AK,"$dir/$gse/$file/cluster/annotation/result/$fichier") or die "impossible d'ouvrir $dir/$gse/$file/cluster/annotation/result/$fichier \n" ;
      $ligne = <AK> ;
		my $total_puce = 0 ;
		my $total_cluster = 0 ;
      while(<AK>)
      {

        chomp ;
        $_ =~ s/,/\./g;
        $_ =~ /([^\t]*)\t([^\t]*)\t[^\t]*\t[^\t]*\t([^\t]*)\t[^\t]*\t[^\t]*\t([^\t]*)\t([^\t]*)/ ;
        $tab[$compteur][0] = $1 ; #GO_id
        $tab[$compteur][3] = $2 ; #nombre puce
        $tab[$compteur][2] = $3 ; # nombre cluster
        $tab[$compteur][1] = $4 ; #p_value
        $tab[$compteur][4] = $5 ; #GO term
		if($tab[$compteur][0] eq "all"){
		$total_puce = $tab[$compteur][3] ;
		$total_cluster = $tab[$compteur][2] ;
		}
        $compteur++ ;

      }
      close AK ;
      
		for(my $audrey = 0 ; $audrey <= $compteur ; $audrey ++ )
		{
			
			if($total_cluster >0 and $tab[$audrey][3] >0 and $total_puce >0)
			{
				$tab[$audrey][5] = ($tab[$audrey][2]/$total_cluster)/($tab[$audrey][3]/$total_puce) ; #enrichment
			}
		}
		
      @tab = sort byage @tab;
      
      open(RES,">$dir/$gse/$file/cluster/annotation/formated_result/cluster$number.txt") ;
      print RES "GO ID\tP-Value (Changed)\tChange\tTotal\tTerm\tR\n";
      for(my $i = 0 ; $i <= $#tab ; $i ++)
      {
		if($tab[$i][0] ne "")
		{
			print RES "$tab[$i][0]" ;
			for(my $j = 1 ; $j<= 5 ; $j++)
			{
			print RES "\t$tab[$i][$j]" ;
			}
			print RES "\n";
		}
      }
      close RES ;
      
      $sth2->execute($file);
      my $id = $sth2->fetchrow_array;


	my $nb_result = 0 ;
	my $fada = 0 ;
	while($nb_result < 5)
	{
		if($tab[$fada][1] < "0.001" and $tab[$fada][2] > 3 and $tab[$fada][0] ne "")
		{
			$sth1->execute($id,$number,$tab[$fada][0],$tab[$fada][4],$tab[$fada][3],$tab[$fada][2],$tab[$fada][1],$tab[$fada][5]);
			$tab[$fada][2] = 0 ; 
			$nb_result++ ;
		}
		if($fada > $compteur){ last;}
		$fada ++ ;
	}

	$fada = 0 ;
	if($nb_result < 5)
	{
		while($nb_result < 5)
		{
			if($tab[$fada][2] ne 0 and $tab[$fada][0] ne "")
			{
				$sth1->execute($id,$number,$tab[$fada][0],$tab[$fada][4],$tab[$fada][3],$tab[$fada][2],$tab[$fada][1],$tab[$fada][5]);
				$nb_result++ ;
			}
			$fada++ ;
			if($fada > $compteur) {last;} 
		}
	}
      print "ok\n" ;
    }
  }
  else
  {
  	print "Directory \"annotation\" NOT EXISTING !\n";
  }
}
$sth1->finish();
$sth2->finish();
$dbh->disconnect;

sub byage {
  $a1 = $$a[1];
  $b1 = $$b[1];
  $a1 <=> $b1;
}
