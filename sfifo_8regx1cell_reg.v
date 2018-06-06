
module sfifo_8regx1cell_reg (/*AUTO ARG*/
   // Outputs
   sfifo_reg_data_r, 
   // Inputs
   tst_gatedclock, rst_n, clk, wdata, sfifo_reg_wr_sel, cell_en
   );

/****************************************************** PARAMETERS ************************************************************/

// synopsys template
 parameter SF_DWIDTH = 64;                 // FIFO data width
 parameter SF_CELL_NUM = 1;                // Number of cells

/******************************************************** INPUTS **************************************************************/

 input tst_gatedclock;                             // Scan enable indication
 input rst_n;                              // Reset signal
 input clk;                                // Clock
 input [SF_DWIDTH-1:0] wdata;              // Data in bus
 input sfifo_reg_wr_sel;                   // Write signal form register file
 input [SF_CELL_NUM-1:0] cell_en;          // Byte (cell) enable signals to the cells

/******************************************************** OUTPUTS *************************************************************/

 output [SF_DWIDTH-1:0] sfifo_reg_data_r;  // Data out bus

/*************************************************** WIRE DECLARATIONS ********************************************************/

 wire [SF_CELL_NUM-1:0] sfifo_reg_cell_en; // Calculated write enable signals for the cells
 wire [SF_DWIDTH-1:0] sfifo_reg_data_r;    // Data out bus

/*************************************************** END OF DECLARATIONS ******************************************************/

// ******************************************************************************************
// Anding the register select signal(addr decode) with the cells enable signals (FIFO input)
// ******************************************************************************************

// Write enable signal for a FIFO cells
 assign sfifo_reg_cell_en = {SF_CELL_NUM{sfifo_reg_wr_sel}} & // Register write select signal
                             cell_en;                         // Cell enable signal

// ******************************************************************************************
// Cells Instantiation
// ******************************************************************************************

 sfifo_cell #(SF_DWIDTH/SF_CELL_NUM) sfifo_cell_0 (/*AUTO INST*/
		      // Outputs
		      .sfifo_cell_data_r (sfifo_reg_data_r[SF_DWIDTH/SF_CELL_NUM-1:0]),
		      // Inputs
		      .tst_gatedclock		(tst_gatedclock),
		      .rst_n		(rst_n),
		      .clk		(clk),
		      .wdata		(wdata[SF_DWIDTH/SF_CELL_NUM-1:0]),
		      .cell_en   	(sfifo_reg_cell_en[0]));

endmodule




