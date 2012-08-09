import processing.serial.*;

int nb_flips = 0;
int nb_ones = 0;
int previous_nb_flips = 0;
int previous_nb_ones = 0;
static final int stats_intervale = 100;
int lastStatsTime = 0;
float[] vals;
int[] bytes = new int[500000];
int current_byte_ind = 0;
PFont f;


void setup() {
  size(400, 200);
  f = createFont("Arial", 16, true);
  println(Serial.list());
  // Using the first available port (might be different on your computer)
  Serial port = new Serial(this, Serial.list()[0], 115200);
 
  // An array of random values
  vals = new float[width];
  for (int i = 0; i < vals.length; i++) {
    vals[i] = height/2;
  }
}

void draw() {
  background(255);
  
  float ratio = (float(previous_nb_ones)/float(previous_nb_flips));
  
  // Draw lines connecting all points
  for (int i = 0; i < vals.length-1; i++) {
    stroke(0);
    strokeWeight(2);
    line(i,vals[i],i+1,vals[i+1]);
  }
  
  // Add a new random value
  vals[vals.length-1] = ratio * height;
  
  textFont(f,16);                 // STEP 4 Specify font to be used
  fill(0);                        // STEP 5 Specify font color 
  text("Ratio : " + ratio, 10, 20);  // STEP 6 Display Text 
  text("Rate : " + previous_nb_flips * 10 + " bit/sec", 200, 20);

  int elapsedTime = millis();
  int delta = elapsedTime - lastStatsTime;

  if(delta >= stats_intervale){
    // Slide everything down in the array
    for (int i = 0; i < vals.length-1; i++) {
      vals[i] = vals[i+1]; 
    }
    /*println("Nb 1 = " + nb_ones);
    println("Nb 0 = " + (nb_flips - nb_ones));
    println("Random ratio = " + ratio);
    println("-------------------------------------------");*/
    lastStatsTime = elapsedTime;
    previous_nb_ones = nb_ones;
    previous_nb_flips = nb_flips;
    nb_ones = 0;
    nb_flips = 0;
    //println(previous_nb_ones);
  }
}

//Je ne sais pas si cette fonction est bien juste car elle était faite pour les char au début
//Mais on s'en fou, je récupère bien le bon nombre de bit et c'est l'essentiel pour l'instant
boolean bitAt(byte b, int pointer) {
   return ((b & (1 << pointer)) != 0);
}

int nb_bytes = 0;
// Called whenever there is something available to read
void serialEvent(Serial port) {
  int val = port.read();
  if(val == 0){
    println("Youpi = " + nb_bytes);
    println(val);
    nb_bytes = 0;
  }
  nb_bytes++;
  byte b = byte(val);
  
  for (int i = 0; i < 8; i = i+1) {
    boolean bit = bitAt(b, i);
    nb_ones += int(bit);
    nb_flips++;
  }
  
  //Pour le calcul de la mediane
  bytes[current_byte_ind] = val;
  current_byte_ind++;
  if (current_byte_ind == 500000){
    bytes = sort(bytes);
    //On calcul la médiane en prenant la moyenne du chiffre du milieu et de celui d'après
    int median_1 = bytes[current_byte_ind / 2 - 1];
    int median_2 = bytes[(current_byte_ind / 2)];
    int med = (median_1 + median_2) / 2;
    println("Min : " + bytes[0]);
    println("Max : " + bytes[current_byte_ind - 1]);
    println("Median : " + med);
    println("-------------------------------------------");
    current_byte_ind = 0;
  }
}
