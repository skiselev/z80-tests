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

### Running z80type Example

#### Zilog Z80 NMOS

```
A>Z80TYPE
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Processor Type: Z80 NMOS
```

#### Zilog Z80 CMOS

```
A>Z80TYPE
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Processor Type: Z80 CMOS
```

#### MME U880

```
A>Z80TYPE
Z80 Processor Type Detection (C) 2024 Sergey Kiselev
Processor Type: U880 NMOS
```
