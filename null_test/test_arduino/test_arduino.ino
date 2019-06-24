
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

  const bool x_ready_null = (x0 == 0) && (x1 == 0);
  const bool x_done_null = (x0 == 1) && (x1 == 1);
  const bool y_ready_null = (y0 == 0) && (y1 == 0);
  const bool y_done_null = (y0 == 1) && (y1 == 1);
  
  const bool x_null = x_ready_null || x_done_null;
  const bool y_null = y_ready_null || y_done_null;

  // Default ready null
  unsigned ref_o0 = 0, ref_o1 = 0;

  if(x_null || y_null) {
    if(x_ready_null && y_ready_null) {
      ref_o0 = ref_o1 = 0;
    } else if((x_ready_null && y_done_null) || (y_ready_null && x_done_null)) {
      ref_o0 = ref_o1 = 1;
    } else if (x_done_null && y_done_null) {
      ref_o0 = ref_o1 = 1;
    } else if (x_done_null || y_done_null) {
      // data + done null = ready null out
      ref_o0 = ref_o1 = 0;
    } else if (x_ready_null || y_ready_null) {
      // data + ready null = ready null out
      ref_o0 = ref_o1 = 0;
    }
  } else {
    if(x1 && y1) {
      ref_o0 = 1;
      ref_o1 = 0;
    } else {
      ref_o0 = 0;
      ref_o1 = 1;
    }
  }

  if((o0 != ref_o0) || (o1 != ref_o1)) {
    Serial.print("  Mismatched ref ");
    Serial.print(ref_o0);
    Serial.print(",");
    Serial.print(ref_o1);
    Serial.println();
  }
  
  delay(100);
}
