#!/usr/bin/perl
use Time::HiRes qw(usleep);

$|=1;
while (<>) {
  chomp;
  $dori = $_;
  $found = 1;
  open F, "dig $dori | grep ANSWER |" or die("$dori;;nottl;noanswer");
  while (<F>) {
    if (/ANSWER\: 0,/) {
      $found = 0;
    }
  }
  close F;

  if ($found == 1) {
    $not_address = 1;
    $dcheck = $dori;
    do {
      $dom = "";
      open F, "dig +trace $dcheck |";
      while (<F>) {
        if (/^(\S+)\s+([0-9]+)\s+IN\s+A+\s+(\S+)/) {
          $dom = $1;
          $ttl = $2;
          $ips = $3;
          $not_address = 0;
        } elsif (/\s+IN\s+CNAME\s+(\S+)/) {
          $dom = $1;
        }
      }
      close F;
      if ($dom eq "") {
        $not_address = 0;
      } else {
        $dcheck = $dom;
      }
    } while $not_address;
    print "$dori;$dom;$ttl;$ips\n";
  } else {
    print "$dori;;nottl;noanswer\n";
  }
  usleep(250000);
}
