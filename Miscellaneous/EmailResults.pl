#!/usr/local/bin/perl -w
use strict;
use Net::SMTP;
                                       
	my $src_adress=testharness@criticalpath.net;
	my $dest_address=$ENV{RESULTS_EMAIL};
	my $mail_host=

	 
    $smtp = Net::SMTP->new('$mail_host');
    $smtp->mail($src_address);
    $smtp->to($dest_address);
     
    # Send the header. 
    $smtp->data();
    $smtp->datasend("To: $dest_address\n");
    $smtp->datasend("Subject: Summary of Test Results\n");
    $smtp->datasend("\n");
    
    # Send the body.
 	$smtp->datasend("====================================================================\n");
	$smtp->datasend("Test Results Summary $0\n");
	$smtp->datasend("Number of Tests  = $no_tests\n");
	$smtp->datasend("Number of Passes = $no_passes\n");
	$smtp->datasend("Number of Fails  = $no_fails\n");

	my $element_count=scalar(@failed);
	if ($element_count > 0) {	
		$smtp->datasend("The following tests failed...\n");
		my $i = 0;
		while ($i < $element_count) { # List all the elements in the array.
		$smtp->datasend("$failed[$i].\n";
			$i++;
		}
	}
	
	$smtp->datasend("====================================================================\n");    
    
    $smtp->dataend();
    $smtp->quit; 