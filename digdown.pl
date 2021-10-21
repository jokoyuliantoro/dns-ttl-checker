#!/usr/bin/perl
$|=1;
while (<>) {
  chomp;
  $dcheck = $_;
  $not_in_a = 1;
  $reald = "";
  do {
    open F, "dig $dcheck | ";
    while (<F>) {
      if (/([0-9]+)\s+IN\s+CNAME\s+(\S+)/) {
        print "$dcheck $1 $2\n";
        $dcheck = $2; 
      } elsif (/IN\s+A+\s+/) {
        $reald = $dcheck;
        $not_in_a = 0;
      }
    }
    close F;
  } while ($not_in_a);
  
  if ($reald ne "") {
    @d = split(/\./, $reald);
    $dl = scalar @d;
    $dom = "";
    for ($i = $dl-1; $i; $i--) {
      $dom = ".".$dom if $dom ne "";
      $dom = $d[$i].$dom;
    }
    $ns = "";
    $nsip = "";
    $dom = $dcheck if $dl == 2;
    open F, "dig $dom ns | ";
    while (<F>) {
      if (/IN\s+NS\s+(\S+)/) {
        $ns = $1;
        open G, "dig $ns +short |";
        while (<G>) {
          if (/([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/) {
            $nsip = $1;
            break;
          }
        }
        close G;
      }
      if ($nsip ne "") {
        close F;
      }
    }

    $dom = $d[0].".$dom" if $dl > 2;
    if ($nsip ne "") {
      open G, "dig \@$nsip $dom | sort |";
      $ips = "";
      $ttl = "";
      while (<G>) {
        if (/\s+([0-9]+)\s+IN\s+A+\s+(\S+)/) {
          $ttl .= "," if $ttl ne "";
          $ttl .= "$1";
          $ips .= "," if $ips ne "";
          $ips .= "$2";
        }
      }
      close G;
      print "$dom $ttl $ips\n";
    } else {
      print "$dom nottl noanswer\n";
    }
  } else {
    print "$dcheck nottl noanswer\n";
  }
}
