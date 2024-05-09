// CSE140L  
// see Structural Diagram in Lab2 assignment writeup
// fill in missing connections and parameters
module Top_Level #(parameter NS=60, NH=24, ND=7, NM=12)(
  input Reset,
        Timeset, 	  // manual buttons
        Alarmset,	  //	(five total)
		Minadv,
		Hrsadv,
		Dayadv,
        Datadv
        Monadv,
		Alarmon,
		Pulse,		  // digital clock, assume 1 cycle/sec.
// 6 decimal digit display (7 segment)
  output [6:0] S1disp, S0disp, 	   // 2-digit seconds display
               M1disp, M0disp, 
               H1disp, H0disp,
               D0disp,   // for part 2
               T1disp, T0disp,
               N1disp, N0disp,
  output logic Buzz);	           // alarm sounds
// internal connections (may need more)
  logic[6:0] TSec, TMin, THrs, TDays, TDate, TMonth, DateMod, // clock/time 
             AMin, AHrs, ADays;		   // alarm setting
  logic S_max, M_max, H_max, Date_max, 	   // "carry out" from sec -> min, min -> hrs, hrs -> days
        TMen, THen, AMen, AHen; 
// (almost) free-running seconds counter	-- be sure to set modulus inputs on ct_mod_N modules
  ct_mod_N  Sct(
// input ports
    .clk(Pulse), .rst(Reset), .en(!Timeset), .modulus(NS),
// output ports    
    .ct_out(TSec), .ct_max(S_max));

// minutes counter -- runs at either 1/sec while being set or 1/60sec normally
  ct_mod_N Mct(
// input ports
    .clk(Pulse), .rst(Reset), .en(S_max || Timeset && Minadv), .modulus(NS),
// output ports
    .ct_out(TMin), .ct_max(M_max));
//advance hours if both seconds and minutes at 59?
//or enable hours when HrsAdvg == Timeset == 1
  
// hours counter -- runs at either 1/sec or 1/60min
  ct_mod_N  Hct(
// input ports
    .clk(Pulse), .rst(Reset), .en(M_max && S_max || Timeset && Hrsadv), .modulus(NH),
// output ports
    .ct_out(THrs), .ct_max(H_max));

  //reset if 23:59:59
  
// days counter -- runs at either 1/sec or 1/60min
  ct_mod_N  Dct(
// input ports
    .clk(Pulse), .rst(Reset), .en(H_max && M_max && S_max || Timeset && Dayadv), .modulus(ND),
// output ports
    .ct_out(TDays), .ct_max());

    always_comb begin 
        if (TMonth == 0 || TMonth == 2 || TMonth == 4 || TMonth == 6 || TMonth == 7 || TMonth == 9 || TMonth == 11) begin 
            DateMod = 31;
        end else if (TMonth == 1) begin 
            DateMod = 29;
        end else begin 
            DateMod = 30;
        end
    end

  ct_mod_N  Tct(
// input ports
    .clk(Pulse), .rst(Reset), .en(H_max && M_max && S_max || Timeset && Datadv), .modulus(DateMod),
// output ports
    .ct_out(TDate), .ct_max(Date_max));

  ct_mod_N  Nct(
// input ports
    .clk(Pulse), .rst(Reset), .en(Date_max && H_max && M_max && S_max || Timeset && Monadv), .modulus(NM),
// output ports
    .ct_out(TMonth), .ct_max());

    // REGISTERS

// alarm set registers -- either hold or advance 1/sec while being set
  ct_mod_N Mreg(
// input ports
    .clk(Pulse), .rst(Reset), .en(Alarmset && Minadv), .modulus(NS),
// output ports    
    .ct_out(AMin), .ct_max()  ); 

  ct_mod_N  Hreg(
// input ports
    .clk(Pulse), .rst(Reset), .en(Alarmset && Hrsadv), .modulus(NH),
// output ports    
    .ct_out(AHrs), .ct_max() ); 

  ct_mod_N  Dreg(
// input ports
    .clk(Pulse), .rst(Reset), .en(Alarmset && Dayadv), .modulus(ND + 1),
// output ports    
    .ct_out(ADays), .ct_max() ); 

// display drivers (2 digits each, 6 digits total)
  lcd_int Sdisp(					  // seconds display
    .bin_in    (TSec),
	.Segment1  (S1disp),
	.Segment0  (S0disp)
	);

  lcd_int Mdisp(
    .bin_in    (Alarmset ? AMin : TMin),
    .Segment1  (M1disp),
    .Segment0  (M0disp)
	);

  lcd_int Hdisp(
    .bin_in    (Alarmset ? AHrs : THrs),
    .Segment1  (H1disp),
    .Segment0  (H0disp)
	);

  lcd_int Ddisp(
    .bin_in    (Alarmset ? ADays : TDays),
    .Segment1  (),
    .Segment0  (D0disp)
	);

  lcd_int Dadisp(
    .bin_in    (TDate + 1),
    .Segment1  (T1disp),
    .Segment0  (T0disp)
	);

  lcd_int Modisp(
    .bin_in    (TMonth + 1),
    .Segment1  (N1disp),
    .Segment0  (N0disp)
	);

// buzz off :)	  make the connections
  alarm a1(
    .tmin(TMin), .amin(AMin), .thrs(THrs), .ahrs(AHrs), .tdays(TDays), .adays(ADays), .buzz(Buzz)
  );

endmodule
