# DNS TTL Checker Script

This script is designed to read a list of FQDN and collect the TTL + address information directly from the authoritative NS. This information is required because DNS resolvers reduce the TTL. Additionally, the script can tell top queried domains which are not active. The information can be used to tune the DNS Caching parameters.

```
$ head -n5 domain.txt
www.google.com
dns.msftncsi.com
graph.facebook.com
gateway.fe.apple-dns.net
outlook.office365.com
$
$ ./digdown.pl < domain.txt > res.txt
$
$ head -n5 res.txt
www.google.com 300,300,300,300,300,300 172.217.194.103,172.217.194.104,172.217.194.105,172.217.194.106,172.217.194.147,172.217.194.99
dns.msftncsi.com 30 131.107.255.255
graph.facebook.com 300 api.facebook.com.
api.facebook.com. 299 star.c10r.facebook.com
star.c10r.facebook.com 60 157.240.235.15
$
$
$ dig www.google.com

; <<>> DiG 9.16.1-Ubuntu <<>> www.google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 35253
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;www.google.com.                        IN      A

;; ANSWER SECTION:
www.google.com.         5       IN      CNAME   forcesafesearch.google.com.
forcesafesearch.google.com. 4   IN      A       216.239.38.120

;; Query time: 7 msec
;; SERVER: 127.0.0.53#53(127.0.0.53)
;; WHEN: Thu Oct 21 21:52:09 WIB 2021
;; MSG SIZE  rcvd: 89

$
```

Example above shows that `www.google.com` has `TTL` of `300` directly from NS but local resolver returned a `CNAME`.

```
$ dig graph.facebook.com

; <<>> DiG 9.16.1-Ubuntu <<>> graph.facebook.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 37678
;; flags: qr rd ra; QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65494
;; QUESTION SECTION:
;graph.facebook.com.            IN      A

;; ANSWER SECTION:
graph.facebook.com.     5       IN      CNAME   api.facebook.com.
api.facebook.com.       4       IN      CNAME   star.c10r.facebook.com.
star.c10r.facebook.com. 4       IN      A       157.240.208.16

;; Query time: 15 msec
;; SERVER: 127.0.0.53#53(127.0.0.53)
;; WHEN: Thu Oct 21 21:53:56 WIB 2021
;; MSG SIZE  rcvd: 105

$
```

Another example is `graph.facebook.com` which has `TTL` of `300` from NS but local resolver returned `TTL` of `5`.
