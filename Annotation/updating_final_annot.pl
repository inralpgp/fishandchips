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

use DBI;

###################  TO COMPLETE 
my $password="";
my $user="";
my $host="";


$dbh=DBI->connect("DBI:mysql:database=fishAndchips;host="$host, $user, $password);

$reqBlastRes=$dbh->prepare("
	SELECT `blast_result_id`
	FROM `Final_annotation`
	WHERE `blast_result_id` IS NOT NULL
	GROUP BY `blast_result_id`;
");

$reqRefSeq=$dbh->prepare("
	SELECT `ensembl_transcript` 
	FROM `refseq` 
	WHERE `seq_id` = ?;
");

$reqInfoSeq=$dbh->prepare("
	SELECT `gene_id`, `gene_name`, `gene_details`, `species`
	FROM `cDNA` 
	WHERE `transcript_id` = ?;
");

$reqUpTable=$dbh->prepare("
	UPDATE `Final_annotation`
	SET `Annotation_gene_id` = ?, `Annotation_gene_symbol` = ?, `Annotation_gene_name` = ?, `Annotation_species` = ?
	WHERE `blast_result_id` = ?;
");


$total=$reqBlastRes->execute();
print "\n";
system("date");
print $total." transcripts found\n\n";

$cpt=0;
$pass=0;
while($seqId=$reqBlastRes->fetchrow_array())
{
	++$cpt;

	if(($cpt%1000)==0)
	{
		$pass+=1000;
		system("date");
		print $pass." transcripts updated\n\n";
	}

	chomp$seqId;
	if($seqId=~m/^NM_/)
	{
		$reqRefSeq->execute($seqId);
		$newSeqId=$reqRefSeq->fetchrow_array();
	}
	else
	{
		$newSeqId=$seqId;
	}
	
	chomp$newSeqId;
	$reqInfoSeq->execute($newSeqId);
	@infos=$reqInfoSeq->fetchrow_array();
	
	if($infos[1] eq "null")
	{
		undef $infos[1];
	}
	if($infos[2] eq "null")
	{
		undef $infos[2];
	}
	
	$reqUpTable->execute($infos[0],$infos[1],$infos[2],$infos[3],$seqId);
}

$reqBlastRes->finish;
$reqRefSeq->finish;
$reqInfoSeq->finish;
$reqUpTable->finish;
$dbh->disconnect;

exit;

