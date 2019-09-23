int value=0;
int oldvalue=0;
void setup() {
  // initialize the serial communication:
  Serial.begin(9600);
  pinMode(LED_BUILTIN, OUTPUT);
}

void loop() {
  // send the value of analog input 0:
  value = analogRead(A0);
  Serial.println(value);
  if (value-oldvalue!=0){
   digitalWrite(LED_BUILTIN, HIGH);

    }
  // wait a bit for the analog-to-digital converter
  // to stabilize after the last reading:
  delay(2);
  oldvalue=value;
  digitalWrite(LED_BUILTIN, LOW);  
}
