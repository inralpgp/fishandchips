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

use strict;
my $chemin = $ARGV[1];


######################################
## retrieve info from datasets ##
######################################

my $dataset_list=$ARGV[0];
my @list = () ;
my $i = 0 ;


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


for(my $j = 0 ; $j <= $#list ; $j++ )
{
	my $file = $list[$j] ;
	my $srp=$file ;


	##############################################
	##### Clustering for each cluster ###########
	#cluster + image 
	opendir DIR, "$chemin/$file/$file/cluster";
	my @listing_file = grep { $_ ne '.' and $_ ne '..' and $_ =~ /cluster_\d+\.txt/} readdir DIR;
	closedir DIR ;
	print "clustering + images des ";
	print scalar @listing_file;
	print " clusters en cours ...\n\n";

	my $groupetxt = "" ;
	foreach $groupetxt (sort @listing_file)
	{
		$groupetxt =~ s/\.txt// ;
		
		print $groupetxt."\n";
		
		system("./3_bis-clustering_clusters/cluster3 -f $chemin/$file/$file/cluster/$groupetxt.txt -l -cg m -g 1 -e 1 -m a");
		
		if(-e "$chemin/$file/$file/cluster/$groupetxt.png")
		{
			system("rm $chemin/$file/$file/cluster/$groupetxt.png");
		}
		if(-e "$chemin/$file/$file/cluster/$groupetxt.fix.png")
		{
			system("rm $chemin/$file/$file/cluster/$groupetxt.fix.png");
		}	

		system("../../slcview-2.0/slcview.pl $chemin/$file/$file/cluster/$groupetxt.cdt -xsize 20 -ysize 0.5 -atrresolution 150 -gtrresolution 100 -arraylabels 170 -genelabels 0 -spacing 5 -linecolor black -o $chemin/$file/cluster/$groupetxt.png");
		

		system("../../slcview-2.0/slcview.pl $chemin/$file/$file/cluster/$groupetxt.cdt -height 450 -width 300 -atrresolution 150 -gtrresolution 100 -arraylabels 170 -genelabels 0 -spacing 5 -linecolor black -o $chemin/$file/cluster/$groupetxt.fix.png");
	}	
	system("date");

	print "<end>\n\n\n\n";
} 



