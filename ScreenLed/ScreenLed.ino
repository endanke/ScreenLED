#include <Adafruit_NeoPixel.h>
#ifdef __AVR__
  #include <avr/power.h>
#endif

#define LEDPIN 6
#define NUM_LEDS 27
#define BRIGHTNESS 255

struct RGB {
  byte r;
  byte g;
  byte b;
};

struct RGB colors[NUM_LEDS];

Adafruit_NeoPixel strip = Adafruit_NeoPixel(NUM_LEDS, LEDPIN, NEO_GRB + NEO_KHZ800);

int ledcolor = 0;
int a = 100;
int red = 9;
int green = 10;
int blue = 11;
char buff[35];

void setup() {
  #if defined (__AVR_ATtiny85__)
    if (F_CPU == 16000000) clock_prescale_set(clock_div_1);
  #endif
  strip.setBrightness(BRIGHTNESS);
  strip.begin();
  strip.show();

  // Idle color
  strip.setPixelColor(5, 100,100,100);
  strip.show();
 
  Serial.begin(57600);
  while (!Serial) {
    ; // wait for serial port to connect.
  }
  
  setColor(128,128,128);
}

void loop() {
  if (Serial.available () > 0){
    Serial.readBytes(buff, 35);
    char part[9];
    
    memcpy(part, buff + 0, 3);
    int r1 = atoi(part);
    memcpy(part, buff + 4, 3);
    int g1 = atoi(part);
    memcpy(part, buff + 8, 3);
    int b1 = atoi(part);
  
    memcpy(part, buff + 12, 3);
    int r2 = atoi(part);
    memcpy(part, buff + 16, 3);
    int g2 = atoi(part);
    memcpy(part, buff + 20, 3);
    int b2 = atoi(part);
  
    memcpy(part, buff + 24, 3);
    int r3 = atoi(part);
    memcpy(part, buff + 28, 3);
    int g3 = atoi(part);
    memcpy(part, buff + 32, 3);
    int b3 = atoi(part);
  
    int third = NUM_LEDS / 3;
    for(int i = 0; i < third; i++){
      colors[i] = { r1 , g1 , b1 };
    }
    for(int i = 9; i < third*2; i++){
      colors[i] = { r2 , g2 , b2 };
    }
    for(int i = 18; i < NUM_LEDS; i++){
      colors[i] = { r3 , g3 , b3 };
    }

    updateColors();
  }
}

void setColor(int r, int g, int b){
  uint32_t c = strip.Color(r, g, b);
  for(uint16_t i=0; i<strip.numPixels(); i++) {
    strip.setPixelColor(i, c);
  }
  strip.show();
}


void updateColors(){
  for(uint16_t i=0; i<strip.numPixels(); i++) {
      uint32_t c = strip.Color(colors[i].r, colors[i].g, colors[i].b);
      strip.setPixelColor(i, c);
  }
  strip.show();
}

