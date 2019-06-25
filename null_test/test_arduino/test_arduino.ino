
const int in_clk = 6;
const int in_data = 7;
const int in_rst = 8;

const int out_clk = 9;
const int out_data = 10;
const int out_rst = 11;

const int complete = 12;

void setup() {
  pinMode(in_clk, OUTPUT);
  pinMode(in_data, OUTPUT);
  pinMode(in_rst, OUTPUT);
  pinMode(out_clk, OUTPUT);
  pinMode(out_rst, OUTPUT);
  pinMode(out_data, INPUT);
  pinMode(complete, INPUT);

  digitalWrite(in_rst, LOW);
  digitalWrite(in_clk, LOW);

  Serial.begin(57600);
}

void write_word(unsigned long w, unsigned n) {
  digitalWrite(in_rst, HIGH);
  digitalWrite(in_clk, HIGH);
  digitalWrite(in_rst, LOW);
  digitalWrite(in_clk, LOW);

  for(unsigned i=0;i<n;++i) {
    digitalWrite(in_data, (w & (1L << i)) ? HIGH : LOW);
    digitalWrite(in_clk, HIGH);
    digitalWrite(in_clk, LOW);
  }
}

unsigned long long read_word(unsigned n) {
  unsigned long long w = 0;
  
  digitalWrite(out_rst, HIGH);
  digitalWrite(out_clk, HIGH);
  digitalWrite(out_rst, LOW);
  digitalWrite(out_clk, LOW);

  for(unsigned i=0;i<n;++i) {
    if(digitalRead(out_data) == HIGH)
      w |= (1LL << i);
    digitalWrite(out_clk, HIGH);
    digitalWrite(out_clk, LOW);
  }

  return w;
}

unsigned long ref_gate_out(unsigned long bits_in, unsigned vals[2][2]) {
  const unsigned x0 = (bits_in & 0b0001) ? 1 : 0;
  const unsigned x1 = (bits_in & 0b0010) ? 1 : 0;
  const unsigned y0 = (bits_in & 0b0100) ? 1 : 0;
  const unsigned y1 = (bits_in & 0b1000) ? 1 : 0;
/*
Serial.print("refgate x ");
Serial.print(x0);
Serial.print(x1);
Serial.print(" y ");
Serial.print(y0);
Serial.print(y1);
Serial.println();
  */
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
    if(vals[x1][y1]) {
      ref_o0 = 0;
      ref_o1 = 1;
    } else {
      ref_o0 = 1;
      ref_o1 = 0;
    }
  }

  return ref_o0 | (ref_o1 << 1);
}

void gates_test() {
  const int n_input_bits = 12;
  const int n_output_bits = 6;

  const unsigned long bits_out = random(0, 0b111111111111);

  write_word(bits_out, n_input_bits);

  // TODO: Wait for null completion
  delay(1);

  unsigned long rval = read_word(n_output_bits);

  const unsigned nand_vals[2][2] = {
    {1,1},
    {1,0},
  };
  const unsigned and_vals[2][2] = {
    {0,0},
    {0,1},
  };
  const unsigned or_vals[2][2] = {
    {0,1},
    {1,1},
  };
  const unsigned xor_vals[2][2] = {
    {0,1},
    {1,0},
  };

  unsigned long ref = ref_gate_out(bits_out, or_vals) | 
                      (ref_gate_out(bits_out >> 4, and_vals) << 2) | 
                      (ref_gate_out(bits_out >> 8, xor_vals) << 4);

  if(rval != ref) {
    Serial.print("Mismatch! ");
  }
  {
    Serial.print("ref ");
    Serial.print(ref);
    Serial.print(" rval ");
    Serial.print(rval);
    Serial.println();
  }
}

void test_full_adder() {
  const int n_input_bits = 6;
  const int n_output_bits = 4;

  unsigned a = random(0,2);
  unsigned b = random(0,2);
  unsigned c = random(0,2);

  unsigned ref_s = a + b + c;
  unsigned ref_c = 0;

  if(ref_s == 2) {
    ref_s = 0;
    ref_c = 1;
  } else if(ref_s == 3) {
    ref_s = 1;
    ref_c = 1;
  }

  unsigned long in_word = ((a ? 0b10L : 0b01L) << 0L) |
                          ((b ? 0b10L : 0b01L) << 2L) |
                          ((c ? 0b10L : 0b01L) << 4L);

  unsigned long out_word = ((ref_s ? 0b10L : 0b01L) << 0L) |
                           ((ref_c ? 0b10L : 0b01L) << 2L);

  if(random(0, 4) == 0) {
    in_word |= 0b111111L;
    out_word |= 0b1111L;
  } else if(random(0, 4) == 0) {
    in_word &= 0b00;
    out_word = 0;
  }

  write_word(in_word, n_input_bits);

//  while(digitalRead(complete) == LOW);

  unsigned long rval = read_word(n_output_bits);

  if(rval != out_word) 
  {
    Serial.print("Mismatch! ");
  }
  {
    Serial.print(" a ");
    Serial.print(a);
    Serial.print(" b ");
    Serial.print(b);
    Serial.print(" c ");
    Serial.print(c);
    Serial.print(" in ");
    Serial.print(in_word, BIN);
    Serial.print(" ref ");
    Serial.print(out_word, BIN);
    Serial.print(" rval ");
    Serial.print(rval, BIN);
    Serial.println();
  }
}

void test_inc() {
  const int n_input_bits = 2;
  const int n_output_bits = 4;

  unsigned a = random(0,2);

  unsigned ref_s = a + 1;
  unsigned ref_c = 0;

  if(ref_s == 2) {
    ref_s = 0;
    ref_c = 1;
  } else if(ref_s == 3) {
    ref_s = 1;
    ref_c = 1;
  }

  unsigned long in_word = ((a ? 0b10L : 0b01L) << 0L);

  unsigned long out_word = ((ref_s ? 0b10L : 0b01L) << 0L) |
                           ((ref_c ? 0b10L : 0b01L) << 2L);

  if(random(0, 4) == 0) {
    in_word |= 0b111111L;
    out_word |= 0b1111L;
  } else if(random(0, 4) == 0) {
    in_word &= 0b00;
    out_word = 0;
  }

  write_word(in_word, n_input_bits);

//  while(digitalRead(complete) == LOW);

  unsigned long rval = read_word(n_output_bits);

  if(rval != out_word) 
  {
    Serial.print("Mismatch! ");
  }
  {
    Serial.print(" a ");
    Serial.print(a);
    Serial.print(" in ");
    Serial.print(in_word, BIN);
    Serial.print(" ref ");
    Serial.print(out_word, BIN);
    Serial.print(" rval ");
    Serial.print(rval, BIN);
    Serial.println();
  }
}


void test_carry() {
  const int n_input_bits = 4;
  const int n_output_bits = 4;

  unsigned a = random(0,2);
  unsigned c = random(0,2);

  unsigned ref_s = a + c;
  unsigned ref_c = 0;

  if(ref_s == 2) {
    ref_s = 0;
    ref_c = 1;
  } else if(ref_s == 3) {
    ref_s = 1;
    ref_c = 1;
  }

  unsigned long in_word = ((a ? 0b10L : 0b01L) << 0L) |
                          ((c ? 0b10L : 0b01L) << 2L);

  unsigned long out_word = ((ref_s ? 0b10L : 0b01L) << 0L) |
                           ((ref_c ? 0b10L : 0b01L) << 2L);
/*
  if(random(0, 4) == 0) {
    in_word |= 0b111111L;
    out_word |= 0b1111L;
  } else if(random(0, 4) == 0) {
    in_word &= 0b00;
    out_word = 0;
  }*/

  write_word(in_word, n_input_bits);

//  while(digitalRead(complete) == LOW);

  unsigned long rval = read_word(n_output_bits);

  if(rval != out_word) 
  {
    Serial.print("Mismatch! ");
  }
  {
    Serial.print(" a ");
    Serial.print(a);
    Serial.print(" c ");
    Serial.print(c);
    Serial.print(" in ");
    Serial.print(in_word, BIN);
    Serial.print(" ref ");
    Serial.print(out_word, BIN);
    Serial.print(" rval ");
    Serial.print(rval, BIN);
    Serial.println();
  }
}


void test_full_inc() {
  const int n_input_bits = 32;
  const int n_output_bits = 32;

  unsigned long a = random(0, 65536L);
  unsigned long a_ = a+1;

  unsigned long in_word = 0;
  unsigned long out_word = 0;

  for(int i=0;i<n_input_bits/2;++i) {
    in_word |= ((a & (1L << i)) ? 0b10L : 0b01L) << (i*2);
    out_word |= ((a_ & (1L << i)) ? 0b10L : 0b01L) << (i*2);
  }

  write_word(in_word, n_input_bits);

  delay(1);

  unsigned long rval = read_word(n_output_bits);

  unsigned long decoded = 0;
  for(int i=0;i<n_output_bits/2;++i) {
    if(rval & (1L << ((2*i)+1))) {
      decoded |= (1L << i);
    }
  }

  if(rval != out_word) 
  {
    Serial.print("Mismatch! ");
  }
  {
    Serial.print(" a ");
    Serial.print(a);
    Serial.print(" in ");
    Serial.print(in_word, BIN);
    Serial.print(" ref ");
    Serial.print(out_word, BIN);
    Serial.print(" rval ");
    Serial.print(rval, BIN);
    Serial.print(" dec ");
    Serial.print(decoded);
    Serial.println();
  }
}

void loop() {
//  test_full_adder();
//  gates_test();
//  test_inc();
//  test_carry();
//  test_full_inc();

  const int n_output_bits = 53;
  unsigned long long rval = read_word(n_output_bits);

  unsigned long flags = (unsigned long)(rval >> 48LL);

  unsigned long decoded = 0;
  for(int i=0;i<24;++i) {
    if(rval & (1LL << ((2*i)+1))) {
      decoded |= (1LL << i);
    }
  }
#if 0
  if((flags & 0b11) == 0b10)
    Serial.print("work phase ");
  else if((flags & 0b11) == 0b01)
    Serial.print("high null phase ");
  else
    Serial.print("low null phase ");
  
  Serial.print(flags >> 2LL, BIN);
  Serial.print(" ");
  Serial.print((unsigned long)((rval >> 32LL) & 0b1111111111111111LL), BIN);
  Serial.print((unsigned long)(rval & 0b11111111111111111111111111111111LL), BIN);
  Serial.println();
#endif
  // Work phase
  
  static unsigned long long last = 0;
  static unsigned long long last_micros = micros();
  if((flags & 0b11) == 0b10) {
    if(decoded < last) {
      Serial.print("Counter roll-over in ");
      unsigned long long now = micros();
      Serial.println((unsigned long)(now - last_micros));
      last_micros = now;
    }
    last = decoded;
  }

  if((flags & 0b11) == 0b10) {
    Serial.print(" dec ");
    Serial.print(decoded);
    Serial.println();
  }
  
  delay(5);
}
