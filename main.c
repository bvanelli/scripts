
// Include the library
#include"UPGBinary.h"


main()
{
	float timestart = getCurrentTime();

	// Create a bit array
	bitArray * primes = newBitArray(1000);

	primeSieve(primes);
	//printToFile(primes, "primes.txt");
	freePrimeArray(primes);


	// Print primes below 1000
	bitArray * newPrimes = generatePrimes(1000);
	printArray(newPrimes);
	freePrimeArray(newPrimes);

	printf("\n\nExecution terminated in ~%.3f seconds \n\n", getCurrentTime() - timestart);

	getchar();
}