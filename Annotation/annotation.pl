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

$species=$ARGV[0];
$blast_type=$ARGV[1];	# "Megablast" ou "Discontiguous"
$existing_contig=$ARGV[2];


###################  TO COMPLETE 
my $password="";
my $user="";
my $host="";



$dbh=DBI->connect("DBI:mysql:database=fishAndchips;host="$host, $user, $password);

$update_final2=$dbh->prepare("
	UPDATE `Final_annotation`
	SET `annotation_by`=?, `blast_type`=?, `blast_query_id`=?, `blast_result_id`=?, `blast_identity`=?, `blast_e-value`=?
	WHERE `seq_id`=?;
");

if($existing_contig==1)
{
	$update_final1=$dbh->prepare("
		UPDATE `Final_annotation`
		SET `annotation_by`=?, `blast_type`=?, `blast_query_id`=?, `blast_result_id`=?, `blast_identity`=?, `blast_e-value`=?
		WHERE `contig_id`=?;
	");

	$data_per_refseq=$dbh->prepare("
		SELECT `seq_id`, `first_blast_id`, `first_blast_identity`, `first_blast_e-value`, `contig_id`
		FROM `Annotation_all_sequences` 
		WHERE `type`='RefSeq'
		AND `reciprocal_blast_id`=`seq_id`
		AND `species`=?
		AND `blast_type`=?;
	");

	$data_per_singlet=$dbh->prepare("
		SELECT `seq_id` , `species` , `type` , `contig_id` , `blast_type` , `first_blast_id` , `first_blast_identity` , `first_blast_e-value` , `reciprocal_blast_id`
		FROM `Annotation_all_sequences`
		WHERE `species` = ?
		GROUP BY `contig_id`
		HAVING COUNT( `seq_id` ) =1
		AND ( 
			( `type` = 'EST' AND `blast_type` = ? )
			OR 
			( (`type` = 'TSA' OR `type` = 'mRNA' ) AND `reciprocal_blast_id` = `seq_id` AND `blast_type` = ? )
		);
	");

	$retrieve_contig=$dbh->prepare("
		SELECT DISTINCT( `contig_id` )
		FROM `Final_annotation`
		WHERE `species` = ?
		AND `blast_type` IS NULL;
	");	

	$data_per_assembling=$dbh->prepare("
		SELECT `reciprocal_blast_id`, `first_blast_id`, `first_blast_identity`, `first_blast_e-value`, `seq_length`
		FROM `Annotation_contigs_assembled`
		WHERE `contig_id`=?
		AND `species` = ?
		AND `blast_type` = ?
		AND `reciprocal_blast_id` = `contig_id`;
	");

	$data_per_seq=$dbh->prepare("
		SELECT `reciprocal_blast_id`, `first_blast_id`, `first_blast_identity`, `first_blast_e-value`, `seq_length`
		FROM `Annotation_all_sequences`
		WHERE `contig_id`=?
		AND `species` = ?
		AND `blast_type` = ?
		AND `type` = ?
		AND `reciprocal_blast_id` = `seq_id`;
	");


	$cpt=$data_per_refseq->execute($species, $blast_type);
	print "\nContig annotation with RefSeq \($cpt\) ...\n\n";
	$cpt=0;
	while(@data=$data_per_refseq->fetchrow_array())
	{
		++$cpt;
		print $data[4]."\t".$cpt."\n";
		$update_final1->execute("contig", $blast_type, $data[0], $data[1], $data[2], $data[3], $data[4]);
	}


	$cpt=$data_per_singlet->execute($species, $blast_type, $blast_type);
	print "\nSinglet contig annotation \($cpt\) ...\n\n";
	$cpt=0;
	while(@data=$data_per_singlet->fetchrow_array())
	{
		++$cpt;
		print $data[3]."\t".$cpt."\n";
		$update_final1->execute("contig", $blast_type, $data[0], $data[5], $data[6], $data[7], $data[3]);
	}


	$cpt=$retrieve_contig->execute($species);
	print "\nRemaining $cpt contigs ...\n\n";
	@contig_list=();
	while($contig_id=$retrieve_contig->fetchrow_array())
	{
		push(@contig_list, $contig_id);
	}

	print "\nContig annotation with assembling ...\n\n";
	$cpt=0;
	foreach $contig_id(@contig_list)
	{
		$found=$data_per_assembling->execute($contig_id, $species, $blast_type);
	
		if ($found ne "0E0")
		{
			++$cpt;
			$length_ref=0;
			@data=();
	
			while(@temp_data=$data_per_assembling->fetchrow_array())
			{
				if($temp_data[4]>$length_ref)
				{
					$length_ref=$temp_data[4];
					@data=@temp_data;
				}
			}
			print $contig_id."\t".$cpt."\n";
			$update_final1->execute("contig", $blast_type, $data[0], $data[1], $data[2], $data[3], $contig_id);
		}
		else
		{
			++$cpt;
			print "No annotation with assembling for ".$contig_id."\t".$cpt."\n";
		}
	}


	$retrieve_contig2=$dbh->prepare("
		SELECT DISTINCT (`Annotation_all_sequences`.`contig_id`)
		FROM `Annotation_all_sequences` , `Final_annotation`
		WHERE `Annotation_all_sequences`.`seq_id` = `Final_annotation`.`seq_id`
		AND `Annotation_all_sequences`.`species` = ?
		AND `Annotation_all_sequences`.`type` = ?
		AND `Annotation_all_sequences`.`reciprocal_blast_id` = `Annotation_all_sequences`.`seq_id`
		AND `Final_annotation`.`blast_type` IS NULL;
	");
	
	$cpt=$retrieve_contig2->execute($species, "mRNA");
	print "\n".$cpt." contigs annotate with mRNA\n";
	@contig_list=();
	while($contig_id=$retrieve_contig2->fetchrow_array())
	{
		push(@contig_list, $contig_id);
	}	
	
	print "\nContig annotation with mRNA ...\n\n";
	$cpt=0;
	foreach $contig_id(@contig_list)
	{
		$data_per_seq->execute($contig_id, $species, $blast_type, "mRNA");

		++$cpt;
		$length_ref=0;
		@data=();
		@temp_data=();

		while(@temp_data=$data_per_seq->fetchrow_array())
		{
			if($temp_data[4]>$length_ref)
			{
				$length_ref=$temp_data[4];
				@data=@temp_data;
			}
		}
		print $contig_id."\t".$cpt."\n";
		$update_final1->execute("contig", $blast_type, $data[0], $data[1], $data[2], $data[3], $contig_id);	
	}
	
	
	$cpt=$retrieve_contig2->execute($species, "TSA");
	print "\n".$cpt." contigs annotate with TSA\n";
	@contig_list=();
	while($contig_id=$retrieve_contig2->fetchrow_array())
	{
		push(@contig_list, $contig_id);
	}	
	
	print "\nContig annotation with TSA ...\n\n";
	$cpt=0;
	foreach $contig_id(@contig_list)
	{
		$data_per_seq->execute($contig_id, $species, $blast_type, "TSA");

		++$cpt;
		$length_ref=0;
		@data=();
		@temp_data=();

		while(@temp_data=$data_per_seq->fetchrow_array())
		{
			if($temp_data[4]>$length_ref)
			{
				$length_ref=$temp_data[4];
				@data=@temp_data;
			}
		}
		print $contig_id."\t".$cpt."\n";
		$update_final1->execute("contig", $blast_type, $data[0], $data[1], $data[2], $data[3], $contig_id);
	}


	$data_per_refseq->finish;
	$data_per_singlet->finish;
	$data_per_assembling->finish;
	$data_per_seq->finish;
	$update_final1->finish;
	$retrieve_contig->finish;
	$retrieve_contig2->finish;

}
else
{
	$data_per_seq=$dbh->prepare("
		SELECT `seq_id`, `first_blast_id`, `first_blast_identity`, `first_blast_e-value`
		FROM `Annotation_all_sequences`
		WHERE `species` = ?
		AND `blast_type` = ?
		AND `seq_id` = `reciprocal_blast_id`;
	");
	
	$cpt=$data_per_seq->execute($species, $blast_type);
	print "\n".$cpt." sequences to annotate\n\n";
	
	$cpt=0;
	while(@data=$data_per_seq->fetchrow_array())
	{
		++$cpt;
		print $data[0]."\t".$cpt."\n";
		$update_final2->execute("sequence", $blast_type, $data[0], $data[1], $data[2], $data[3], $data[0]);
		
	}

}



if($blast_type eq "discontiguous")
{
	$retrieve_est=$dbh->prepare("
		SELECT `seq_id`
		FROM `Final_annotation`
		WHERE `species` = ?
		AND `blast_type` IS NULL
		AND `type` = ?;
	");
	
	$data_per_est=$dbh->prepare("
		SELECT `blast_type`, `first_blast_id`, `first_blast_identity`, `first_blast_e-value`
		FROM `Annotation_all_sequences`
		WHERE `seq_id` = ?
		AND `blast_type` IS NOT NULL;
	");


	$cpt=$retrieve_est->execute($species, "EST");
	print "\n".$cpt." sequences probably annotate with EST\n";
	@est_list=();
	while($est_id=$retrieve_est->fetchrow_array())
	{
		push(@est_list, $est_id);
	}

	print "\nAnnotation by sequence with EST ...\n\n";
	$cpt=0;
	foreach $est_id(@est_list)
	{
		$found=$data_per_est->execute($est_id);
		
		if ($found ne "0E0")
		{
			++$cpt;
		
			@data=$data_per_est->fetchrow_array();
		
			print $est_id."\t".$cpt."\n";
			$update_final2->execute("sequence", $data[0], $est_id, $data[1], $data[2], $data[3], $est_id);
		}
	}
	
	$data_per_est->finish;
	$retrieve_est->finish;
}

$update_final2->finish;
$dbh->disconnect;

exit;

