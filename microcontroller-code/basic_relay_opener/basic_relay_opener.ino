int incomingByte;
const int led = 13;
const int relay1 = 3;   
const int relay2 = 4;     
int delta = 200;
boolean hit = false;

void setup() {
  pinMode(led, OUTPUT);
  pinMode(relay1, OUTPUT);     
  pinMode(relay2, OUTPUT);     
  Serial.begin(9600);
}

void loop() {  
  if (Serial.available() > 0) {
    incomingByte = Serial.read();
    //Serial.println(incomingByte);

    digitalWrite(led, HIGH);
    digitalWrite(relay1, HIGH);
    digitalWrite(relay2, HIGH);
    delay(delta);
    digitalWrite(led, LOW);
    digitalWrite(relay1, LOW);
    digitalWrite(relay2, LOW);      
    delay(delta);      
  }
}
