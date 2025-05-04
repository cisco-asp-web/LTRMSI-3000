## Contents
- [Contents](#contents)
- [xrd01](#xrd01)
- [xrd07](#xrd07)
- [Back to Lab 1 Guide](#back-to-lab-1-guide)

## xrd01
```
conf t

router isis 100
 address-family ipv6 unicast
  segment-routing srv6
   locator MyLocator
   !
  !
 !
!
router bgp 65000
 address-family ipv4 unicast
  segment-routing srv6
  locator MyLocator
  !
 ! 
 address-family ipv6 unicast
  segment-routing srv6
  locator MyLocator
  !
 !
 neighbor-group xrd-ipv4-peer
  address-family ipv4 unicast
  !
 ! 
 neighbor-group xrd-ipv6-peer
  address-family ipv6 unicast
  !
 !
!  
segment-routing
 srv6
  encapsulation
   source-address fc00:0000:1111::1
  !
  locators
   locator MyLocator
    micro-segment behavior unode psp-usd
    prefix fc00:0000:1111::/48
   !
  !
 !
 commit
 
```

## xrd07
```
conf t

router isis 100
 address-family ipv6 unicast
  segment-routing srv6
   locator MyLocator
   !
  !
 !
!
router bgp 65000
 address-family ipv4 unicast
  segment-routing srv6
  locator MyLocator
  !
 ! 
 address-family ipv6 unicast
  segment-routing srv6
  locator MyLocator
  !
 !
 neighbor-group xrd-ipv4-peer
  address-family ipv4 unicast
  !
 ! 
 neighbor-group xrd-ipv6-peer
  address-family ipv6 unicast
  !
 !
!
segment-routing
 srv6
  encapsulation
   source-address fc00:0000:7777::1
  !
  locators
   locator MyLocator
    micro-segment behavior unode psp-usd
    prefix fc00:0000:7777::/48
   !
  !
 !
 commit

 ```

 ## Back to Lab 1 Guide
[Lab 1 Guide](./lab_1-guide.md#validate-srv6-configuration-and-reachability)