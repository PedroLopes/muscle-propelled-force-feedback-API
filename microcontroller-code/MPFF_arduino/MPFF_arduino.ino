const int led = 13; //LED for debug
const int relay1 = 3; //arduino pin for relay 1
const int relay2 = 4; //arduino pin for relay 1  
int delta = 200; //waiting time for open/close functions (feels like a hit)
int x;
const int MAX_INT = 32767;
boolean DEBUG = false;

void setup() {
  pinMode(led, OUTPUT);
  pinMode(relay1, OUTPUT);     
  pinMode(relay2, OUTPUT);     
  Serial.begin(9600); //speed of communications, set this on the program that interfaces with your arduino too
}

//this code is not written for optimization, but rather for simplicity for those who are not programmers
void loop() {  
  if(Serial.available() > 0) {
    x = Serial.parseInt();
    Serial.println(x);
    digitalWrite(led, HIGH);
    //depending on the value (1-9 and 0) we do a different program:
    if (x == 1) { // opens channel 1
      digitalWrite(relay1, HIGH);
      if (DEBUG) Serial.println("opens channel 1");
    }
    else if (x == 2){ // closes channel 1
      digitalWrite(relay1, LOW);
      if (DEBUG) Serial.println("closes channel 1");
    } else if (x == 3){ // opens channel 2
      digitalWrite(relay2, HIGH);
      if (DEBUG) Serial.println("opens channel 2");
    }
    else if (x == 4){ //closes channel 2
      digitalWrite(relay2, LOW);
      if (DEBUG) Serial.println("closes channel 2");
    } else if (x == 5){ // opens & closes channel 1 (default = fast)
      if (DEBUG) Serial.println("opens and closes channel 1 with wait in between");
      digitalWrite(relay1, HIGH);
      delay(delta);
      digitalWrite(relay1, LOW);
      delay(delta);      
    } else if (x == 6){ // opens & closes channel 2 (default = fast)
      if (DEBUG) Serial.println("opens and closes channel 2 with wait in between");
      digitalWrite(relay1, HIGH);
      delay(delta);
      digitalWrite(relay1, LOW);
      delay(delta);      
    }
    else if (x == 7){ // changes waiting time for 5 & 6 to default
      if (DEBUG) Serial.print("delta set to: ");
      delta=200;
      if (DEBUG) Serial.println(delta);
    } else if (x == 8){ // adds one second to waiting time for 5 & 6 
      if (DEBUG) Serial.print("adding 1 second to delta, now set to: ");
      if(delta<=MAX_INT-1000)
        delta+=1000;
      if (DEBUG) Serial.println(delta);
    } else if (x == 9){ // subtracts one second to waiting time for 5 & 6 
      if (DEBUG) Serial.print("subtracting 1 second to delta, now set to: ");
      if(delta>=1200)
        delta-=1000;
      if (DEBUG) Serial.println(delta);
    } else if (x == 0){ // closes all channels, safety
      digitalWrite(relay1, LOW);
      digitalWrite(relay2, LOW);      
      if (DEBUG) Serial.println("Closed all relays"); 
    }
    // feel free to integrate more functions or to change the ones above. 
    digitalWrite(led, LOW);
    char d = Serial.read();
    //Serial.println(d);
    if (d == 'd') 
      DEBUG=!DEBUG;
  }
}
