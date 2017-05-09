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

$numero_GPL=$ARGV[0];
$species=$ARGV[1];

use DBI;
###################  TO COMPLETE 
my $password="";
my $user="";
my $host="";

my $dbh=DBI->connect("DBI:mysql:database=fishAndchips;host="$host, $user, $password) or die $DBI::errstr;

$insert=$dbh->prepare("INSERT INTO array_gene (array_id,gene_id,symbol) VALUES(?,?,?);");

system("date");
print $numero_GPL."\t".$species."\t";


%geneTab=();

$requete_recup_gene_salmon=$dbh->prepare("
	SELECT `Annotation_gene_id`
	FROM `annotations_Salmo_salar`, `array_design`
	WHERE `annotations_Salmo_salar`.`seq_id` = `array_design`.`gb_acc` 
	AND `array_design`.`array_id` = '$numero_GPL'
	AND `Annotation_gene_id` IS NOT NULL
	GROUP BY `Annotation_gene_id`
;");
$number=$requete_recup_gene_salmon->execute();
print $number." in Salmon tab\t";

while($gid = $requete_recup_gene_salmon->fetchrow_array())
{
	chomp$gid;
	$geneTab{$gid}=0;
}


$requete_recup_gene_trout=$dbh->prepare("
	SELECT `Annotation_gene_id`
	FROM `annotations_Oncorhynchus_mykiss`, `array_design`
	WHERE `annotations_Oncorhynchus_mykiss`.`seq_id` = `array_design`.`gb_acc`
	AND `array_design`.`array_id` = '$numero_GPL'
	AND `Annotation_gene_id` IS NOT NULL
	GROUP BY `Annotation_gene_id`
;");
$number=$requete_recup_gene_trout->execute();
print $number." in Trout tab\n";

while($gid = $requete_recup_gene_trout->fetchrow_array())
{
	chomp$gid;
	$geneTab{$gid}=0;
}


$requete_symbol=$dbh->prepare("
	SELECT `gene_name`
	FROM `cDNA`
	WHERE `gene_id` = ?
	GROUP BY `gene_name`
;");

foreach $gid(sort keys %geneTab)
{
 	chomp$gid;

 	$requete_symbol->execute($gid);
 	$symbol = $requete_symbol->fetchrow_array();
 	
	chomp $symbol;
	
	if($symbol eq "null")
 	{
 		undef $symbol;
 	}
 	else
 	{
		$symbol=~s/ \(.*//;
	}

	$insert->execute($numero_GPL, $gid, $symbol);
 }
 
 print"\n";
 
$insert->finish();
$requete_symbol->finish();
$requete_recup_gene_trout->finish();
$requete_recup_gene_salmon->finish();

exit;

