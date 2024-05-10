// CSE140 lab 2  
// How does this work? How long does the alarm stay on? 
// (buzz is the alarm itself)
module alarm(
  input[6:0]   tmin,
               amin,
              thrs,
              ahrs,						 
              tdays,
              adays,
              enable,
  output logic buzz
);

  always_comb
    if (adays == 7) begin 
        buzz = enable && tmin == amin && thrs == ahrs;
    end else if (adays == 6) begin 
        buzz = enable && tmin == amin && thrs == ahrs && tdays != 0 && tdays != 6;
    end else begin 
        buzz = enable && tmin == amin && thrs == ahrs && tdays != adays && tdays != adays + 1;
    end
endmodule
