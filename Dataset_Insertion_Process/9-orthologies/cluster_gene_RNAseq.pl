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


$set=$ARGV[0];
$idSet=$ARGV[1];
$species=$ARGV[2];


use DBI;



###################  TO COMPLETE 
my $password="";
my $user="";
my $host="";

my $dbh=DBI->connect("DBI:mysql:database=fishAndchips;host="$host, $user, $password) or die $DBI::errstr;

$insert=$dbh->prepare("INSERT INTO cluster_gene (id,cluster_id,gene_id,symbol) VALUES(?,?,?,?);");


system("date");

$info_cluster=$dbh->prepare("
	SELECT *
	FROM liste_cluster_correct
	WHERE id=?;
");
$nbClust=$info_cluster->execute($idSet);

print $nbClust." clusters to screen\n";

@data=();
while(@data = $info_cluster->fetchrow_array())
{
	chomp$data[0];

	print $set."\t".$data[0]."\t".$data[1]."\t".$species."\t";

	$tab="annotations_".$species;
	$tab=~s/ /_/;

	$id=$data[0];
	$cluster_id=$data[1];


	$requete_recup_gene=$dbh->prepare("
		SELECT $tab.Annotation_gene_id
		FROM gene_selection_correct, $tab
		WHERE gene_selection_correct.id ='$id'
		AND gene_selection_correct.cluster_id ='$cluster_id'
		AND $tab.seq_id = gene_selection_correct.gene
		AND $tab.Annotation_gene_id IS NOT NULL
		GROUP BY $tab.Annotation_gene_id
	;");
  
	$requete_symbol=$dbh->prepare("
  		SELECT `gene_name`
		FROM `cDNA`
		WHERE `gene_id` = ?
	;");
	
 	 $number=$requete_recup_gene->execute();
 	 print $number." found\n";
 	 
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

 		$insert->execute($id, $cluster_id, $gid, $symbol);
 	 }
}
print"\n";

$insert->finish();
$info_cluster->finish();
$requete_symbol->finish();
$requete_recup_gene->finish();

exit;

