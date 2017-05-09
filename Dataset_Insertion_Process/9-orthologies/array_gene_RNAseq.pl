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



$tab="annotations_".$species;
$tab=~s/ /_/;


$requete_recup_gene=$dbh->prepare("
	SELECT `Annotation_gene_id`
	FROM $tab , `array_design`
	WHERE $tab.`seq_id` = `array_design`.`gb_acc` 
	AND `array_design`.`array_id` = '$numero_GPL'
	AND `Annotation_gene_id` IS NOT NULL
	GROUP BY `Annotation_gene_id`
;");

  $requete_symbol=$dbh->prepare("
	SELECT `gene_name`
	FROM `cDNA`
	WHERE `gene_id` = ?
	GROUP BY `gene_name`
;");
 
 %array_gene=();

 $number=$requete_recup_gene->execute();
 
 if($number eq "0E0")
 {
 	print "0\nWARNING !!! WARNING !!! GB not found in array design !!!!!!!\n\n";
	next;
 }
 else
 {
 	print $number."\n";
 }

 while($gid = $requete_recup_gene->fetchrow_array())
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
$requete_recup_gene->finish();

exit;

