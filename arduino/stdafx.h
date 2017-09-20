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
    
        int push (float _data, float _time)
        {
            if (this->isFull())
                return 1;
            data[pointer] = _data;
            t[pointer] = _time;
            pointer++;
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
        
        int isFull ()       { return pointer == MAX_POINTER ? 1 : 0; }        
        uint16_t maxSize () { return MAX_POINTER; }
        uint16_t size ()    { return pointer; }
        float getData (uint16_t pos)    { return data[pos]; }
        float getTime (uint16_t pos)    { return t[pos]; }
};


typedef struct
{
    float x = 0;
    float y = 0;
    float z = 0;
} xyzdata;

/*

    Declare standard accelerometer interface.

*/
class Accelerometer
{
    private:
        int xport, yport, zport;
    
    public:
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

/*

    A simple PI controller for Arduino based on discrete controller.

    The controller is:

    C = kc (z - q)
        -------
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

    F = kf    z  
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

        int available (unsigned long ts) { return tlast - millis() > ts ? 1 : 0; }
        float getFilteredReference ()    { return kf*ref - zf*refp; }
        float getError ()     { return e; }
        float getReference () { return ref; }
        float getOutput ()    { return u; }
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
        GPIO (int _pin, int _mode)
        {
            pin = _pin;
            mode = _mode;

            if (mode == INPUT || mode == INPUT_PULLUP || mode == OUTPUT)
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
            if (mode == INPUT)
                return digitalRead(pin);
            else if (mode == INPUT_PULLUP)
                return !digitalRead(pin);
            else
                return analogRead(pin);
        }

        void set ()
        {
            if (mode == OUTPUT)
            {
                digitalWrite(pin, HIGH);
                state = HIGH;
            }
        }

        void set (int value)
        {
            analogWrite(pin, value);
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
