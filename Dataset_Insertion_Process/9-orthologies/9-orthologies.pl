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


######################################################################
#### Script allowing the updating of some tables necessary for the comparison of lists of genes via the PHP pages ######
#### table "ARRAY_GENE": to insert all the ENSEMBL and SYMBOL ids present in the array (id from the result of the annotation)
#### table "CLUSTER_GENE": to insert all the ENSEMBL and SYMBOL ids present in each cluster of a given dataset (id from the result of the annotation)
######################################################################


my $dataset_list=$ARGV[0];

use DBI;

###################  TO COMPLETE 
my $password="";
my $user="";
my $host="";

my $dbh=DBI->connect("DBI:mysql:database=fishAndchips;host="$host, $user, $password) or die $DBI::errstr;


		### UPDATE ON `array_gene` FOR NEW ARRAY ###	
print "\n\t\t".'### UPDATE ON `array_gene` FOR NEW ARRAY ###'."\n\n\n";


$test=$dbh->prepare("	
SELECT array_id
FROM array_gene
WHERE `array_id` = ?
GROUP BY array_id
");

$info_array=$dbh->prepare("	
SELECT array_id, species
FROM array_design
WHERE `array_id` = ?
GROUP BY array_id
");

%arrayTab=();


open(GO, $dataset_list) or die "impossible d'ouvrir $dataset_list ! \n" ;
while (<GO>)
{
  chomp;
	$_ =~ /([^\t]*)\t([^\t]*)\t([^\t]*)\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t([^\t]*)\t([^\t]*)\t.*/ ;
	
	@data=();
	
	$resTest=$test->execute($2);
	

	if($resTest ne "1")
	{
		$info_array->execute($2);
		@data = $info_array->fetchrow_array();

		$arrayTab{$data[0]}=$data[1];
	}
	else
	{
		print $2." already in array_gene tab ! \n";
	}
}
close GO ;
$test->finish();
$info_array->finish();


foreach $array(sort keys %arrayTab)
{
	if($arrayTab{$array}=~m/,/)
	{
		system("perl", "./9-orthologies/MULTI_array_gene.pl", $array, $arrayTab{$array});
	}
	else
	{
		system("perl", "./9-orthologies/array_gene.pl", $array, $arrayTab{$array});
	}
}





		### UPDATE ON `cluster_gene` FOR NEW DATASET ###	
print "\n\n\n\t\t".'### UPDATE ON `cluster_gene` FOR NEW DATASET ###'."\n\n\n";

$infoSet=$dbh->prepare("
	SELECT `id` , `directory` , `array_id` , `species`
	FROM `array_design` , `datasets`
	WHERE `directory` = ?
	AND `array_design`.`array_id` = `datasets`.`GPL`
	GROUP BY `id`;
");



open(GO, $dataset_list) or die "impossible d'ouvrir $dataset_list ! \n" ;
while (<GO>)
{
  chomp;
	$_ =~ /([^\t]*)\t([^\t]*)\t([^\t]*)\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t([^\t]*)\t([^\t]*)\t.*/ ;
	
	$setName=$3;

	$infoSet->execute($setName);
	@resInfoSet=();
	@resInfoSet = $infoSet->fetchrow_array();
	
	if($resInfoSet[3]=~m/,/)
	{
		system("perl", "./9-orthologies/MULTI_cluster_gene.pl", $setName, $resInfoSet[0], $resInfoSet[3]);
	}
	else
	{
		system("perl", "./9-orthologies/cluster_gene.pl", $setName, $resInfoSet[0], $resInfoSet[3]);
	}
}
close GO ;
$infoSet->finish();


$dbh->disconnect;

exit;

