#include <LiquidCrystal.h>
//variables

int pulsePin = 0; //pulse sensor input at A0
int blinkPin = 13;
//const int buzzer = 8;
//volatile variables (for interrupt service routine

volatile int BPM; 
volatile int Signal; //stores incoming data from pulse sensor
volatile int pulseTime = 600; //stores the time between two beats
volatile boolean Pulse = false; //This becomes True when the heart beat is detected for the first time
volatile boolean PD = false; //This becomes True when a beat is detected

volatile int rate[10]; //array to hold the last ten PD values
volatile unsigned long counter = 0;
volatile unsigned long lastBeatTime = 0;
volatile int Peak = 512;
volatile int Trough = 512;
volatile int threshold = 530;
volatile int amplitude = 0;
volatile boolean firstBeat = true;
volatile boolean secondBeat = false;

//LCD intilializing

LiquidCrystal lcd(12,11,5,4,3,2);


void setup() {
  Serial.begin(115200);
  pinMode(blinkPin,OUTPUT);
  //pinMode(buzzer,OUTPUT);
  lcd.begin(16,2);
  lcd.setCursor(2,0);
  lcd.print("PULSE METER");
  lcd.setCursor(0,1);
  lcd.print("PULSE RATE :");
  pinMode(6,OUTPUT);
  pinMode(7,OUTPUT);
  pinMode(8,OUTPUT);
  pinMode(9,OUTPUT);
  pinMode(10,OUTPUT);
  pinMode(2,OUTPUT);

  /*setting up the timer interrupt. Arduino should read the pulse every 2ms. Hence the interrrupt frequency should be (1/2ms) = 500Hz. 
   Then the compare match regitser value is 124 when the prescaler is 256. So we can use either timer0 or timer1 as CMR is less than 256.
   We have used timer2 interrupt with a prescaler of 256*/

   //Setting up the timer2 at 500Hz

   //cli(); //stop interrupts

   /*TCCR2A = 0; //set entire TCCR2A register to 0
   TCCR2B = 0; //set entire TCCRBA register to 0
   TCNT2 = 0; //initilize counter value to 0
   OCR2A = 124; //compare match register value set to 124
   TCCR2A |= (1 << WGM21); //turn on CTC mode (Clear Timer on Compare mode)
   TCCR2B |= (1 << CS22); //set the prescaler to 256
   TIMSK2 |= (1 << OCIE2A); //enable timer compare interrupt

   sei(); //allow interrupts */

  TCCR2A = 0x02;     // DISABLE PWM ON DIGITAL PINS 3 AND 11, AND GO INTO CTC MODE
  TCCR2B = 0x06;     // DON'T FORCE COMPARE, 256 PRESCALER
  OCR2A = 0X7C;      // SET THE TOP OF THE COUNT TO 124 FOR 500Hz SAMPLE RATE
  TIMSK2 = 0x02;     // ENABLE INTERRUPT ON MATCH BETWEEN TIMER2 AND OCR2A
  sei();        

   
 
}

//Service Routine for timer2 interrupt. This makes sure that a reading is taken from the pulse sensor at every 2ms.

ISR(TIMER2_COMPA_vect){
  cli(); //disable interrupts while taking the reading
  Signal = analogRead(pulsePin); //read the input from the sensor module
  counter += 2; //increment the counter with 2ms to keep track of the time
  int N = counter - lastBeatTime;

  //Finding the trough of the pulse wave

  if (Signal < threshold && N > (pulseTime/5)*3){ //filters the dichrotic notch noise
    if (Signal < Trough){
      Trough = Signal;
    }
  }

  //Finding the peak of the pulse wave

  if (Signal > threshold && Signal > Peak){
    Peak = Signal;
  }

  //Looking for the heart beat 

  if (N > 250){
    if ( (Signal > threshold) && (Pulse == false) && (N > (pulseTime/5)*3)){
        Pulse = true;
        digitalWrite(10,HIGH);
        digitalWrite(6,HIGH);
        delay(10);
        digitalWrite(6,LOW);
        digitalWrite(7,HIGH);
        delay(10);
        digitalWrite(7,LOW);
        digitalWrite(8,HIGH);
        delay(10);
        digitalWrite(8,LOW);
        digitalWrite(9,HIGH);
        delay(10);
        digitalWrite(9,LOW);
       //digitalWrite(blinkPin,HIGH);
      //digitalWrite(buzzer,HIGH);   
      pulseTime = counter - lastBeatTime;
      lastBeatTime = counter;

      if (secondBeat){
        secondBeat = false;
        for (int i = 0; i <= 9 ; i++){
          rate[i] = pulseTime;
        }
      }

      if (firstBeat){
        firstBeat = false;
        secondBeat = true;
        sei();
        return;
      }

      word total = 0;

      for (int i = 0; i <= 8 ; i++){
        rate[i] = rate[i+1];
        total += rate[i];
      }

      rate[9] = pulseTime;
      total += rate[9];
      total /= 10;
      BPM = 60000/total;
      PD = true;
    }
  }

  if (Signal < threshold && Pulse == true){
    Pulse = false;
    digitalWrite(10,LOW);
    
    //digitalWrite(blinkPin,LOW);
    //digitalWrite(buzzer,LOW);
    amplitude = Peak - Trough;
    threshold = amplitude/2 + Trough;
    Peak = threshold;
    Trough = threshold;
  }

  if (N > 2500){
    threshold = 530;
    Peak = 512;
    Trough = 512;
    lastBeatTime = counter;
    firstBeat = true;
    secondBeat = false;
  }
 sei();
}



void loop() {
  /*Serial.print(BPM);
  Serial.print(",");
  Serial.print(pulseTime);
  Serial.print(",");
  Serial.println(Signal);*/

  digitalWrite(2,OUTPUT);

  /*if (Pulse == true){
    digitalWrite(10,HIGH);
    digitalWrite(6,HIGH);
    delay(50);
    digitalWrite(6,LOW);
    digitalWrite(7,HIGH);
    delay(50);
    digitalWrite(7,LOW);
    digitalWrite(8,HIGH);
    delay(50);
    digitalWrite(8,LOW);
    digitalWrite(9,HIGH);
    delay(50);
    digitalWrite(9,LOW);
  }else{
    digitalWrite(10,LOW);
    
  }*/

  if (BPM < 100){
    lcd.setCursor(13,1);
    lcd.print(BPM);
    lcd.setCursor(15,1);
    lcd.print(" ");
  }else{
    lcd.setCursor(13,1);
    lcd.print(BPM);
  }

serialOutput();


  /*int val = analogRead(pulsePin);                                              
  Serial.write( 0xff );                                                         
  Serial.write( (val >> 8) & 0xff );                                            
  Serial.write( val & 0xff );
  //delay(20);*/
}

