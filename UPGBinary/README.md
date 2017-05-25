# Ultimate Prime Generator - Binary

This C library implements a bitArray and a simple Sieve of Eratosthenes to find prime numbers. Despite it's 'Ultimate' name, it's meant to be a simple to use library to generate prime number arrays and text files.

For larger and faster prime number algorithms, refer to [primesieve - Fast C/C++ prime number generator](http://primesieve.org) also hosted at GitHub under [kimwalisch/primesieve](https://github.com/kimwalisch/primesieve).

## Usage

To use the library, simply include the header file in your C/C++ project:

```c
#include "UPGBinary.h"
```

To create a bitArray with 32*size positions, use:

```c
bitArray * primes = newBitArray(size);
```

To apply Sieve of Eratosthenes:

```c
primeSieve(primes);
```

If you want to print all primes to a text file:

```c
printToFile(primes, "primes.txt");
```

Remember to free the unused memory:

```c
freePrimeArray(primes);
```

Alternatively, you can use the 'generatePrimes' function that will generate primes below a certain threshold:

```c
bitArray * primes = generatePrimes(maxNumber);
printToFile(primes, "primes.txt");
```
