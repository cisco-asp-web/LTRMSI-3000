## Contents
- [Contents](#contents)
- [xrd01](#xrd01)
- [xrd05](#xrd05)
- [xrd06](#xrd06)
- [xrd07](#xrd07)
- [Example VRF and interface config:](#example-vrf-and-interface-config)
- [Back to Lab 2 Guide](#back-to-lab-2-guide)

## xrd01
```
conf t

router bgp 65000
 neighbor-group xrd-ipv6-peer
  address-family vpnv4 unicast
   next-hop-self
  !
  address-family vpnv6 unicast
   next-hop-self
  !
 !
!
 vrf carrots
  rd auto
  address-family ipv4 unicast
   segment-routing srv6
    locator MyLocator
    alloc mode per-vrf
   !
   redistribute connected
  !
  address-family ipv6 unicast
   segment-routing srv6
    locator MyLocator
    alloc mode per-vrf
   !
   redistribute connected
  !
 !
!
segment-routing
 traffic-eng
  segment-lists
   srv6
    sid-format usid-f3216
   !
   segment-list xrd567
    srv6
     index 10 sid fc00:0:5555::
     index 20 sid fc00:0:6666::
    !
   !
   segment-list xrd2347
    srv6
     index 10 sid fc00:0:2222::
     index 20 sid fc00:0:3333::
     index 30 sid fc00:0:4444::
    !
   !
  !
  policy low-latency
   srv6
    locator MyLocator binding-sid dynamic behavior ub6-insert-reduced
   !
   color 50 end-point ipv6 fc00:0:7777::1
   candidate-paths
    preference 100
     explicit segment-list xrd567
     !
    !
   !
  !
  policy bulk-transfer
   srv6
    locator MyLocator binding-sid dynamic behavior ub6-insert-reduced
   !
   color 40 end-point ipv6 fc00:0:7777::1
   candidate-paths
    preference 100
     explicit segment-list xrd2347
     !
    !
   !
  !
 !
!
commit

```

## xrd05
```
conf t

router bgp 65000
 neighbor-group xrd-ipv6-peer
  address-family vpnv4 unicast
   route-reflector-client
  !
  address-family vpnv6 unicast
   route-reflector-client
  !
 !
!
commit

```

## xrd06
```
conf t

router bgp 65000
 neighbor-group xrd-ipv6-peer
  address-family vpnv4 unicast
   route-reflector-client
  !
  address-family vpnv6 unicast
   route-reflector-client
  !
 !
!
commit

```

## xrd07
```
conf t

router static
 vrf carrots
  address-family ipv4 unicast
   40.0.0.0/24 10.107.2.2
   50.0.0.0/24 10.107.2.2
  !       
  address-family ipv6 unicast
   fc00:0:40::/64 fc00:0:107:2::2
   fc00:0:50::/64 fc00:0:107:2::2
  !
 !
!
router bgp 65000
 neighbor-group xrd-ipv6-peer
  address-family vpnv4 unicast
   next-hop-self
  !
  address-family vpnv6 unicast
   next-hop-self
  !
 !
!
router bgp 65000
 vrf carrots
  rd auto
  address-family ipv4 unicast
   segment-routing srv6
    locator MyLocator
    alloc mode per-vrf
   !
   redistribute connected
   redistribute static
  !
  address-family ipv6 unicast
   segment-routing srv6
    locator MyLocator
    alloc mode per-vrf
   !
   redistribute connected
   redistribute static
  !
 !
!
extcommunity-set opaque low-latency
  50
end-set
!
extcommunity-set opaque bulk-transfer
  40
end-set
!
route-policy set-color
  if destination in (40.0.0.0/24) then
    set extcommunity color bulk-transfer
  endif
  if destination in (50.0.0.0/24) then
    set extcommunity color low-latency
  endif
  if destination in (fc00:0:40::/64) then
    set extcommunity color bulk-transfer
  endif
  if destination in (fc00:0:50::/64) then
    set extcommunity color low-latency
  endif
  pass
end-policy
!
router bgp 65000
 neighbor-group xrd-ipv6-peer
  address-family vpnv4 unicast
   route-policy set-color out
  !       
  address-family vpnv6 unicast
   route-policy set-color out
  !
 !
!
commit

```

## Example VRF and interface config:
```
vrf carrots
 address-family ipv4 unicast
  import route-target
   9:9
  !
  export route-target
   9:9
  !
 !
 address-family ipv6 unicast
  import route-target
   9:9
  !
  export route-target
   9:9
  !
 !
! 
interface Loopback100
 ipv4 address 100.0.7.1 255.255.255.0
 ipv6 address 2001:db8:100:7::1/64
!
interface GigabitEthernet0/0/0/3
 vrf carrots
 ipv4 address 10.107.2.2 255.255.255.0
 ipv6 address fc00:0:107:2::2/64
 no shutdown
!
```

## Back to Lab 2 Guide
[Back to lab 2 guide](https://github.com/cisco-asp-web/LTRMSI-3000/blob/main/lab_2/lab_2-guide.md#validate-srv6-l3vpn)
