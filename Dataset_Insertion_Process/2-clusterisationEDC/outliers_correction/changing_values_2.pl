#!/usr/bin/perl

# Script pour le remplacement des valeurs détectée comme étant outliers par NA

my $dir="../Downloads-2012.08.19";
my $dataset=$ARGV[0];
my $round_num=$ARGV[1];
my $target=$ARGV[2];

print "=====> launch changing valus 2 .pl \n";

print "Scanning round_$round_num\.txt ...\n\n";
%outliers_tab=();
open(ROUND, "$dataset/outliers/round_$round_num\.txt");
while(<ROUND>)
{
	chomp$_;
	@line=split("\t", $_);
	
	if($outliers_tab{$line[0]})
	{
		$temp_val=$outliers_tab{$line[0]};
		$temp_val=$temp_val."\t".$line[1];
		$outliers_tab{$line[0]}=$temp_val;
	}
	else
	{
		$outliers_tab{$line[0]}=$line[1];
	}
}
close ROUND;


print "Printing temp matrix ...\n\n";

open (NEWMAT, ">$dataset/temp.txt");
open (MATRIX, "$dataset/$target");
@matrix=<MATRIX>;
close MATRIX;
foreach ($i=0; $i<scalar@matrix; ++$i)
{
	chomp$matrix[$i];
	@line=split("\t", $matrix[$i]);
	
	if($i==0)
	{
		for($j=1; $j<scalar@line; ++$j)
		{
			chomp$line[$j];
			$sample_tab{$line[$j]}=$j;
		}	
	}
	else
	{
		if($outliers_tab{$line[0]})
		{
			@case=split("\t", $outliers_tab{$line[0]});
			foreach $sample(@case)
			{
				foreach $sample_name(keys %sample_tab)
				{
					if ($sample_name=~m/^$sample\_\.\.\_|^$sample$/)
					{
						$pos=$sample_tab{$sample_name};
						$line[$pos]="NA";
					}
				}
			}
		}
	}
	$final_line=join("\t", @line);
	
	print NEWMAT "$final_line\n";
}
close NEWMAT;

unlink "$dataset/$target";
rename "$dataset/temp.txt", "$dataset/$target";

exit;

