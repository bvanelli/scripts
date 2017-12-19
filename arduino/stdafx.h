/*

stdafx.h - A Multipurpose library to tweak Arduino boards.
Author: Brunno Vanelli at brunno.v@grad.ufsc.br
 
The stdafx library is supposed to be a multi-purpose library aimed at filling gaps Arduino.h itself can't handle or did not implemented.

It supports streaming just like C++, GPIO manipulation, a time-based memory database, PI filtered controller, sensor support and more to come.

To use it, simply include in your project root directory and include it, so it ships with your program.

*/


#ifndef stdafx_h
#define stdafx_h
#include "Arduino.h"
#include "float.h"

/*

    Declare streaming inside Arduino, as on ARDUINO_STREAMING library, so you can use:
        Serial << "Hello World!" << endl;

    To do that, simply define DEBUG before calling this library:
        #define DEBUG
        #include "stdafx.h"

    You can disable stdout by not defining the debug flag before calling this library.

*/
enum _EndLineCode { endl };
#ifdef DEBUG
    template<class T> 
    inline Print &operator <<(Print &obj, T arg) { obj.print(arg); return obj; } 
    inline Print &operator <<(Print &obj, _EndLineCode arg) { obj.println(); return obj; }
#else
    template<class T>
    inline Print &operator <<(Print &obj, T arg) { } 
    inline Print &operator <<(Print &obj, _EndLineCode arg) { }
#endif

/*

    Define some useful conversions for stdout, you can use:
        Serial << _HEX(a);

*/
#define _HEX(a)     _BASED(a, HEX)
#define _DEC(a)     _BASED(a, DEC)
#define _OCT(a)     _BASED(a, OCT)
#define _BIN(a)     _BASED(a, BIN)

/*

    Simple memory database for recording float data/timestamp keypair.

*/
class Database
{
    protected:
        uint16_t MAX_POINTER;
        float * data;
        unsigned long * t;
        uint16_t pointer = 0;

    public:
        Database (uint16_t size)
        {
            data = new float[size];
            t = new unsigned long[size];
            MAX_POINTER = size;            
            this->free();
        }

        ~Database ()
        {
            delete[] data;
            delete[] t;
        }
    
        uint16_t push (float _data, float _time)
        {
            if (!this->hasSpace())
                return 0;
            data[pointer] = _data;
            t[pointer] = _time;
            pointer++;
            return pointer;
        }

        void free ()
        {
            pointer = 0;
            for(int i = 0; i < MAX_POINTER; i++)
            {
                data[i] = 0;
                t[i] = 0;
            }
        }
        
        uint16_t hasSpace () { return MAX_POINTER - pointer; }        
        uint16_t maxSize ()  { return MAX_POINTER; }
        uint16_t size ()     { return pointer; }
        float getData (uint16_t pos)    { return data[pos]; }
        float getTime (uint16_t pos)    { return t[pos]; }
};

/*

    Declare standard accelerometer interface.

*/
class Accelerometer
{
    private:
        int xport, yport, zport;
    
    public:

        typedef struct
        {
            float x = 0;
            float y = 0;
            float z = 0;
        } xyzdata;

        Accelerometer (int _x, int _y, int _z)
        {
            xport = _x;
            yport = _y;
            zport = _z;
        }
    
        xyzdata read ()
        {
            xyzdata reader;
            reader.x = analogRead(xport);
            reader.y = analogRead(yport);
            reader.z = analogRead(zport);
            
            return reader;
        }
};

/*

    Declare LM35 Temperature Reader integrated circuit.

*/
class LM35
{
    private:
        int tempPin;
    
    public:
        LM35 (int _tempPin)
        {
            tempPin = _tempPin;
        }
        
        float read ()
        {
            return ( analogRead(tempPin) / 1024.0 ) * 500.0;
        }
};


class Signals {

public:

/*

    IIR Filter Design on Arduino.

    This filter can be written as (a0 is assumed to be 0):

        y[n] = b0*x[n] + b1*x[n - 1] + ... + bP*x[n - P]
         - a1*y[n - 1] + a2*y[n - 2] + ... + aQ*y[n - Q]

    or in the z domain:

        H(z) = b0 + b1*z^-1 + ... + bP*z^-P
               -----------------------------
                1 + a1*z^-1 + ... + aQ*z^-Q

    To use it, first create the filter with the desired coefficients:

        const float b[] = {0, 1};
        const float a[] = {-0.5};
        Signals::IIR f(b, sizeof(b)/sizeof(*b), a, sizeof(a)/sizeof(*a));

    Now filter the current ref value!

        float fref = f.filter(ref);

*/
class IIR
{
    private:
        float * a, * b;
        float * x, * y;
        unsigned int size_a, size_b;
        unsigned int iteration_a, iteration_b;

    public:
        IIR(const float * b, const unsigned int size_b, const float * a, const unsigned int size_a)
        {
            // b coefficients
            this->size_b = size_b;
            this->b = new float[size_b];
            memcpy(this->b, b, size_b*sizeof(float));
            
            this->x = new float[size_b];

            for (unsigned int i = 0; i < size_b; i++)
                this->x[i] = 0.0;

            // a coefficients
            this->size_a = size_a;
            this->a = new float[size_a];
            memcpy(this->a, a, size_a*sizeof(float));
            
            this->y = new float[size_a];
            
            for (unsigned int i = 0; i < size_a; i++)
                this->y[i] = 0.0;
        }

        ~IIR()
        {
            delete this->a, this->b;
            delete this->x, this->y;
        }

        float filter(const float value)
        {
            float ret = 0;
            x[iteration_b] = value;
            
           
            for (int i=0; i < size_b; i++)
                ret += b[i] * x[(i + iteration_b) % size_b];

            for (int i=0; i < size_a; i++)
                ret -= a[i] * y[(i + iteration_a) % size_a];
            
            iteration_b = (iteration_b + 1) % size_b;
            iteration_a = (iteration_a + 1) % size_a;
            y[iteration_a] = ret;
            return ret;
        }
};

/*

    FIR Filter Design on Arduino. This is a special case of the IIR filter, and is implemented as such.
    
    The N order filter assumes the type:

        y[n] = b0*x[n] + b1*x[n - 1] + ... + bN*x[n - N]
    
    To use it, first create the filter with the desired coefficients:

        const float h[] = {0.25, 0.25, 0.25, 0.25};
        Signals::FIR f(h, sizeof(h)/sizeof(*h));

    Now filter the current ref value!

        float fref = f.filter(ref);

*/
class FIR : public IIR
{
    public:
        FIR(const float * h, const unsigned int size) : IIR(h, size, {0}, 1) {} // FIXME: i left size as 0 to prevent creation of 0 size array, even though it's permitted by gcc and works fine
};

/*

    A simple PI controller for Arduino based on discrete controller.

    The controller is:

        C = kc (z - q)
            ----------
              z - 1

    To create PI instance:
        cPI controller(kc, q);

    To set the setpoint:
        controller.setpoint(SETPOINT);

    To calculate control signal:
        value = controller.calculate(SENSOR_READING);

    Don't forget to delay your sampling time Ts:
        delay(Ts);

    Remember to limit your output, so your control signal won't skyrocket:
        controller.limit(min, max);

    To use a filter, use the function setFilter(kf, pf). It's automatically applied to the controller. The filter equation is:

    F = kf   z  
          -------
           z + pf

    The filter is normally used to cancel a zero in the dynamic in the closed loop system.

*/
class cPI
{
    private:
        // Controller variables
        float kc, z, u, up, e, ep, ref;
        // Limit variables
        float limmin = FLT_MIN, limmax = FLT_MAX;
        // Filter variables
        float kf = 1, zf = 0, refp = 0;
        // Timed interruption
        unsigned long long tlast = 0;
        
        float limit (float _u)
        {
            if (_u > limmax)
                _u = limmax;
            if (_u < limmin)
                _u = limmin;
            return _u;
        }
        

    public:
        cPI (float _kc, float _z)
        {
            z = _z;
            kc = _kc;
            u = 0;
            up = 0;
            e = 0;
            ep = 0;
        }
        
        void setpoint (float _ref)
        {
            ref = _ref;
        }
        
        float calculate (float val_sensor)
        {
            e = this->getFilteredReference() - val_sensor;
            u = up + kc*e - kc*z*ep;
            ep = e;
            up = u = this->limit(u);
            refp = ref;
            tlast = millis();
            
            return u;
        }

        void setLimit (float _limmin, float _limmax)
        {
            limmin = _limmin;
            limmax = _limmax;
        }

        void setFilter (float _kf, float _zf)
        {
            kf = _kf;
            zf = _zf;
        }

        bool available (unsigned long ts) { return tlast - millis() > ts; }
        float getFilteredReference ()    { return kf*ref - zf*refp; }
        float getError ()     { return e; }
        float getReference () { return ref; }
        float getOutput ()    { return u; }
};

};

/*

    Use this to declare custom GPIO since Arduino doesn't provide ways to detect rising/falling edges on non-interrupt pins.

*/
class GPIO
{
    private:
        int pin;
        int lastState;
        int state;
        int mode;

    public:
        
        enum {
            IN = INPUT,
            OUT = OUTPUT,
            IN_PULLUP = INPUT_PULLUP,
            ANALOG,
            PWM
        };

        GPIO (const int _pin, const int _mode)
        {
            pin = _pin;
            mode = _mode;

            if (mode == IN || mode == IN_PULLUP || mode == OUT)
            {
                pinMode(_pin, _mode);
                lastState = state = this->read();
            }
        }

        int risingEdge ()
        {
            state = this->read();
            int value = !lastState && state;
            lastState = state;
            return value;
        }

        int fallingEdge ()
        {
            state = this->read();
            int value = lastState && !state;
            lastState = state;
            return value;
        }

        int read ()
        {
            if (mode == IN)
                return digitalRead(pin);
            else if (mode == IN_PULLUP)
                return !digitalRead(pin);
            else if (mode == ANALOG)
                return analogRead(pin);
        }

        void set ()
        {
            if (mode == OUT)
            {
                digitalWrite(pin, HIGH);
                state = HIGH;
            }
        }

        void set (const int value)
        {
            if (mode == PWM)
            {
                analogWrite(pin, value);
                state = value;
            }
        }

        void clear ()
        {
            if (mode == OUTPUT)
            {
                digitalWrite(pin, LOW);
                state = LOW;
            }
            else
                this->set(0);
        }

        int getState () { return state; }
        int getPin ()   { return pin; }
        int getMode ()  { return mode; }
};

/*

    This free_ram() function takes no parameter and returns the distance between the heap and the stack.

*/
int free_ram()
{
	extern int __heap_start, * __brkval;
	int v;
	return (int) &v - (__brkval == 0 ? (int) &__heap_start : (int) __brkval);
}

#endif
