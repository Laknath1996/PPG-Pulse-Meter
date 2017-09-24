void drawBPMWaveform(){
// DRAW THE BPM WAVE FORM
   for (int i=0; i<rate.length-1; i++){
     rate[i] = rate[i+1];                  // shift the bpm Y coordinates over one pixel to the left
   }
// then limit and scale the BPM value
   BPM = min(BPM,200);                     // limit the highest BPM value to 200
   float dummy = map(BPM,0,200,750,500);   // map it to the heart rate window Y
   rate[rate.length-1] = int(dummy);       // set the rightmost pixel to the new data point value
 
 // GRAPH THE HEART RATE WAVEFORM
 stroke(250,0,0);                          // color of heart rate graph
 strokeWeight(2);                          // thicker line is easier to read
 noFill();
 beginShape();
 for (int i=0; i < rate.length-1; i++){    // variable 'i' will take the place of pixel x position
   vertex(i+980, rate[i]);                 // display history of heart rate datapoints
 }
 endShape();
}