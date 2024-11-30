#include <Adafruit_NeoPixel.h>
#include <Ultrasonic.h>
#include <Wire.h>
#include <LCD_I2C.h>
#include <TM1637Display.h>

#define Led1 13
#define Led2 A1

#define NUMPIXELS 92 // number of neopixels in strip

#define PIN_YEAR 4
#define PIN_TYPE 2
#define PIN_TURNON 5

#define PIN_MIC A4

#define qtt_years 4
#define qtt_cities 4
#define qtt_types 3

#define PINO_TRIGGER_0 8
#define PINO_ECHO_0 11

#define PINO_TRIGGER_1 7
#define PINO_ECHO_1 10

#define PINO_TRIGGER_2 12
#define PINO_ECHO_2 3

#define PINO_TRIGGER_3 A0
#define PINO_ECHO_3 6

#define CLK A3
#define DIO A2

#define SENSOR_THR 2800 // REGULAGEM DISTANCIA DO SENSOR

#define BUTTON_TOL 300

#define SENSOR_DELAY 10
#define IDLE_DELAY 15000

#define SENSOR_ERROR 5

#define buzzer 9

TM1637Display display = TM1637Display(CLK, DIO);
Adafruit_NeoPixel strip1 = Adafruit_NeoPixel(NUMPIXELS, Led1, NEO_GRB + NEO_KHZ800);
Adafruit_NeoPixel strip2 = Adafruit_NeoPixel(NUMPIXELS, Led2, NEO_GRB + NEO_KHZ800);
LCD_I2C lcd(0x27, 16, 2);

// Initialization of the ultrassonic sensors
Ultrasonic ultrasonic0(PINO_TRIGGER_0, PINO_ECHO_0);
Ultrasonic ultrasonic1(PINO_TRIGGER_1, PINO_ECHO_1);
Ultrasonic ultrasonic2(PINO_TRIGGER_2, PINO_ECHO_2);
Ultrasonic ultrasonic3(PINO_TRIGGER_3, PINO_ECHO_3);

//Data used for led management
const float fullData
[qtt_types]
[qtt_cities + 1] // +1 to Brazil
[qtt_years] = {
  { 
    //Atropleamentos para cada 10 mil veículos        
    //2019  2020  2021  2022
    {15.26, 8.08, 15.25,  7.49}, //VITÓRIA
    {9.04,  5.47, 12.04,  7.11}, //SERRA
    {9.39,  5.61, 12.75,  7.16}, //CARIACICA
    {9.94,  6.34, 12.73,  7.54}, //VILA VELHA
    {5.8,   4.0,    3.1,    3.1} //BRASIL
  },
  { 
    //Atropelamentos para cada 100 mil habitantes      
    //2019  2020  2021  2022
    {51.92,29.25, 58.99, 31.09}, //VITÓRIA
    {27.44, 17.07,  38.75, 23.50}, //SERRA
    {28.33,  17.45, 41.40, 27.28}, //CARIACICA
    {31.79, 21.14,  44.23, 27.28}, //VILA VELHA
    {18.6, 13.3,  10.9,  11.7} //BRASIL
  },
  { 
    //Custo médio por hospitalização        
    //2019     2020     2021    2022
    {1064.12,  1026.04, 1049.83,  1381.37}, //VITÓRIA
    {1298.29,  1244.72, 1001.82,  2270.81}, //SERRA
    {0.00,     1541.80, 977.60,   666.16}, //CARIACICA
    {546.93,   567.80,  628.30,   641.73}, //VILA VELHA
    {1149.36,  1216.31, 1218.60,  1291.04} //BRASIL
  }
};

//Used to store the matrix position of the data
int index[3] = {0, 0, 0};
//type, city, year

int sensors[4] = {0, 0, 0, 0};
int buttons[3] = {0, 0, 0};
//type, turnon, year

long timestamp = 0;

long buttons_timing[3] = {0, 0, 0};
// long sensors_timestamp[4] = {0, 0, 0, 0};

int ready[4] = {0, 0, 0, 0};

int last_index_printed[3] = {0, 0, 0};

int ping[4] = {0, 0, 0, 0};

int posIna = 0;
int posEsp = 0;

int maximoLocal = 0;

void setup() {
  Serial.begin(9600);
  pinMode(Led1, OUTPUT);
  pinMode(Led2, OUTPUT);
  strip1.begin();
  strip2.begin();
  clean();
  pinMode(PIN_YEAR, INPUT_PULLUP);
  pinMode(PIN_TYPE, INPUT_PULLUP);
  pinMode(PIN_TURNON, INPUT_PULLUP);
  pinMode(buzzer, OUTPUT);
  lcd.begin();
  lcd.backlight();
  display.clear();
  display.setBrightness(7);
}

void loop(){
  int sensors[4] = {0, 0, 0, 0};
  int buttons[3] = {0, 0, 0};

  // type
  if(digitalRead(PIN_TYPE) == HIGH){
    buttons[0] = 1;
    Serial.print("0 ");
  }
  // turnon
  if(digitalRead(PIN_TURNON) == HIGH){
    buttons[1] = 1;
    Serial.print("1 ");
  }
  // year
  if(digitalRead(PIN_YEAR) == HIGH){
    buttons[2] = 1;
    Serial.print("2 ");
  }

  // Read sensors
  ping[0] = ultrasonic0.timing();
  Serial.print(ping[0]);

  ping[1] = ultrasonic1.timing();
  Serial.print(" ");
  Serial.print(ping[1]);

  ping[2] = ultrasonic2.timing();
  Serial.print(" ");
  Serial.print(ping[2]);

  ping[3] = ultrasonic3.timing();
  Serial.print(" ");
  Serial.print(ping[3]);
  Serial.print("\n");

  if( ping[0] < SENSOR_THR )
  {
    sensors[0] = 1;
  }
  if( ping[1] < SENSOR_THR )
  {
    sensors[1] = 1;
  }
  if( ping[2] < SENSOR_THR )
  {
    sensors[2] = 1;
  }
  if( ping[3] < SENSOR_THR )
  {
    sensors[3] = 1;
  }

  // Button & Ready logic
  if(buttons[0] == 1 && (millis() - buttons_timing[0] > BUTTON_TOL) ) // TIPO
  {
    index[0]++;
    if(index[0] == 3){
      index[0] = 0;
    }
    recalculaMaximo();

    lcdWrite(index[0]);
    ready[0] = 1;
    buttons_timing[0] = millis();
  }

  if(buttons[2] == 1 && (millis() - buttons_timing[2] > BUTTON_TOL) ) // ANO
  {
    index[2]++;
    if(index[2] == 4){
      index[2] = 0;
    }

    setYear(index[2]);
    ready[2] = 1;
    buttons_timing[2] = millis();
  }

  if( buttons[1] == 1 && (ready[0] && ready[2]) ) //botao de confirmar
  {
    ready[1] = 1;
    buttons_timing[1] = millis();
    // activateStrip();
    timestamp = millis();
    posEsp = 0;
    posIna = 0;
    last_index_printed[1]++;
    clean();
    ready[3] = 0;
  }
  
  //Sensor logic
  if( ready[1] == 1 )
  {
    if( sensors[0] + sensors[1] + sensors[2] + sensors[3] > 1 )
    {
      // erro
      clean();
      ready[3] = 0;
      posEsp = 0;
      
      for(int i = 0; i<NUMPIXELS; i++){
        strip1.setPixelColor(i, strip1.Color(255, 69, 0));
        strip2.setPixelColor(i, strip2.Color(255, 69, 0));
      }
      strip1.show();
      strip2.show();
      tone(buzzer, 3000); // Send 1KHz sound signal...
      delay(500);        // ...for 0,5 sec
      noTone(buzzer);     // Stop sound...
      delay(500);
      clean();
    }
    else if( sensors[0] )
    {
      index[1] = 0;
      activateStrip();
      ready[3] = 1;
      timestamp = millis();
    }
    else if( sensors[1] )
    {
      index[1] = 1;
      activateStrip();
      ready[3] = 1;
      timestamp = millis();
    }
    else if( sensors[2] )
    {
      index[1] = 2;
      activateStrip();
      ready[3] = 1;
      timestamp = millis();
    }
    else if( sensors[3] )
    {
      index[1] = 3;
      activateStrip();
      ready[3] = 1;
      timestamp = millis();
    }
  }

  if(ready[1] && !ready[3]){
    Espera();  
  }

  if( (long)millis() - IDLE_DELAY >= timestamp )
  {
    inatividade();
    if(ready[3] == 1 || ready[1] == 1)
    {
      Serial.println("### idle ###");
      clean();
      ready[3] = 0;
      ready[1] = 0;
    }
  }
  else
  {
    posIna = 0;
  }

  delay(10);
}

int activateStrip(){
  if(
    last_index_printed[0] == index[0] &&
    last_index_printed[1] == index[1] &&
    last_index_printed[2] == index[2]
    )
  {
    return 1;
  }
  else
    {
      last_index_printed[0] = index[0];
      last_index_printed[1] = index[1];
      last_index_printed[2] = index[2];
    }

  clean();
  showLight();
  return 0;
}

void inatividade(){
  posIna++;
  if(posIna == NUMPIXELS-10){
    posIna = 0;
    clean();
  }
  // clean();
  for(int i = 0; i<10; i++){
    strip1.setPixelColor(posIna+i, strip1.Color(0, 0, 255));
    strip1.show();
    strip2.setPixelColor(posIna+i, strip2.Color(0, 0, 255));
    strip2.show();
  }
  strip1.setPixelColor(posIna, strip1.Color(0, 0, 0));
  strip1.show();
  strip2.setPixelColor(posIna, strip2.Color(0, 0, 0));
  strip2.show();

}

void Espera(){
  posEsp++;
  if(posEsp == NUMPIXELS/2){
    posEsp = 0;
    clean();
}
  // clean();
  strip1.setPixelColor(posEsp+NUMPIXELS/2, strip1.Color(5*posEsp, 0, 255-5*posEsp));
  strip1.show();
  strip1.setPixelColor(-posEsp+NUMPIXELS/2, strip1.Color(5*posEsp, 0, 255-5*posEsp));
  strip1.show();
  strip2.setPixelColor(posEsp+NUMPIXELS/2, strip2.Color(5*posEsp, 0, 255-5*posEsp));
  strip2.show();
  strip2.setPixelColor(-posEsp+NUMPIXELS/2, strip2.Color(5*posEsp, 0, 255-5*posEsp));
  strip2.show();
}

void recalculaMaximo(){
  maximoLocal = 0;
  for (int i = 0; i<qtt_cities + 1; i++)
  {
    for (int j = 0; j<qtt_years; j++)
    {
      if(fullData[index[0]][i][j] > maximoLocal)
      {
        maximoLocal = fullData[index[0]][i][j];
      }
    }
  }
}

void showLight(){
  clean();

  //Serial.print(fullData[index[0]][index[1]][index[2]]);
  //Serial.print(" ");
  //Serial.println(maximoLocal);
  //delay(1200);

  for (int i=0; i < NUMPIXELS; i++)
  {
    //cidade
    if( i <= (fullData[index[0]][index[1]][index[2]]/maximoLocal)*NUMPIXELS )
    {
      Serial.println(i);
      strip1.setPixelColor(i, strip1.Color(255, 0, 0));
    }

    //brasil
    if( i <= (fullData[index[0]][4][index[2]]/maximoLocal)*NUMPIXELS )
    {
      Serial.println(i);
      strip2.setPixelColor(i, strip2.Color(0, 255, 0));
    }
  
    strip1.show();
    strip2.show();

    delay(15);
  }
}

void clean(){
  for (int i=0; i < NUMPIXELS; i++) {
    strip1.setPixelColor(i, strip1.Color(0, 0, 0));
    strip2.setPixelColor(i, strip2.Color(0, 0, 0));
  }
  strip1.show();
  strip2.show();
}

void lcdWrite(int tipo)
{
  lcd.clear();
  lcd.flush();
  lcd.clearWriteError();
  switch(tipo){
    case 0:
      lcd.setCursor(0, 0);
      lcd.print("  Atropelam. p/");
      lcd.setCursor(0, 1);
      lcd.print(" 10 mil veiculos");
    break;
    case 1:
      lcd.setCursor(0, 0);
      lcd.print(" Atropelam. p/");
      lcd.setCursor(0, 1);
      lcd.print(" 100 mil habts");
    break;
    case 2:
      lcd.setCursor(0, 0);
      lcd.print(" Custo medio p/");
      lcd.setCursor(0, 1);
      lcd.print(" Hospitalizacao");
    break;
    default:
      
    break;

  }
}

void setYear(int ano){
  display.clear();
  switch(ano){
  case 0:
    display.showNumberDec(2019);
  break;
  case 1:
    display.showNumberDec(2020);
  break;
  case 2:
    display.showNumberDec(2021);
  break;
  case 3:
    display.showNumberDec(2022);
  break;
  }
}