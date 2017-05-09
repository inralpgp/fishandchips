#!/usr/bin/perl -w

my $dataset=$ARGV[0];
my $file=$ARGV[1];
my $knn_file=$ARGV[2];


print "=====> launch correction\n";

opendir(DIR, "$dataset/cluster");
@cluster_files=grep{$_=~m/cluster_/} readdir DIR;
closedir DIR;


foreach $cluster(sort @cluster_files)
{
	open (MATRIX, "$dataset/cluster/$cluster");
	@matrix=<MATRIX>;
	close MATRIX;
	
	%gene_tab=();
	foreach ($i=0; $i<scalar@matrix; ++$i)
	{
		chomp$matrix[$i];
		$matrix[$i]=~s/\t.+//;
		$gene_tab{$matrix[$i]}=0;
	}

	
	print "Printing new $cluster ...\n";
	
	open(NEWCLUST, ">$dataset/cluster/$cluster");
	open(KNNFILE, "$dataset/$knn_file");
	while(<KNNFILE>)
	{
		chomp$_;
		@line=split("\t", $_);
		
		if(exists $gene_tab{$line[0]})
		{
			$final_line=join("\t", @line);
			print NEWCLUST $final_line."\n";
		}
	}
	close KNNFILE;
	close NEWCLUST;
}

print "Printing new $file.analyzed.txt ...\n";

open (ANALYZED, ">$dataset/$file.analyzed.txt");	
foreach $cluster(sort @cluster_files)
{
	open (MATRIX, "$dataset/cluster/$cluster");
	@matrix=<MATRIX>;
	close MATRIX;
	
	if($cluster eq "cluster_1.txt")
	{
		print ANALYZED $matrix[0];
		chomp$matrix[0];
		@samples=split("\t", $matrix[0]);
		foreach $case(@samples)
		{
			$case="empty";
		}
		$empty_line=join("\t", @samples);
	}

	foreach ($i=1; $i<scalar@matrix; ++$i)
	{
		print ANALYZED $matrix[$i];
	}
	
	$j=0;
	while($j<10)
	{
		++$j;
		print ANALYZED $empty_line."\n";
	}
}
close ANALYZED;


system("./2-clusterisationEDC/cluster -f $dataset/$file.analyzed.txt -g 0 -e 1 -m c");

system("../../slcview-2.0/slcview.pl $dataset/$file.analyzed.cdt -xsize 20 -ysize 0.5 -atrresolution 150 -gtrresolution 100 -arraylabels 170 -genelabels 0 -spacing 5 -linecolor black -o $dataset/$file.analyzed.png");


exit;

