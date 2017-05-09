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

######################################################################
####Scriptupdating tables if necessary for the viewing through the PHP pages ######
######################################################################

use DBI ;

my $dataset_list=$ARGV[0];

###################  TO COMPLETE 
my $password="";
my $user="";
my $host="";

my $dbh=DBI->connect("DBI:mysql:database=fishAndchips;host="$host, $user, $password) or die $DBI::errstr;

my $sth1=$dbh->prepare("SELECT id FROM datasets WHERE directory = ?;");
%filestab=();
open(GO, $dataset_list) or die "impossible d'ouvrir $dataset_list ! \n" ;
while (<GO>)
{
  chomp;
	$_ =~ /([^\t]*)\t[^\t]*\t([^\t]*)\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t[^\t]*\t([^\t]*)\t([^\t]*)\t.*/ ;
	
	$file=$2;
	$sth1->execute($file);
	my $id = $sth1->fetchrow_array();
	
	$filestab{$id}=$file;
}
close GO ;
$sth1->finish();



		###### Update quality foreach datasets ######
		
print "\t\t***** DATASET QUALITY *****\n";

my $sth2=$dbh->prepare("SELECT quality FROM quality_cluster_new WHERE id = ?;");
my $sth3=$dbh->prepare("UPDATE datasets SET quality_auto = ? WHERE id = ?;");
my $sth4=$dbh->prepare("UPDATE datasets SET quality_estimate = ? WHERE id = ?;");

foreach $id(sort keys %filestab)
{
	chomp$id;
	
	print "dataset : ".$filestab{$id}."\t id : ".$id."\t";

	$sth2->execute($id);
	my @notes = () ;
	my $p_value_datasets = "" ;
	my $qual_esti = "" ;
	my $adition_log = 0 ;
	while($p_value = $sth2->fetchrow_array)
	{
		if($p_value ne "")
		{
			push(@notes,$p_value);
		}
	}
	foreach(@notes)
	{
		$adition_log += log($_) ;
	}
	if($adition_log ne "0")
	{
		$p_value_datasets = exp($adition_log/($#notes+1)) ;
	}
	if($p_value_datasets ne "")
	{
		$sth3->execute($p_value_datasets,$id);
		
		if($p_value_datasets < 0.01)
		{
			$qual_esti=4;
		}
		elsif($p_value_datasets < 0.05)
		{
			$qual_esti=3;
		}
		elsif($p_value_datasets < 0.1)
		{
			$qual_esti=2;
		}
		elsif($p_value_datasets < 1)
		{
			$qual_esti=1;
		}
	}
	else
	{
		$qual_esti=0;
	}
	print $p_value_datasets."\t".$qual_esti."\n";
	
	$sth4->execute($qual_esti,$id);
	
}
$sth2->finish();
$sth3->finish();
$sth4->finish();

print "\n\n";



		###### SELECT good clusters foreach dataset ######
		
print "\t\t***** GOOD CLUSTER SELECTION *****\n";

my $sth1=$dbh->prepare("SELECT cluster_id FROM quality_cluster_new WHERE quality<'0.05' AND id = ?;");
my $sth2=$dbh->prepare("INSERT INTO liste_cluster_correct (id,cluster_id) VALUES(?,?);");

foreach $id(sort keys %filestab)
{
	chomp$id;
	
	$sth1->execute($id);
	while (my $data = $sth1->fetchrow_array())
	{
		print "dataset : ".$filestab{$id}."\t id : ".$id."\t cluster : ".$data."\n";
		$sth2->execute($id,$data);
	}
}
$sth2->finish();
$sth1->finish();

print "\n\n";


		###### SELECT correct genes foreach datasets clusters ######
	
	
print "\t\t***** CORRECT GENE SELECTION *****\n";

my $sth1=$dbh->prepare("
	SELECT DISTINCT gene_selection.cluster_id, gene, gb_acc 
	FROM gene_selection, liste_cluster_correct
	WHERE gene_selection.id = liste_cluster_correct.id
	AND gene_selection.cluster_id = liste_cluster_correct.cluster_id
	AND gene_selection.id=?;
");
my $sth2=$dbh->prepare("INSERT INTO gene_selection_correct (id,cluster_id,gene,gb_acc) VALUES(?,?,?,?);");

foreach $id(sort keys %filestab)
{
	chomp$id;
	print "dataset : ".$filestab{$id}."\t id : ".$id."\n";
	
	$sth1->execute($id);

	my @data=();
	while (@data = $sth1->fetchrow_array)
	{
		$sth2->execute($id,$data[0],$data[1],$data[2]);
	}

}
$sth2->finish();
$sth1->finish();



$dbh->disconnect;
