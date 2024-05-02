# Zilog Z80 and Compatibles Testing Software

## z80type

**z80type** tests the Z80 CPU type. Currently it is able to distinguish between NMOS CPUs, CMOS CPUs, and U880 CPUs.

**z80type** runs under the CP/M or ZSDOS OSes. It uses SIO interrupt vector register as a scratch register for tests. By default the code is configured to run on RC2014* SIO module or on Small Computer Central RCBus modules, such as [SC725 – RCBus Serial and Timer Module](https://smallcomputercentral.com/sc725-rcbus-serial-and-timer-module/).
If running on different systems, modify the SIOBC constant in the code to point to the SIO Channel B control register, and rebuild the code.

### Building z80type

The code is written using CP/M ASM syntax and can be compiled as follows:

```
A>ASM Z80TYPE
A>LOAD Z80TYPE
```

### Example z80type Output

#### Zilog Z80 - NMOS

This is the output for most Z80 NMOS processors, including:
* Zilog Z-80A CPU, date code 7935
* Zilog Z8400APS, date code 8635
* Zilog Z0840006PSC, date code 0415
* SGS Z8400AB1, date code Y28427
* Mostek MK3880N, date code 8448
* NEC D780C, date code 8401XD
* GS Z8400A PS, date code 8640
* ST Z8400AB1, date code 28923
* Sharp LH0080A, date code 048CB
* GoldStar Z8400B PS, date code 9006
* KR1858VM1, date codes 9305 and 9306

```
E>z80type
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Processor family: Z80
Logic family:     NMOS
Manufacturer:     Zilog or non-MME/Thesys clone
```
#### MME UB880D

This is the output for East German UB880 Z80 clones:
* MME UB880D U 6
* MME UB880D T 3
* Thesys Z80H
```
E>z80type
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Processor family: U880
Logic family:     NMOS
Manufacturer:     MME or Thesys
```
#### Zilog Z84C00 - CMOS

This is the output for Zilog Z84C00 and reportedly ST Z84C00 (to be verified)
```
E>z80type
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Processor family: Z80
Logic family:     CMOS
Manufacturer:     Zilog or SGS/ST
```
#### NEC and Toshiba CMOS Z80 clones

This is the output for NEC and Toshiba Z80 CMOS clones:
* NEC D70008AC-6, date code 8832LX703
* Toshiba TMPZ84C00AP-8, date code 9544EFI
```
E>z80type
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Processor family: Z80
Logic family:     CMOS
Manufacturer:     Toshiba or NEC
```
