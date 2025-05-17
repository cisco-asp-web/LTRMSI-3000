

```
segment-routing
 srv6
  static-sids
   sid fc00:0:1200::/48 locator MAIN behavior uN
   sid fc00:0:1200:fe04::/64 locator MAIN behavior uDT4 vrf default
   sid fc00:0:1200:fe06::/64 locator MAIN behavior uDT6 vrf default
  exit
  !
 exit
```

```
vrf Vrf1
 ipv6 route 2001:db8:1024::/64 Vrf1 segments fc00:0:1000:1203:fe06::
exit-vrf
```