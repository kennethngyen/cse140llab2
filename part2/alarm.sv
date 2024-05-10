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
          buzz = tmin == amin && thrs == ahrs && enable;
      end else if (adays == 6) begin 
          buzz = tmin == amin && thrs == ahrs && tdays != 0 && tdays != 6 && enable;
      end else begin 
          buzz = tmin == amin && thrs == ahrs && tdays != adays && tdays != adays + 1 && enable;
      end
endmodule
