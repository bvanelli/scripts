# Hasher

Very simple hasher to find low SHA256. Even though this code was somehow aiming for speed, it's not in any way optimized and makes use of some archaic coding style.

## Compiling

Make sure you have `openssl` and `make` and just run the command `make`. Run `make run` to execute the automated test.

## Usage

```
Usage: hasher -z [number of zeros] -e [exponent of 10 to be tested]
   -s [pre-string]   : adds pre string on the value to be hashed.
   -h                : salt can be hexadecimal.
``` 

## Examples

Mine your first hash with:

```
./hasher -e 6 -z 6
```

**Output**

```
Testing numbers up to 1000000

Started program at tick 1187

665782 - 0000000399c6aea5ad0c709a9bc331a3ed6494702bd1d129d8c817a0257a1462

Finished in 4.258e+06 ticks
Average 0.234852 numbers/tick.
```

Find a matching hexadecimal hash for your name

```
./hasher -e 7 -z 6 -h -s "brunno:"
```

**Output**

```
Testing numbers up to 10000000

Started program at tick 1445

brunno:3e692e - 000000bf8320684803a4f042d1f9fa6e87cb6d0634f6cf90c54127163a8866fd

Finished in 6.3709e+07 ticks
Average 0.156964 numbers/tick.

```



