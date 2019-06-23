
const int reg_clk = 6;
const int dataA = 7;
const int dataB = 8;
const int feedback = 12;

void setup() {
  pinMode(reg_clk, OUTPUT);
  pinMode(dataA, OUTPUT);
  pinMode(dataB, OUTPUT);
  pinMode(feedback, INPUT);
  pinMode(LED_BUILTIN, OUTPUT);
  Serial.begin(57600);
}

void loop() {
  static unsigned lastA = 0;
  static unsigned lastB = 0;
  
  delayMicroseconds(1 + random(0, 100));

  unsigned did_read = digitalRead(feedback) ? 1 : 0;

  if(did_read != (lastA & lastB)) {
    Serial.println("Read check A failed");
  }

  const unsigned real_read = random(0, 2);
  const unsigned to_writeA = random(0, 2);
  const unsigned to_writeB = random(0, 2);

  Serial.print("Test: real (");
  Serial.print(real_read);
  Serial.print(") val (");
  Serial.print(to_writeA);
  Serial.print(" ");
  Serial.print(to_writeB);
  Serial.print(") last (");
  Serial.print(lastA);
  Serial.print(" ");
  Serial.print(lastB);
  Serial.print(")");
  Serial.println();
  
  
  digitalWrite(dataA, to_writeA);
  delayMicroseconds(1 + random(0, 100));
  digitalWrite(dataB, to_writeB);
  delayMicroseconds(1 + random(0, 100));
  digitalWrite(reg_clk, real_read);
  delayMicroseconds(1 + random(0, 100));
  
  if(real_read) {
    lastA = to_writeA;
    lastB = to_writeB;
  }

  did_read = digitalRead(feedback) ? 1 : 0;

  
  if(did_read != (lastA & lastB)) {
    Serial.println("Read check B failed");
  }

  digitalWrite(LED_BUILTIN, did_read);
  
  digitalWrite(reg_clk, 0);
  delayMicroseconds(100);

  delay(10);
}
