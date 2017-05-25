#pragma once

#ifndef _UPGBINARY_H
#define _UPGBINARY_H

// Included Libraries
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>
#include <time.h>

// Microsoft being Microsoft
#ifdef __unix
#define fopen_s(fp, fmt, mode)          *(fp)=fopen( (fmt), (mode))
#endif

//  Defines 
//

// Reduce code usage. Can be set to anything higher.
typedef unsigned long long huge;      

// Define the size for the int - equivalent to sizeof(int)
#define SIZE 32                       


// Macros for bit arrays based on:
// http://www.mathcs.emory.edu/~cheung/Courses/255/Syllabus/1-C-intro/bit-array.html
#define setbit(A,k)     ( A[(k/SIZE)] |= (1 << (k%SIZE)) )
#define clearbit(A,k)   ( A[(k/SIZE)] &= ~(1 << (k%SIZE)) )
#define testbit(A,k)    ( A[(k/SIZE)] & (1 << (k%SIZE)) )


// This struct is meant to hold the prime array you are going to sieve.
// It's constructor is 'bitArray * newBitArray(int count)'
// Since SIZE is fixed at 32, for every count increase there are 32 new bit slots on the array.
typedef struct bitArray {

	int * array;
	huge size;
	int flag;

} bitArray;



// Constructor for the bitArray struct
// The memory used is count*4 bytes and will allocate 32*count bit slots
//
bitArray * newBitArray(huge count)
{
	static bitArray isprime;

	isprime.array = calloc(count, SIZE);

	if (isprime.array == NULL)
		return NULL;

	isprime.size = (huge)SIZE*count;
	isprime.flag = 0;

	return &isprime;
}


// Destructor for the bitArray struct
// It frees all the memory allocated
//
void freePrimeArray(bitArray * structArray)
{
	if (!structArray)
		free(structArray->array);

	structArray = NULL;
}


// Standart Sieve of Eratosthenes
// This sieve does not fully optimize memory usage.
//
int primeSieve(bitArray * structArray)
{
	if (!structArray)
		return -1;

	int * isprime = structArray->array;
	huge arraySize = structArray->size;

	huge cont = 0, i = 0, searchStart = 0; // Loop variables

	huge maxTest = sqrt(arraySize); // Test until the square root of the max number

	setbit(isprime, 0); // Set 0 as not prime manually;
	setbit(isprime, 1); // Set 1 as not prime manually;

	// Sieve iterator
	for (cont = 2; cont <= maxTest; cont++)
	{
		if (testbit(isprime, cont) == 0)
		{
			searchStart = cont*cont;
			for (i = searchStart; i <= arraySize; i = i + cont)
			{
				setbit(isprime, i);
			}
		}
	}

	structArray->flag = 1;

	return 0;
}


// Generates the prime numbers below 'maxNumber' threshold.
// Ensure that maxNumber is greater than 2 or it will return a nullPointer.
//
bitArray * generatePrimes(huge maxNumber)
{
	huge memoryCount = maxNumber/SIZE + 1;
	
	bitArray * isprime = newBitArray(memoryCount);

	if (!isprime || maxNumber < 2)
		return NULL;

	isprime->size = maxNumber;

	primeSieve(isprime);

	return isprime;
}


// This a prototype for printing the bitarray to a file
// It will print every bit that has been not set and it's relative position
//
int printToFile(bitArray * structArray, char * filename)
{
	FILE * pFile;
	int err = fopen_s(&pFile, filename, "w+");
	huge position = 1;

	if (err != 0 || !structArray)
		return -1;

	int * isprime = structArray->array;

	// Begin printing
	for (huge cont = 0; cont <= structArray->size; cont++)
	{
		if (testbit(isprime, cont) == 0)
		{
			fprintf(pFile, "%llu. %llu\n", position, cont);
			position++;
		}
	}

	fclose(pFile);
	return 0;

}


// Prints out the bit array
// 
//
int printArray(bitArray * structArray)
{
	if (structArray == NULL)
		return -1;

	for (huge i = 0; i <= structArray->size; i++)
	{
		if (!testbit(structArray->array, i))
		{
			printf("%llu. 0 \n", i);
		}
		else
		{
			printf("%llu. 1 \n", i);
		}
	}

	return 0;
}


// A simple timer that returns execution time since launch
// It may not be accurate since CLOCKS_PER_SEC is a defined value
//
float getCurrentTime()
{
	return (float)clock() / (float)(CLOCKS_PER_SEC);
}

#endif /* !UPGBINARY_H */
