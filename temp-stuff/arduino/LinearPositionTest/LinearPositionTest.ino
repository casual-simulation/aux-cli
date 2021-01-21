
#include <Adafruit_DotStar.h>   // Need for DotStar LEDs
#include <SPI.h>                // Need for DotStar LEDs if using SPI
#define NUMPIXELS 144 // Number of LEDs in strip

// DOTSTAR - Using SPI Pin Setup
Adafruit_DotStar strip(NUMPIXELS, DOTSTAR_BGR);

// DOTSTAR - Using any two pins:
//#define DATAPIN    4
//#define CLOCKPIN   5
//Adafruit_DotStar strip(NUMPIXELS, DATAPIN, CLOCKPIN, DOTSTAR_BGR);

//uint32_t color = 0xFF0000;      // 'On' color (starts Red)
uint32_t color = 0x00FF00;      // 'On' color (starts Green)
//uint32_t color = 0x0000FF;      // 'On' color (starts Blue)
//uint32_t color = 0xFFFFFF;      // 'On' color (starts White)
//uint32_t color = 0x4A235A;      // 'On' color (starts Purple)
//uint32_t color = 0x1ABC9C;      // 'On' color (starts Teal)


const int pin = 2;    //naming pin 2 as ‘pin’ variable 
const int adc1 = 1;   //naming pin 0 of analog input side as ‘adc1’
const int adc2 = 3;   //naming pin 3 of analog input side as ‘adc2’
const int onoff = 0;   //naming pin 1 as ‘onoff’ variable 
int onoffstate = 0;

void setup()
{
//  Serial.begin(9600);
  strip.begin(); // Initialize pins for output
  strip.show();  // Turn all LEDs off ASAP
  
  pinMode(pin,OUTPUT) ;  //setting pin 2 as output
  pinMode(onoff,INPUT_PULLUP) ;  //setting pin 1 as input
}

void loop()
{
  onoffstate = digitalRead(onoff);
  int adc1  = analogRead(1) ;    //reading analog voltage and storing it in an integer 
  int adc2  = analogRead(3) ;    //reading analog voltage and storing it in an integer 
  int HALFPIXELS = NUMPIXELS/2;


  adc1 = map(adc1, 0, 1023, 0, NUMPIXELS); 
  adc2 = map(adc2, 0, 1023, HALFPIXELS, 0); 

  //Front Half
  for (int i = 72; i <= NUMPIXELS; i++) //Range of pixels to loop through 144-72
  {
    if (onoffstate == LOW)
    {
      strip.setPixelColor(i, 0);
    }
    else
    {
      if (i < adc1)
      {
        strip.setPixelColor(i, color);
      }
      else
      {
        strip.setPixelColor(i, 0);
      }
    }
  }

  //Back Half
  for (int i = 0; i <= HALFPIXELS-1; i++) // Range of pixels to loop through 0-72
  {
    if (onoffstate == LOW)
    {
      strip.setPixelColor(i, 0);
    }
    else
    {
      if (i < adc2)
      {
        strip.setPixelColor(i, 0);
      }
      else
      {
        strip.setPixelColor(i, color);
      }
    }
  }

  

  analogWrite(pin,adc1); // Toggle for single LED
  strip.show(); // Toggle for LED Strip
  delay(20);
}
