# z80type - Example Output on Certain CPUs

## Zilog

### Zilog Z84C00

* Zilog Z84C0008PEC; Z80 CPU; 9835 O6; Back side: PHILIPPINES
* Zilog Z84C0010PEG; Z80 CPU; 1935 VD; Back side: TAIWAN

```
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Raw results:       CMOS: 2C U880: 00 XF/YF: FF
XF/YF flags test:  C000C000
Detected CPU type: Zilog Z84C00
```

### Zilog Z80 (NMOS), Zilog Z08400

* Zilog Z-80A CPU; 8400 OA; 7935 CS; Back Side: BPHILAA932ZA; Pink ceramic package
* Zilog Z8400A CSH; 8304 V*; Back side: AUSAA152AA; Gray ceramic package
* Zilog Z8400B PS; Z80B CPU; 8329; Back side: BAAV312JM12NR; PHILIPPINES
* Zilog Z8400APS; Z80 CPU; 8635; Back side: BAAH634RF05EH; PHILIPPINES
* Zilog Z0840006PSC; 0415 FK; Back side: PHILIPPINES

```
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Raw results:       CMOS: 00 U880: 00 XF/YF: FF
XF/YF flags test:  C000C000
Detected CPU type: Zilog Z80, Zilog Z08400 or similar NMOS CPU
                   Mostek MK3880N, SGS/ST Z8400, Sharp LH0080A, KR1858VM1
```

## Mostek

Mostek was the original Zilog licensed second source manufacturer for the Zilog Z80

### Mostek MK3800N

* Mostek(C)8248; MK3880N; Z80-CPU; MALAYSIA; Back side: 3880 CM
* Mostek(C)8234; MK3880N-4; Z80 CPU; Back side: 3880N AU; MALAYSIA

```
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Raw results:       CMOS: 00 U880: 00 XF/YF: FF
XF/YF flags test:  C000C000
Detected CPU type: Zilog Z80, Zilog Z08400 or similar NMOS CPU
                   Mostek MK3880N, SGS/ST Z8400, Sharp LH0080A, KR1858VM1
```

## SGS/ST

Supposedly SGS/ST was a licensed Z80 manufacturer

### SGS/ST Z8400AB1

* SGS Z8400AB1; Y28427 (two CPUs with this date tested)
* ST Z8400AB1; 28923

```
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Raw results:       CMOS: 00 U880: 00 XF/YF: FF
XF/YF flags test:  C000C000
Detected CPU type: Zilog Z80, Zilog Z08400 or similar NMOS CPU
                   Mostek MK3880N, SGS/ST Z8400, Sharp LH0080A, KR1858VM1
```

### ST Z84C00

* ST Z84C00AB6; 29124

```
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Raw results:       CMOS: 2C U880: 00 XF/YF: 3F
XF/YF flags test:  8000C000
Detected CPU type: Toshiba TMPZ84C00AP, ST Z84C00AB
```
## NEC

NEC D780C is one of the earlier unlicensed Z80 clones

### NEC D780C

* NEC D780C; JAPAN; 8401XD

```
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Raw results:       CMOS: 00 U880: 00 XF/YF: FD
XF/YF flags test:  C000AF62
Detected CPU type: NEC D780C, GoldStar Z8400, possibly KR1858VM1
```

### NEC D70008AC
 
* NEC D70008AC-6; JAPAN; 8832LX703
 
```
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Raw results:       CMOS: 2C U880: 00 XF/YF: 1F
XF/YF flags test:  8CCEA317
Detected CPU type: NEC D70008AC
```

* NEC D70008AC-6; IRELAND; 8946L8119

```
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Raw results:       CMOS: 2C U880: 00 XF/YF: 0D
XF/YF flags test:  80007B5A
Detected CPU type: NEC D70008AC
```

* NEC D70008AC-6; JAPAN; 8648LX

```
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Raw results:       CMOS: 2C U880: 00 XF/YF: 15
XF/YF flags test:  6D767C31
Detected CPU type: Unknown CMOS Z80 clone
```

## Toshiba

Toshiba was one of the earlier CMOS Z80 versions manufacturers

### Toshiba TMPZ84C00AP

* Toshiba TMPZ84C00AP; JAPAN; 8549EDI
* Toshiba TMPZ84C00AP-8; JAPAN; 9544EFI
* Toshiba TMPZ84C00AP-10; JAPAN; 9442EFI

```
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Raw results:       CMOS: 2C U880: 00 XF/YF: 3F
XF/YF flags test:  8000C000
Detected CPU type: Toshiba TMPZ84C00AP, ST Z84C00AB
```

## Eastern Bloc

### MME U880, Thesys Z80, Microelectronica MMN 80CPU

* Thesys Z80H; 399

```
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Raw results:       CMOS: 00 U880: 01 XF/YF: FF
XF/YF flags test:  C000C000
Detected CPU type: Newer MME U880, Thesys Z80, Microelectronica MMN 80CPU
```

* MME UB880D; U 6

```
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Raw results:       CMOS: 00 U880: 01 XF/YF: FF
XF/YF flags test:  C000C000
Detected CPU type: Newer MME U880, Thesys Z80, Microelectronica MMN 80CPU
```

* MME UB880D; T 3

```
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Raw results:       CMOS: 00 U880: 01 XF/YF: FD
XF/YF flags test:  B2B28BF6
Detected CPU type: Older MME U880
```

* Microelectronica MMN 80CPU - 9262

```
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Raw results:       CMOS: 00 U880: 01 XF/YF: FF
XF/YF flags test:  C000C000
Detected CPU type: Newer MME U880, Thesys Z80, Microelectronica MMN 80CPU
```

### KR1858VM1

* KR1858VM1; Manufacturer: Electronika; 9306; 8 MHz; Back side: 18394

```
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Raw results:       CMOS: 00 U880: 00 XF/YF: F4
XF/YF flags test:  83CF8000
Detected CPU type: Overclocked KR1858VM1
```

* KR1858VM1; Manufacturer: Electronika; 9306; 1.8 MHz; Back side: 18394

```
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Raw results:       CMOS: 00 U880: 00 XF/YF: FD
XF/YF flags test:  C000B85A
Detected CPU type: NEC D780C, GoldStar Z8400, possibly KR1858VM1
```

* KR1858VM1; Manufacturer: Angstrem; 9305; 1.8 MHz

```
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Raw results:       CMOS: 00 U880: 00 XF/YF: FF
XF/YF flags test:  C000C000
Detected CPU type: Zilog Z80, Zilog Z08400 or similar NMOS CPU
                   Mostek MK3880N, SGS/ST Z8400, Sharp LH0080A, KR1858VM1
```

## GoldStar/GS

### GoldStar, GS

* GS Z8400A PS; 8640

```
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Raw results:       CMOS: 00 U880: 00 XF/YF: FD
XF/YF flags test:  BFDEBA37
Detected CPU type: NEC D780C, GoldStar Z8400, possibly KR1858VM1
```

* GoldStar Z8400B PS; 9006

```
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Raw results:       CMOS: 00 U880: 00 XF/YF: FF
XF/YF flags test:  C000BFFE
Detected CPU type: Zilog Z80, Zilog Z08400 or similar NMOS CPU
                   Mostek MK3880N, SGS/ST Z8400, Sharp LH0080A, KR1858VM1
```

## Sharp

### Sharp LH5080A

* Sharp LH5080A; JAPAN; 8604 3 D

```
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Raw results:       CMOS: 00 U880: 00 XF/YF: 30
XF/YF flags test:  40008000
Detected CPU type: Sharp LH5080A
```

### Sharp LH0080A

* Sharp LH0080A; 048CB

```
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Raw results:       CMOS: 00 U880: 00 XF/YF: FF
XF/YF flags test:  C000BFFE
Detected CPU type: Zilog Z80, Zilog Z08400 or similar NMOS CPU
                   Mostek MK3880N, SGS/ST Z8400, Sharp LH0080A, KR1858VM1
```
