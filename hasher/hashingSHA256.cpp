#include <iostream>
#include <iomanip> 
#include <sstream>
#include <string>
#include <math.h>
//#include <omp.h>
#include <getopt.h>


#include <ctime>


#include <openssl/sha.h>

using namespace std;

inline bool isInteger(const std::string & s)
{
   if(s.empty() || ((!isdigit(s[0])) && (s[0] != '-') && (s[0] != '+'))) return false ;

   char * p ;
   strtol(s.c_str(), &p, 10) ;

   return (*p == 0) ;
}

string sha256(const string str)
{
    unsigned char hash[SHA256_DIGEST_LENGTH];
    SHA256_CTX sha256;
    SHA256_Init(&sha256);
    SHA256_Update(&sha256, str.c_str(), str.size());
    SHA256_Final(hash, &sha256);
    stringstream ss;
    for(int i = 0; i < SHA256_DIGEST_LENGTH; i++)
    {
        ss << hex << setw(2) << setfill('0') << (int)hash[i];
    }
    return ss.str();
}

void printUsage()
{
    cout << "Usage: hasher -z [number of zeros] -e [exponent of 10 to be tested]" << endl;
    cout << "   -s [pre-string]   : adds pre string on the value to be hashed." << endl;
    cout << "   -h                : salt can be hexadecimal." << endl;
}

int main(int argc, char* argv[]){
    
    std::string pre("");
    std::string one("0");
    std::string s("");    
    unsigned long MAX_NUMB = 0, i = 0;
	
    int opt, eobg = -1, zobg = -1, numzeros = 0, hex = 0;
    while ((opt = getopt (argc, argv, "e:z:s:h")) != -1)
    {
        switch (opt)
        {
            case 'e':
                if (!isInteger(optarg))
                {
                    cout << "Invalid argument" << endl;
                    printUsage();
                    return 1;
                }
                else
                {
                    MAX_NUMB = pow(10, strtol(optarg, NULL, 10));
                }
                cout << "Testing numbers up to " << MAX_NUMB << endl;
                eobg = 0;
                break;
            case 'z':
                if (!isInteger(optarg))
                {
                    cout << "Invalid argument" << endl;
                    printUsage();
                    return 1;
                }
                else
                {
                    numzeros = strtol(optarg, NULL, 10);
                }
                for (i = 0; i < numzeros; i++)
                    s = s + one;            
                zobg = 0;
                break;
            case 's':
                pre.assign(optarg);
                break;
            case 'h':
                hex = 1;
                break;
        }
    }
    

    if (eobg == -1 || zobg == -1)
    {
        printUsage();
        return 1;
    }
    
    std::clock_t start;
    double duration;
    start = std::clock();
    cout << endl << "Started program at tick " << start << endl << endl;

    // There might be a better way to perform this
    if (hex)
    {
        #pragma omp parallel for
        for (i = 0; i < MAX_NUMB; i++)
        {
            std::stringstream stream;
            stream << std::hex << i;
            std::string value = pre + stream.str();
            if (sha256(value).find(s) == 0)
            { 
                cout << value << " - " << sha256(value) << endl;
            }
        }
    }
    else
    {
        #pragma omp parallel for
        for (i = 0; i < MAX_NUMB; i++)
        {
            std::string value = pre + std::to_string(i);
            if (sha256(value).find(s) == 0)
            { 
                cout << value << " - " << sha256(value) << endl;
            }
        }
    }

    duration = ( std::clock() - start );
    cout << endl << "Finished in " << duration << " ticks" << endl;
    cout << "Average " << (float) MAX_NUMB / (float) (duration) << " numbers/tick." << endl;

    return 0;
}
