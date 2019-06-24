
const int x0_out = 6;
const int x1_out = 7;
const int y0_out = 8;
const int y1_out = 9;
const int o0_in = 10;
const int o1_in = 11;


void setup() {
  pinMode(x0_out, OUTPUT);
  pinMode(x1_out, OUTPUT);
  pinMode(y0_out, OUTPUT);
  pinMode(y1_out, OUTPUT);
  pinMode(o0_in, INPUT);
  pinMode(o1_in, INPUT);
  Serial.begin(57600);
}

void loop() {

  const unsigned x0 = random(0, 2);
  const unsigned x1 = random(0, 2);
  const unsigned y0 = random(0, 2);
  const unsigned y1 = random(0, 2);

  digitalWrite(x0_out, x0 ? HIGH : LOW);
  digitalWrite(x1_out, x1 ? HIGH : LOW);
  digitalWrite(y0_out, y0 ? HIGH : LOW);
  digitalWrite(y1_out, y1 ? HIGH : LOW);
//  delayMicroseconds(1 + random(0, 100));
  delayMicroseconds(100);

  const unsigned o0 = digitalRead(o0_in) ? 1 : 0;
  const unsigned o1 = digitalRead(o1_in) ? 1 : 0;

  Serial.print(x0);
  Serial.print(",");
  Serial.print(x1);
  Serial.print(" ");
  Serial.print(y0);
  Serial.print(",");
  Serial.print(y1);
  Serial.print(" -> ");
  Serial.print(o0);
  Serial.print(",");
  Serial.print(o1);
  Serial.println();
  delay(100);
}
