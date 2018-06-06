
module sfifo_cell (/*AUTO ARG*/
   // Outputs
   sfifo_cell_data_r, 
   // Inputs
   tst_gatedclock, rst_n, clk, wdata, cell_en
   );

/****************************************************** PARAMETERS ************************************************************/

// synopsys template
 parameter SF_CELL_WIDTH = 8;                   // FIFO cell data width (default is 8 - byte)

/******************************************************** INPUTS **************************************************************/

 input tst_gatedclock;                                  // Scan enable indication
 input rst_n;                                   // Reset signal
 input clk;                                     // Clock
 input [SF_CELL_WIDTH-1:0] wdata;               // Data in bus
 input cell_en;                                 // Write enable for FIFO cell

/******************************************************** OUTPUTS *************************************************************/

 output [SF_CELL_WIDTH-1:0] sfifo_cell_data_r;  // FIFO cell data out bus

/*************************************************** WIRE DECLARATIONS ********************************************************/

 wire sfifo_cell_wr;                            // Write signal to FIFO cell data out bus

/************************************************ PHYSICAL REG DECLARATIONS ***************************************************/

 reg [SF_CELL_WIDTH-1:0] sfifo_cell_data_r;     // FIFO cell data out bus
 
/*************************************************** END OF DECLARATIONS ******************************************************/

// ******************************************************************
// Gater for FIFO cell data out
// ******************************************************************

// Write enable signal for data out bus
   clock_gater cell_gater(
                          // Outputs
                          .gclk        (sfifo_cell_wr),
                          // Inputs
                          .enable      (cell_en),
                          .wait_r      (1'b0),
                          .clk         (clk),
                          .tst_gatedclock      (tst_gatedclock));

// ******************************************************************
// Cell data out bus 
// ******************************************************************

// Sample data in bus ipon cell write enable 
 always @(posedge sfifo_cell_wr or negedge rst_n) 
   if (~rst_n)
     sfifo_cell_data_r <= {SF_CELL_WIDTH{1'b0}};
   else
     sfifo_cell_data_r <= wdata; 

endmodule



