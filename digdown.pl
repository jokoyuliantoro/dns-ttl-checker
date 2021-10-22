#!/usr/bin/perl
$|=1;
while (<>) {
  chomp;
  $dcheck = $_;
  $notfound = 1;
  do {
    $ttl = "";
    $ips = "";
    $dom = "";
    open F, "dig +trace $dcheck |";
    while (<F>) {
      if (/^(\S+)\s+([0-9]+)\s+IN\s+A+\s+(\S+)/) {
        $dom = $1;
        $ttl = $2;
        $ips = $3;
        $notfound = 0;
      } elsif (/\s+IN\s+CNAME\s+(\S+)/) {
        $dom = $1;
      }
    }
    close F;
    if ($dom eq "") {
      $notfound = 0;
    } else {
      $dcheck = $dom;
    }
  } while $notfound;

  $ttl = "nottl" if $ttl eq "";
  $ips = "noanswer" if $ips eq "";
  print "$dcheck;$dom;$ttl;$ips\n";
}
