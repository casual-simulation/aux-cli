
#include <Adafruit_DotStar.h>   // Need for DotStar LEDs
#include <SPI.h>                // Need for DotStar LEDs
#include "Adafruit_VL6180X.h"   // Need for ToF Sensor
#include <SimpleRotary.h>       // Need for Rotary Encoder

#define NUMPIXELS 144 // Number of LEDs in strip

// DOTSTAR - Using SPI Pin Setup
Adafruit_DotStar strip(NUMPIXELS, DOTSTAR_BRG);
uint32_t color = 0xFF0000;      // 'On' color (starts green)

// ROTARY - Pin A, Pin B, Button Pin
SimpleRotary rotary(6, 5, 4); 

// TOF - Setting the ToF Sensor
Adafruit_VL6180X vl = Adafruit_VL6180X();



void setup() {
  Serial.begin(9600);
  vl.begin();    // Initialize ToF Sensor
  strip.begin(); // Initialize pins for output
  strip.show();  // Turn all LEDs off ASAP
}

void loop() {

  int range = vl.readRange();

  for (int i = 0; i <= NUMPIXELS; i++) {
    if (i < range)
    {
      strip.setPixelColor(i, color);
    }
    else
    {
      strip.setPixelColor(i, 0);
    }
  }

  byte pushedShort = rotary.push();
  byte pushedLong = rotary.pushLong(1000);
  byte rotate = rotary.rotate();


  // 0 = not pushed, 1 = pushed
  if ( pushedShort == 1 )
  {
    Serial.println("Pushed");
  }

  // Check to see if button is pressed for 1 second.
  if ( pushedLong == 1 )
  {
    Serial.println("1 Sec Long Pushed");
  }

  // 0 = not turning, 1 = CW, 2 = CCW
  if ( rotate == 1 )
  {
    Serial.println("CW");
  }
  if ( rotate == 2 )
  {
    Serial.println("CCW");
  }


  strip.show();
  delay(20);

}
