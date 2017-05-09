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


my $chemin = $ARGV[1];

######################################
## retrieve infos about GDS ##
######################################

my $dataset_list=$ARGV[0];
my @list = () ;
my $i = 0 ;


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


open(PLANTAGE, ">>./3-clustering/plantage-clustering_relance.txt") or die "impossible de créer ou compléter plantage-clustering_relance.txt\n" ;


#clustering after normalisation
for(my $j = 0 ; $j <= $#list ; $j++ )
{
	my $file = $list[$j] ;
	my $gse=$file ;
	$gse=~s/(-A-.+)|(-GPL.+)//;
	
	
	print "\n<begin>\n$file\n" ;
	
	if(-e "$chemin/$gse/$file/$file.lowess.knn.txt")
	{
		$extension="lowess";
	}
	elsif(-e "$chemin/$gse/$file/$file.norm.knn.txt")
	{
		$extension="norm";
	}
	else
	{
		print "Manque $chemin/$gse/$file/$file.lowess.knn.txt\n";
		print PLANTAGE "Manque $chemin/$gse/$file/$file.lowess.knn.txt\n";
		next;
	}
	

	## verified if clusters already exists 
	if (-e "$chemin/$gse/$file/$file.$extension.knn.gtr" && not -z "$chemin/$gse/$file/$file.$extension.knn.gtr") {
		system("date");
		print "Le clustering a deja ete fait\n";
	}
	elsif(-e "$chemin/$gse/$file/$file.$extension.knn.txt")
	{

		print "clustering $file.$extension.knn.txt...\n";
		system("date");
		open(TOTO,"$chemin/$gse/$file/$file.$extension.knn.txt");
		my $niania = 0 ;
		while(<TOTO>) {$niania++ ;}
		close TOTO;

		if($niania > 26000)
		{
			system("./3-clustering/cluster -f $chemin/$gse/$file/$file.$extension.knn.txt -g 1 -e 1 -m o");
			print "Gerard methode\n";
		}
		else
		{
			system("./3-clustering/cluster -f $chemin/$gse/$file/$file.$extension.knn.txt -g 1 -e 1 -m c");
		}
		if(-e "$chemin/$gse/$file/$file.$extension.knn.gtr")
		{
			if(-e "$chemin/$gse/$file/$file.$extension.knn.png")
			{
				system("rm $chemin/$gse/$file/$file.$extension.knn.png");
			}
			print "image $file.$extension.knn.png...\n";
			system("date");
			
			system("../../slcview-2.0/slcview.pl $chemin/$gse/$file/$file.$extension.knn.cdt -xsize 20 -ysize 0.1 -atrresolution 150 -gtrresolution 0 -arraylabels 170 -genelabels 0 -spacing 5 -linecolor black -o $chemin/$gse/$file/$file.$extension.knn.png");
			
			if(-e "$chemin/$gse/$file/$file.$extension.knn.png")
			{}
			else
			{
				print "Plantage image $file.$extension.knn.png\n";
				print PLANTAGE "Plantage image $file.$extension.knn.png\n";
			}
		}
		else
		{
			print "Plantage clustering $file.$extension.knn.txt\n";
			print PLANTAGE "Plantage clustering $file.$extension.knn.txt\n";	
		}
	}
	
	print "<end>\n\n\n";
}


print "CLUSTERING RAW DATA !!!!!!!!!!!! \n" ;

for(my $j = 0 ; $j <= $#list ; $j++ )
{
	my $file = $list[$j] ;
	my $gse=$file ;
	$gse=~s/(-A-.+)|(-GPL.+)//;
	
	

	print "\n<begin>\n$file\n" ;


	if(-e "$chemin/$gse/$file/$file.gtr" && not -z "$chemin/$gse/$file/$file.gtr"){
		system("date");
		print "Le clustering a deja ete fait\n";
	}

	elsif(-e "$chemin/$gse/$file/$file.txt")
	{
		
		print "clustering $file.txt...\n";
		system("date");
		open(TOTO,"$chemin/$gse/$file/$file.txt");
		my $niania = 0 ;
		$somme=0;
		$cpt_val=0;
		while(<TOTO>)
		{
			$niania++;
			
			if($niania>1)
			{
				chomp$_;
				@line=split("\t", $_);
				for($i=1; $i<scalar@line; ++$i)
				{
					unless($line[$i]=~m/[a-zA-Z]/)
					{
						$somme=$somme+$line[$i];
						++$cpt_val;
					}
				}
			}
		}
		close TOTO;
		
		$mean=$somme/$cpt_val;
		print "values mean: ".$mean."\t";

		
		
		if($niania > 26000)
		{
		
			if($mean<1)
			{
				print "values already in log\n";
				system("./3-clustering/cluster -f $chemin/$gse/$file/$file.txt -cg m -g 1 -e 1 -m o");
				print "Gerard methode\n";
			}
			else
			{
				print "log needed\n";
				system("./3-clustering/cluster -f $chemin/$gse/$file/$file.txt -l -cg m -g 1 -e 1 -m o");
				print "Gerard methode\n";
			}
		}
		else
		{

		
			if($mean<1)
			{
				print "values already in log\n";
				system("./3-clustering/cluster -f $chemin/$gse/$file/$file.txt -cg m -g 1 -e 1 -m c");
			}
			else
			{
				print "log needed\n";
				system("./3-clustering/cluster -f $chemin/$gse/$file/$file.txt -l -cg m -g 1 -e 1 -m c");
			}
		}
		
		if(-e "$chemin/$gse/$file/$file.gtr")
		{
			if(-e "$chemin/$gse/$file/$file.png")
			{
				system("rm $chemin/$gse/$file/$file.png");
			}
			print "image $file.png...\n";
			system("date");

			system("../../slcview-2.0/slcview.pl $chemin/$gse/$file/$file.cdt -xsize 20 -ysize 0.1 -atrresolution 150 -gtrresolution 0 -arraylabels 170 -genelabels 0 -spacing 5 -linecolor black -o $chemin/$gse/$file/$file.png");
			
			
			if(-e "$chemin/$gse/$file/$file.png")
			{}
			else
			{
				print "Plantage image $file.png\n";
				print PLANTAGE "Plantage image $file.png\n";
			}
		}
		else
		{
			print "Plantage clustering $file.txt\n";
			print PLANTAGE "Plantage clustering $file.txt\n";	
		}
	}
	else
	{
		print "Manque $chemin/$gse/$file/$file.txt\n";
		print PLANTAGE "Manque $chemin/$gse/$file/$file.txt\n";
	}
	print "<end>\n\n\n";

}

close PLANTAGE ;
