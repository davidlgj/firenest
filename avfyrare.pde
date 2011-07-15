/**
 * firecrow transmitter code
 * 6 buttons for 6 channnels and a led for each
 * First button can also fire all channels in succesion
 */

#define XBEE_BAUD 9600
#define CHANNELS 2
#define THRESHHOLD 20
#define LED_THRESHHOLD 100

struct Channel {
  int button_pin;
  int led_pin;
  int state;
  int time;  
  int led_state;  
};

Channel channels[] = { 
  {2,8,0,0,-1}, 
  {3,9,0,0,-1},
  {4,A3,0,0,-1},
  {5,A0,0,0,-1},
  {6,A1,0,0,-1},
  {7,A2,0,0,-1}
};

//used when using first button to fire all channels
int channel_count = 0;


void setup() {
  for (int i= 0; i<CHANNELS; i++) {
    pinMode(channels[i].button_pin,INPUT);
    digitalWrite(channels[i].button_pin,HIGH); //enable internal 20K pullup
    
    pinMode(channels[i].led_pin,OUTPUT);
    digitalWrite(channels[i].led_pin,LOW);
  }
  
  Serial.begin(XBEE_BAUD);
}



//State 0 == not pressed, waiting for press

//State 1 == pressed, debouncing time not up
//Fire on press

//State 2 == pressed, waiting for release 

//State 3 == release, debouncing time not up

void loop() {
  int val;
  int m;
  
  for (int i= 0; i<CHANNELS; i++) {
    m = millis();
    
    if (channels[i].state == 0 || channels[i].state == 2) {
      val = digitalRead(channels[i].button_pin);
      
      if (channels[i].state == 0 && val == LOW) {
          //a press!, fire!
          int cc = i;
          //special case, we can fire all channels by firing the first button repeatably
          if (i == 0) {
            cc = channel_count;
            channel_count = (channel_count + 1) % CHANNELS;
          } 
          
          //fire!
          //Serial.println(cc);
          Serial.write('a'+cc);
          
          //light led
          digitalWrite(channels[cc].led_pin,HIGH);
          channels[cc].led_state = m;
                   
      }
      
      if ((channels[i].state == 0 && val == LOW) || (channels[i].state == 2 && val == HIGH)) {
        channels[i].state = (channels[i].state + 1) % 4; //change state 
        channels[i].time = m;
        //Serial.print("State change: ");
        //Serial.println(channels[i].state);
      }
            
    } else if (m - channels[i].time >  THRESHHOLD) {
      channels[i].state = (channels[i].state + 1) % 4; //change state   
      //Serial.print("State timeout: ");
      //Serial.println(channels[i].state);
    }
    
    //update led
    if (m - channels[i].led_state > LED_THRESHHOLD) {
      digitalWrite(channels[i].led_pin,LOW);
      channels[i].led_state = 0;
    }
  } 
}





