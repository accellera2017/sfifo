

module ginc_cfg (/*AUTOARG*/
   // Outputs
   gdataout, gcout, 
   // Inputs
   gdatain
   );



/****************************************************** PARAMETERS ************************************************************/

 // synopsys template
 parameter WIDTH = 16;          

/******************************************************** INPUTS **************************************************************/

 input [WIDTH-1:0] gdatain;    // Input source to the incrementor

/******************************************************** OUTPUTS *************************************************************/

 output [WIDTH-1:0] gdataout;  // Incrementor output result
 output  	    gcout;     // Carry out 

/*************************************************** WIRE DECLARATIONS ********************************************************/

 wire [WIDTH:0]     gtmp;      // Serial 1's detector      

/*************************************************** END OF DECLARATIONS ******************************************************/


// ****************************************************************************************************************************
// Configurable incremntor logic
// ****************************************************************************************************************************

// ******************************************************************************************
// The gtmp bus is a serial 1's detector for example:
// 
// | Input source value | gtemp value |
// +--------------------+-------------+
// | 000111             | 001111      |
// +--------------------+-------------+
// | 000011             | 000111      |
// +--------------------+-------------+
// | 000001             | 000011      |
// +--------------------+-------------+
// | 000110             | 000001      |
// +--------------------+-------------+
// | 111010             | 000001      |
// +--------------------+-------------+
// | 111000             | 000001      |
// +--------------------+-------------+
// 
// ******************************************************************************************


// ******************************************************************
// Serial 1's detector logic
// ******************************************************************

// Initial the lsb bit
 assign gtmp[0] = 1'b1;

// Serial 1's detector   
 assign gtmp[WIDTH:1] = gtmp [WIDTH-1:0] & gdatain ;
   
// ******************************************************************
// Incrementor output results.
// The output result is determined according to the Serial 1's 
// detector (gtemp) and the input source, for example:
// 
// | Input ^  gtemp     | output      |
// | value    value     | result      |
// +--------------------+-------------+
// | 000111 ^ 001111    | 001000      |
// +--------------------+-------------+
// | 000011 ^ 000111    | 000100      |
// +--------------------+-------------+
// | 000001 ^ 000011    | 000010      |
// +--------------------+-------------+
// | 000110 ^ 000001    | 000111      |
// +--------------------+-------------+
// | 111010 ^ 000001    | 111011      |
// +--------------------+-------------+
// | 111000 ^ 000001    | 111001      |
// +--------------------+-------------+
// ******************************************************************

// Incrementor sum result according to the Serial 1's detector (gtemp)
// and the input source
 assign gdataout = gtmp [WIDTH-1:0] ^ gdatain ;

 // Carry out 
 assign gcout = gtmp[WIDTH] ^ 1'b0;
      
endmodule
