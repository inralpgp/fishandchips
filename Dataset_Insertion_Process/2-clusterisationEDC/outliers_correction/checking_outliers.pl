#!/usr/bin/perl

# SCRIPT de préparation pour le lancemment de la détectuion des outliers sur chaque cluster trouvé précédemment par le programme "Noyau" 

my $dataset=$ARGV[0];
my $file=$ARGV[1];
my $round_num=$ARGV[2];
my $series=$ARGV[3];


print "======> launch checking_outliers\n";

if(-e "$dataset/cluster/cluster_1.txt")
{
	print "$file\tok\n" ;
	opendir DIR2, "$dataset/cluster/";
	my @list_clusters = () ;
	@list_clusters = grep {$_ =~ /^cluster_[\d]*\.txt/} readdir DIR2 ;
	closedir DIR2 ;

	my $cluster = "" ;

	foreach $cluster (sort @list_clusters)
	{
		chomp$cluster;
		
		open (BATCHR, ">./2-clusterisationEDC/outliers_correction/Launch".$series.".R") or print STDERR "Impossible de creer Launch.R\n ";
		print BATCHR "FILENAME = \"$file\"\n" ;

		print "$cluster\n\n" ;
		my $cluster_file = "" ;
		($cluster_file=$cluster) =~ s/\.txt// ;
		print BATCHR "CLUSTER = \"$cluster_file\"\n" ;
		print BATCHR "round=$round_num\n" ;
		print BATCHR "source(\"/home/ambre-aurore/bin/Fish_And_Chips_AAJ/Dataset_insertion_process/2-clusterisationEDC/outliers_correction/test_outliers_et_bruit.R\") \n";  # !!!!!!!!!!!! A MODIFIER !!!!!!!!!!!!!!!!!!!!!!
		close BATCHR ;
		($numero_cluster=$cluster_file) =~ s/cluster_// ;
		
		print "VANILLA\n";
		system("R --vanilla --slave < ./2-clusterisationEDC/outliers_correction/Launch".$series.".R")== 0 or print STDERR "R script failed";

	}
}
else
{
	print "Pas de cluster pour $file !\n";
}

exit;

