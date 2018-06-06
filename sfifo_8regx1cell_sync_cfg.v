
module sfifo_8regx1cell_sync_cfg (/*AUTO ARG*/
   // Outputs
   sfifo_full_r, sfifo_amfull_r, sfifo_hlfull_r, sfifo_amepty_r, 
   sfifo_epty_r, sfifo_rdata, sfifo_count_r, 
   // Inputs
   clk, wdata, cell_en, push, pop, flush, rst_n, tst_gatedclock
   );

/****************************************************** PARAMETERS ************************************************************/

// synopsys template
 parameter SF_DWIDTH = 64;                 // FIFO data width
 parameter SF_REG_NUM = 8;                 // Number of fifo stages
 parameter SF_AWIDTH = 3;                  // FIFO address width (log of SF_REG_NUM)
 parameter SF_CELL_NUM = 1;                // Number of cells (bytes) in a single stage

/******************************************************** INPUTS **************************************************************/

 input clk;                                // Clock
 input [SF_DWIDTH-1:0] wdata;              // FIFO write data
 input [SF_CELL_NUM-1:0] cell_en;          // Cell enable write signal
 input push;                               // Push request - increment the wr pointer
 input pop;                                // Pop request - increment the rd pointer
 input flush;                              // Flush signal
 input rst_n;                              // Reset signal
 input tst_gatedclock;                             // Scan enable indication

/******************************************************** OUTPUTS *************************************************************/

 output sfifo_full_r;                      // Full indication
 output sfifo_amfull_r;                    // Aolmost full indication
 output sfifo_hlfull_r;                    // Half full/empty indication
 output sfifo_amepty_r;                    // Empty indication
 output sfifo_epty_r;                      // Aolmost empty indication
 output [SF_DWIDTH-1:0] sfifo_rdata;       // FIFO data out
 output [SF_AWIDTH:0] sfifo_count_r;       // Counter value

/*************************************************** WIRE DECLARATIONS ********************************************************/

// Counter 
 wire [SF_AWIDTH:0] sfifo_count_dec;       // Counter's decremented value 
 wire [SF_AWIDTH:0] sfifo_count_inc;       // Counter's incremented value
 wire [SF_AWIDTH:0] sfifo_count_mx;        // Counter's increment/decrement mux
 wire [SF_AWIDTH:0] sfifo_count_flush_mx;  // Counter's flush mux
 wire sfifo_count_chg;                     // Counter changed indication
 wire sfifo_count_en;                      // Enable signal for the counter 
 wire sfifo_count_wr;                      // Write signal for the counter 
// Write Pointer
 wire [SF_AWIDTH-1:0] sfifo_wptr_inc;      // Write Pointer's incremented value 
 wire [SF_AWIDTH-1:0] sfifo_wptr_flush_mx; // Write Pointer's flush mux
 wire sfifo_wptr_en;                       // Enable signal for the write pointer
 wire sfifo_wptr_wr;                       // Write signal for the write pointer register
// Read Pointer
 wire [SF_AWIDTH-1:0] sfifo_rptr_inc;      // Read Pointer's incremented value
 wire [SF_AWIDTH-1:0] sfifo_rptr_flush_mx; // Read Pointer's flush mux
 wire sfifo_rptr_en;                       // Enable signal for the read pointer
 wire sfifo_rptr_wr;                       // Write signal for the read pointer
// Read Data Multiplexing
 wire [(SF_REG_NUM*SF_DWIDTH)-1:0] sfifo_rdata_in_r; // Read Data One-hot mux input
 wire [SF_DWIDTH-1:0] sfifo_rdata;         // Read Data One-hot mux output
 wire [SF_DWIDTH-1:0] sfifo_reg0_data_r;   // FIFO register 0 data out
 wire [SF_DWIDTH-1:0] sfifo_reg1_data_r;   // FIFO register 1 data out
 wire [SF_DWIDTH-1:0] sfifo_reg2_data_r;   // FIFO register 2 data out
 wire [SF_DWIDTH-1:0] sfifo_reg3_data_r;   // FIFO register 3 data out
 wire [SF_DWIDTH-1:0] sfifo_reg4_data_r;   // FIFO register 4 data out
 wire [SF_DWIDTH-1:0] sfifo_reg5_data_r;   // FIFO register 5 data out
 wire [SF_DWIDTH-1:0] sfifo_reg6_data_r;   // FIFO register 6 data out
 wire [SF_DWIDTH-1:0] sfifo_reg7_data_r;   // FIFO register 7 data out
// Almost-Full flag generation
 wire sfifo_amfull_upon_pop;               // Condition to rise Almost-Full in case pop will be requested
 wire sfifo_amfull_upon_push;              // Condition to rise Almost-Full in case push will be requested
 wire sfifo_amfull_pop_set;                // Almost-Full flag set condition due to pop
 wire sfifo_amfull_push_set;               // Almost-Full flag set condition due to push
 wire sfifo_amfull_set;                    // Almost-Full flag set condition
 wire sfifo_pop_xor_push;                  // Pop or push requests - not simultaneously
 wire sfifo_amfull_trig_rst;               // Almost-Full flag reset condition due to pop or push
 wire sfifo_amfull_rst;                    // Almost-Full flag reset condition due to pop or push or flush
 wire sfifo_amfull_en;                     // Almost-Full flag enable signal
 wire sfifo_amfull_ld;                     // Almost-Full flag load signal
 wire sfifo_amfull_emx;                    // Almost-Full flag enable mux
// Half flag generation
 wire sfifo_hlfull_upon_pop;               // Condition to rise Half in case pop will be requested
 wire sfifo_hlfull_upon_push;              // Condition to rise Half in case push will be requested
 wire sfifo_hlfull_pop_set;                // Half flag set condition due to pop
 wire sfifo_hlfull_push_set;               // Half flag set condition due to push
 wire sfifo_hlfull_set;                    // Half flag set condition
 wire sfifo_hlfull_trig_rst;               // Half flag reset condition due to pop or push
 wire sfifo_hlfull_rst;                    // Half flag reset condition due to pop or push or flush
 wire sfifo_hlfull_en;                     // Half flag enable signal
 wire sfifo_hlfull_ld;                     // Half flag load signal
 wire sfifo_hlfull_emx;                    // Half flag enable mux
// Almost-Empty flag generation
 wire sfifo_amepty_upon_pop;               // Condition to rise Almost-Empty in case pop will be requested
 wire sfifo_amepty_upon_push;              // Condition to rise Almost-Empty in case push will be requested
 wire sfifo_amepty_pop_set;                // Almost-Empty flag set condition due to pop
 wire sfifo_amepty_push_set;               // Almost-Empty flag set condition due to push
 wire sfifo_amepty_set;                    // Almost-Empty flag set condition
 wire sfifo_amepty_trig_rst;               // Almost-Empty flag reset condition due to pop or push
 wire sfifo_amepty_rst;                    // Almost-Empty flag reset condition due to pop or push or flush
 wire sfifo_amepty_en;                     // Almost-Empty flag enable signal
 wire sfifo_amepty_ld;                     // Almost-Empty flag load signal
 wire sfifo_amepty_emx;                    // Almost-Empty flag enable mux
// Full flag generation
 wire sfifo_full_upon_push;                // Condition to rise Full in case push will be requested
 wire sfifo_full_set;                      // Full flag set condition
 wire sfifo_full_rst;                      // Full flag reset condition due to pop 
 wire sfifo_full_en;                       // Full flag enable signal
 wire sfifo_full_ld;                       // Full flag load signal
 wire sfifo_full_flush_mx;                 // Full flag flush mux
 wire sfifo_full_emx;                      // Full flag enable mux
// Empty flag generation
 wire sfifo_epty_upon_pop;                 // Condition to rise Empty in case pop will be requested
 wire sfifo_epty_set;                      // Empty flag set condition
 wire sfifo_epty_rst;                      // Empty flag reset condition due to push 
 wire sfifo_epty_en;                       // Empty flag enable signal
 wire sfifo_epty_ld;                       // Empty flag load signal
 wire sfifo_epty_flush_mx;                 // Empty flag flush mux
 wire sfifo_epty_emx;                      // Empty flag enable mux


/**************************************************** REG DECLARATIONS ********************************************************/

// FIFO Register's Write select Signals
 integer w;                                // Loop index of Address decoding on the write pointer
 reg [SF_REG_NUM-1:0] sfifo_reg_wr_sel;    // Address decoding on the write pointer
// FIFO Register's Read select Signals
 integer r;                                // Loop index of Address decoding on the read pointer
 reg [SF_REG_NUM-1:0] sfifo_rdata_sel;     // Address decoding on the read pointer

/************************************************ PHYSICAL REG DECLARATIONS ***************************************************/

// FIFO counter
 reg [SF_AWIDTH:0] sfifo_count_r;          // FIFO counter register
// FIFO pointers
 reg [SF_AWIDTH-1:0] sfifo_wptr_r;         // FIFO Write pointer register
 reg [SF_AWIDTH-1:0] sfifo_rptr_r;         // FIFO Read pointer register
// FIFO Flags
 reg sfifo_amfull_r;                       // Almost-Full flag Register
 reg sfifo_hlfull_r;                       // Half flag Register
 reg sfifo_amepty_r;                       // Almost-Empty flag Register
 reg sfifo_full_r;                         // Full flag Register
 reg sfifo_epty_r;                         // Empty flag Register

/*************************************************** END OF DECLARATIONS ******************************************************/

// ****************************************************************************************************************************
//                                                       FIFO Logic
// ****************************************************************************************************************************

// ******************************************************************************************
// Counter Mechanism
// ******************************************************************************************

// ******************************************************************
// Counter's decremented value
// ******************************************************************

// Decremented value is selected in case pop is requested
 gdec_cfg #(SF_AWIDTH+1) gdec_count (/*AUTO INST*/
		   // Outputs
		   .gdataout		(sfifo_count_dec),
		   .gcout		(),
		   // Inputs
		   .gdatain		(sfifo_count_r));

// ******************************************************************
// Counter's incremented value
// ******************************************************************

// Incremented value is selected in case push is requested
 ginc_cfg #(SF_AWIDTH+1) ginc_count (/*AUTO INST*/
		   // Outputs
		   .gdataout		(sfifo_count_inc),
		   .gcout		(),
		   // Inputs
		   .gdatain		(sfifo_count_r));

// ******************************************************************
// Counter's increment/decrement mux
// ******************************************************************

// Select incremented value when push is requested.
 assign sfifo_count_mx = (push)? sfifo_count_inc :          // Counter's incremented value
                                 sfifo_count_dec;           // Counter's decremented value    

// ******************************************************************
// Counter's flush mux
// ******************************************************************

// Selected when flush is asserted
 assign sfifo_count_flush_mx = (flush)? {SF_AWIDTH+1{1'b0}} : // Counter's flush value 
                                        sfifo_count_mx;       // Counter's steady-state value  

// ******************************************************************
// Counter changed indication
// ******************************************************************

// Counter is changed upon decrement or increment indication (not both!)
 assign sfifo_count_chg = push ^                            // Upon inc ind - push request
                          pop;                              // Upon dec ind - pop request
 
// ******************************************************************
// Enable signal for the counter
// ******************************************************************

// Enable signal valid when counter is changed or when loading its flush-value
 assign sfifo_count_en = sfifo_count_chg |                  // Upon change (dec^inc)
                         flush;                             // When loading counter's flush-value
 
// ******************************************************************
// Write signal for the counter 
// ******************************************************************

// Gater for counter register
 clock_gater sfifo_count_gater(
                          // Outputs
                          .gclk        (sfifo_count_wr),
                          // Inputs
                          .enable      (sfifo_count_en),
                          .wait_r      (1'b0),         
                          .clk         (clk),
                          .tst_gatedclock      (tst_gatedclock));

// ******************************************************************
// FIFO counter register
// ******************************************************************

// Sample counter value upon counter Inc/Dec indication or on counter flush 
 always @(posedge sfifo_count_wr or negedge rst_n) 
   if (~rst_n)
     sfifo_count_r <= {SF_AWIDTH+1{1'b0}};
   else
     sfifo_count_r <= sfifo_count_flush_mx; 

// ******************************************************************************************
// Write Pointer
// ******************************************************************************************

// ******************************************************************
// Write Pointer's incremented value
// ******************************************************************

// Incremented value is selected in case push is requested
 ginc_cfg #(SF_AWIDTH) ginc_wptr (/*AUTO INST*/
		   // Outputs
		   .gdataout		(sfifo_wptr_inc),
		   .gcout		(),
		   // Inputs
		   .gdatain		(sfifo_wptr_r));

// ******************************************************************
// Write Pointer's flush mux
// ******************************************************************

// Selected when flush is asserted
 assign sfifo_wptr_flush_mx = (flush)? {SF_AWIDTH{1'b0}} :  // Write Pointer's flush value
                                       sfifo_wptr_inc;      // Write Pointer's next value    

// ******************************************************************
// Enable signal for the write pointer
// ******************************************************************

// Enable signal valid when write pointer is changed or when loading its flush-value
 assign sfifo_wptr_en = push |                              // Upon push 
                        flush;                              // When loading write pointer's flush-value
 
// ******************************************************************
// Write signal for the write pointer register
// ******************************************************************

// Gater for write pointer register
 clock_gater sfifo_wptr_gater(
                          // Outputs
                          .gclk        (sfifo_wptr_wr),
                          // Inputs
                          .enable      (sfifo_wptr_en),
                          .wait_r      (1'b0),         
                          .clk         (clk),
                          .tst_gatedclock      (tst_gatedclock));

// ******************************************************************
// FIFO Write pointer register
// ******************************************************************

// Sample write pointer value upon write pointer Inc/Dec indication or on write pointer flush 
 always @(posedge sfifo_wptr_wr or negedge rst_n) 
   if (~rst_n)
     sfifo_wptr_r <= {SF_AWIDTH{1'b0}};
   else
     sfifo_wptr_r <= sfifo_wptr_flush_mx; 

// ******************************************************************************************
// FIFO Register's Write Enable Signals 
// ******************************************************************************************

// ******************************************************************
// Address decoding on the write pointer value
// ******************************************************************

// Register is selected when Address decoding on the write pointer value matches its index
 always @(/*AUTO SENSE*/sfifo_wptr_r)
   begin
     for (w=0; w<SF_REG_NUM; w=w+1)
       sfifo_reg_wr_sel[w] = ({{32-SF_AWIDTH{1'b0}},sfifo_wptr_r} == w);
   end 

// ******************************************************************************************
// Read Pointer
// ******************************************************************************************

// ******************************************************************
// Read Pointer's incremented value
// ******************************************************************

// Incremented value is selected in case push is requested
 ginc_cfg #(SF_AWIDTH) ginc_rptr (/*AUTO INST*/
		   // Outputs
		   .gdataout		(sfifo_rptr_inc),
		   .gcout		(),
		   // Inputs
		   .gdatain		(sfifo_rptr_r));

// ******************************************************************
// Read Pointer's flush mux
// ******************************************************************

// Selected when flush is asserted
 assign sfifo_rptr_flush_mx = (flush)? {SF_AWIDTH{1'b0}} :  // Read Pointer's flush value
                                       sfifo_rptr_inc;      // Read Pointer's next value    

// ******************************************************************
// Enable signal for the read pointer
// ******************************************************************

// Enable signal valid when read pointer is changed or when loading its flush-value
 assign sfifo_rptr_en = pop |                               // Upon pop 
                        flush;                              // When loading read pointer's flush-value
 
// ******************************************************************
// Write signal for the read pointer 
// ******************************************************************

// Gater for read pointer register
 clock_gater sfifo_rptr_gater(
                          // Outputs
                          .gclk        (sfifo_rptr_wr),
                          // Inputs
                          .enable      (sfifo_rptr_en),
                          .wait_r      (1'b0),         
                          .clk         (clk),
                          .tst_gatedclock      (tst_gatedclock));

// ******************************************************************
// FIFO Read pointer register
// ******************************************************************

// Sample read pointer value upon read pointer Inc/Dec indication or on read pointer flush 
 always @(posedge sfifo_rptr_wr or negedge rst_n) 
   if (~rst_n)
     sfifo_rptr_r <= {SF_AWIDTH{1'b0}};
   else
     sfifo_rptr_r <= sfifo_rptr_flush_mx; 

// ******************************************************************************************
// Read Data Multiplexing
// ******************************************************************************************

// ******************************************************************
// Read Data One-hot mux input
// ******************************************************************

// Concatenation of all FIFO registers data out
 assign sfifo_rdata_in_r = {sfifo_reg7_data_r,              // Register 7 data out
                            sfifo_reg6_data_r,              // Register 6 data out
                            sfifo_reg5_data_r,              // Register 5 data out
                            sfifo_reg4_data_r,              // Register 4 data out
                            sfifo_reg3_data_r,              // Register 3 data out
                            sfifo_reg2_data_r,              // Register 2 data out
                            sfifo_reg1_data_r,              // Register 1 data out
                            sfifo_reg0_data_r};             // Register 0 data out

// ******************************************************************
// Read Data One-hot mux control 
// ******************************************************************

// Register is selected when Address decoding on the read pointer value matches its index
 always @(/*AUTO SENSE*/sfifo_rptr_r)
   begin
     for (r=0; r<SF_REG_NUM; r=r+1)
       sfifo_rdata_sel[r] = ({{32-SF_AWIDTH{1'b0}},sfifo_rptr_r} == r);
   end 

// ******************************************************************
// Read Data One-hot mux 
// ******************************************************************

// Select relevant register data out
 gmux_one_hot_cfg #(SF_DWIDTH,SF_REG_NUM) gmux_one_hot_rdata (/*AUTO INST*/
				    // Outputs
				    .dataout(sfifo_rdata),
				    // Inputs
				    .datain(sfifo_rdata_in_r),
				    .sel(sfifo_rdata_sel));

// ****************************************************************************************************************************
//                                                   FIFO Flags Generation
// ****************************************************************************************************************************

// ******************************************************************************************
//                Almost-Full flag generation - Set-Reset Register
// ******************************************************************************************

// ******************************************************************
// Condition to rise Almost-Full in case pop/push will be requested
// ******************************************************************

// Condition to rise Almost-Full in case pop will be requested
 assign sfifo_amfull_upon_pop = ({{32-(SF_AWIDTH+1){1'b0}},sfifo_count_r} == SF_REG_NUM);

// Condition to rise Almost-Full in case push will be requested
 assign sfifo_amfull_upon_push = ({{32-(SF_AWIDTH+1){1'b0}},sfifo_count_r} == SF_REG_NUM-2);

// ******************************************************************
// Almost-Full flag set condition
// ******************************************************************

// Almost-Full flag set condition due to pop
 assign sfifo_amfull_pop_set = sfifo_amfull_upon_pop &      // Condition for Almost-Full in case of pop  
                               pop &                        // Pop request
                              ~push &                       // In order to exclude push||pop case
                              ~sfifo_amfull_r;              // Current Almost-Full flag is low

// Almost-Full flag set condition due to push
 assign sfifo_amfull_push_set = sfifo_amfull_upon_push &    // Condition for Almost-Full in case of push  
                                push &                      // Push request
                               ~pop &                       // In order to exclude push||pop case
                               ~sfifo_amfull_r;             // Current Almost-Full flag is low

// Almost-Full flag set condition
 assign sfifo_amfull_set = sfifo_amfull_pop_set |           // Almost-Full flag set condition due to pop  
                           sfifo_amfull_push_set;           // Almost-Full flag set condition due to push

// ******************************************************************
// Almost-Full flag reset condition 
// ******************************************************************

// Pop or push requests - not simultaneously 
 assign sfifo_pop_xor_push = pop ^ push;                    // Pop or push (not simultaneously!)

// Almost-Full flag reset condition due to pop or push (not simultaneously!)
 assign sfifo_amfull_trig_rst = sfifo_amfull_r &            // Current Almost-Full flag is high  
                                sfifo_pop_xor_push;         // Pop or push requests - not both 

// Almost-Full flag reset condition due to pop or push or flush
 assign sfifo_amfull_rst = sfifo_amfull_trig_rst |          // Almost-Full reset due to pop or push
                           flush;                           // Almost-Full reset due to flush 

// ******************************************************************
// Almost-Full flag enable signal
// ******************************************************************

// Almost-Full flag enable when set or reset condition
 assign sfifo_amfull_en = sfifo_amfull_set |                // Almost-Full set condition
                          sfifo_amfull_rst;                 // Almost-Full reset condition 

// ******************************************************************
// Almost-Full flag load signal
// ******************************************************************

// Almost-Full flag next value
 assign sfifo_amfull_ld = sfifo_amfull_set &                // Almost-Full set condition
                         ~sfifo_amfull_rst;                 // Almost-Full reset condition 

// ******************************************************************
// Almost-Full flag enable mux
// ******************************************************************
  
 assign sfifo_amfull_emx = (sfifo_amfull_en)? sfifo_amfull_ld : // Load signal
                                              sfifo_amfull_r;   // Previous Value      

// ******************************************************************
// Almost-Full flag Register
// ******************************************************************

// Sampled Almost-Full flag
 always @(posedge clk or negedge rst_n) 
   if (~rst_n)
     sfifo_amfull_r <= 1'b0;
   else
     sfifo_amfull_r <= sfifo_amfull_emx; 

// ******************************************************************************************
//                Half flag generation - Set-Reset Register
// ******************************************************************************************

// ******************************************************************
// Condition to rise Half in case pop/push will be requested
// ******************************************************************

// Condition to rise Half in case pop will be requested
 assign sfifo_hlfull_upon_pop = ({{32-(SF_AWIDTH+1){1'b0}},sfifo_count_r} == (SF_REG_NUM/2)+1);

// Condition to rise Half in case push will be requested
 assign sfifo_hlfull_upon_push = ({{32-(SF_AWIDTH+1){1'b0}},sfifo_count_r} == (SF_REG_NUM/2)-1);

// ******************************************************************
// Half flag set condition
// ******************************************************************

// Half flag set condition due to pop
 assign sfifo_hlfull_pop_set = sfifo_hlfull_upon_pop &      // Condition for Half in case of pop  
                               pop &                        // Pop request
                              ~push &                       // In order to exclude push||pop case
                              ~sfifo_hlfull_r;              // Current Half flag is low

// Half flag set condition due to push
 assign sfifo_hlfull_push_set = sfifo_hlfull_upon_push &    // Condition for Half in case of push  
                                push &                      // Push request
                               ~pop &                       // In order to exclude push||pop case
                               ~sfifo_hlfull_r;             // Current Half flag is low

// Half flag set condition
 assign sfifo_hlfull_set = sfifo_hlfull_pop_set |           // Half flag set condition due to pop  
                           sfifo_hlfull_push_set;           // Half flag set condition due to push

// ******************************************************************
// Half flag reset condition 
// ******************************************************************

// Half flag reset condition due to pop or push (not simultaneously!)
 assign sfifo_hlfull_trig_rst = sfifo_hlfull_r &            // Current Half flag is high  
                                sfifo_pop_xor_push;         // Pop or push requests - not both 

// Half flag reset condition due to pop or push or flush
 assign sfifo_hlfull_rst = sfifo_hlfull_trig_rst |          // Half reset due to pop or push
                           flush;                           // Half reset due to flush 

// ******************************************************************
// Half flag enable signal
// ******************************************************************

// Half flag enable when set or reset condition
 assign sfifo_hlfull_en = sfifo_hlfull_set |                // Half set condition
                          sfifo_hlfull_rst;                 // Half reset condition 

// ******************************************************************
// Half flag load signal
// ******************************************************************

// Half flag next value
 assign sfifo_hlfull_ld = sfifo_hlfull_set &                // Half set condition
                         ~sfifo_hlfull_rst;                 // Half reset condition 

// ******************************************************************
// Half flag enable mux
// ******************************************************************
  
 assign sfifo_hlfull_emx = (sfifo_hlfull_en)? sfifo_hlfull_ld : // Load signal
                                              sfifo_hlfull_r;   // Previous Value      

// ******************************************************************
// Half flag Register
// ******************************************************************

// Sampled Half flag
 always @(posedge clk or negedge rst_n) 
   if (~rst_n)
     sfifo_hlfull_r <= 1'b0;
   else
     sfifo_hlfull_r <= sfifo_hlfull_emx; 

// ******************************************************************************************
//                Almost-Empty flag generation - Set-Reset Register
// ******************************************************************************************

// ******************************************************************
// Condition to rise Almost-Empty in case pop/push will be requested
// ******************************************************************

// Condition to rise Almost-Empty in case pop will be requested
 assign sfifo_amepty_upon_pop = (sfifo_count_r == {{(SF_AWIDTH-1){1'b0}},2'h2});

// Condition to rise Almost-Empty in case push will be requested
 assign sfifo_amepty_upon_push = (sfifo_count_r == {SF_AWIDTH+1{1'b0}});

// ******************************************************************
// Almost-Empty flag set condition
// ******************************************************************

// Almost-Empty flag set condition due to pop
 assign sfifo_amepty_pop_set = sfifo_amepty_upon_pop &      // Condition for Almost-Empty in case of pop  
                               pop &                        // Pop request
                              ~push &                       // In order to exclude push||pop case
                              ~sfifo_amepty_r;              // Current Almost-Empty flag is low

// Almost-Empty flag set condition due to push
 assign sfifo_amepty_push_set = sfifo_amepty_upon_push &    // Condition for Almost-Empty in case of push  
                                push &                      // Push request
                               ~pop &                       // In order to exclude push||pop case
                               ~sfifo_amepty_r;             // Current Almost-Empty flag is low

// Almost-Empty flag set condition
 assign sfifo_amepty_set = sfifo_amepty_pop_set |           // Almost-Empty flag set condition due to pop  
                           sfifo_amepty_push_set;           // Almost-Empty flag set condition due to push

// ******************************************************************
// Almost-Empty flag reset condition 
// ******************************************************************

// Almost-Empty flag reset condition due to pop or push (not simultaneously!)
 assign sfifo_amepty_trig_rst = sfifo_amepty_r &            // Current Almost-Empty flag is high  
                                sfifo_pop_xor_push;         // Pop or push requests - not both 

// Almost-Empty flag reset condition due to pop or push or flush
 assign sfifo_amepty_rst = sfifo_amepty_trig_rst |          // Almost-Empty reset due to pop or push
                           flush;                           // Almost-Empty reset due to flush 

// ******************************************************************
// Almost-Empty flag enable signal
// ******************************************************************

// Almost-Empty flag enable when set or reset condition
 assign sfifo_amepty_en = sfifo_amepty_set |                // Almost-Empty set condition
                          sfifo_amepty_rst;                 // Almost-Empty reset condition 

// ******************************************************************
// Almost-Empty flag load signal
// ******************************************************************

// Almost-Empty flag next value
 assign sfifo_amepty_ld = sfifo_amepty_set &                // Almost-Empty set condition
                         ~sfifo_amepty_rst;                 // Almost-Empty reset condition 

// ******************************************************************
// Almost-Empty flag enable mux
// ******************************************************************
  
 assign sfifo_amepty_emx = (sfifo_amepty_en)? sfifo_amepty_ld : // Load signal
                                              sfifo_amepty_r;   // Previous Value      

// ******************************************************************
// Almost-Empty flag Register
// ******************************************************************

// Sampled Almost-Empty flag
 always @(posedge clk or negedge rst_n) 
   if (~rst_n)
     sfifo_amepty_r <= 1'b0;
   else
     sfifo_amepty_r <= sfifo_amepty_emx; 

// ******************************************************************************************
//                      Full flag generation - Set-Reset Register
// ******************************************************************************************

// ******************************************************************
// Condition to rise Full in case push will be requested
// ******************************************************************

// Condition to rise Full flag when push is reqested
 assign sfifo_full_upon_push = ({{32-(SF_AWIDTH+1){1'b0}},sfifo_count_r} == SF_REG_NUM-1);

// ******************************************************************
// Full flag set condition
// ******************************************************************

// Full flag set condition due to push
 assign sfifo_full_set = sfifo_full_upon_push &             // Condition for Full in case of push  
                         push &                             // Push request
                        ~pop &                              // Not pop request (in push||pop Full is not set)
                        ~sfifo_full_r;                      // Current Full flag is low

// ******************************************************************
// Full flag reset condition 
// ******************************************************************

// Full flag reset condition due to pop 
 assign sfifo_full_rst = sfifo_full_r &                     // Current Full flag is high  
                         pop;                               // Pop request

// ******************************************************************
// Full flag enable signal
// ******************************************************************

// Full flag enable when set or reset condition or flush
 assign sfifo_full_en = sfifo_full_set |                    // Full set condition
                        sfifo_full_rst |                    // Full reset condition 
                        flush;                              // Flush

// ******************************************************************
// Full flag load signal
// ******************************************************************

// Full flag next value
 assign sfifo_full_ld = sfifo_full_set &                    // Full set condition
                       ~sfifo_full_rst;                     // Full reset condition 

// ******************************************************************
// Full flag flush mux
// ******************************************************************
  
 assign sfifo_full_flush_mx = (flush)? 1'b0 :               // Flush-value
                                       sfifo_full_ld;       // Load signal (in steady state)

// ******************************************************************
// Full flag enable mux
// ******************************************************************
  
 assign sfifo_full_emx = (sfifo_full_en)? sfifo_full_flush_mx : // Flush mux value
                                          sfifo_full_r;         // Previous Value      

// ******************************************************************
// Full flag Register
// ******************************************************************

// Sampled Full flag
 always @(posedge clk or negedge rst_n) 
   if (~rst_n)
     sfifo_full_r <= 1'b0;
   else
     sfifo_full_r <= sfifo_full_emx; 

// ******************************************************************************************
//                      Empty flag generation - Set-Reset Register
// ******************************************************************************************

// ******************************************************************
// Condition to rise Empty in case push will be requested
// ******************************************************************

// Condition to rise Empty flag when pop is reqested
 assign sfifo_epty_upon_pop = (sfifo_count_r == {{SF_AWIDTH{1'b0}},1'b1});

// ******************************************************************
// Empty flag set condition
// ******************************************************************

// Empty flag set condition due to pop
 assign sfifo_epty_set = sfifo_epty_upon_pop &              // Condition for Empty in case of pop  
                         pop &                              // Pop request
                        ~push &                             // Not push request (in push||pop Empty is not set)
                        ~sfifo_epty_r;                      // Current Empty flag is low

// ******************************************************************
// Empty flag reset condition 
// ******************************************************************

// Empty flag reset condition due to push
 assign sfifo_epty_rst = sfifo_epty_r &                     // Current Empty flag is high  
                         push;                              // Pop request

// ******************************************************************
// Empty flag enable signal
// ******************************************************************

// Empty flag enable when set or reset condition or flush
 assign sfifo_epty_en = sfifo_epty_set |                    // Empty set condition
                        sfifo_epty_rst |                    // Empty reset condition 
                        flush;                              // Flush

// ******************************************************************
// Empty flag load signal
// ******************************************************************

// Empty flag next value
 assign sfifo_epty_ld = sfifo_epty_set &                    // Empty set condition
                       ~sfifo_epty_rst;                     // Empty reset condition 

// ******************************************************************
// Empty flag flush mux
// ******************************************************************
  
 assign sfifo_epty_flush_mx = (flush)? 1'b1 :               // Flush-value
                                       sfifo_epty_ld;       // Load signal (in steady state)

// ******************************************************************
// Empty flag enable mux
// ******************************************************************
  
 assign sfifo_epty_emx = (sfifo_epty_en)? sfifo_epty_flush_mx : // Flush mux value
                                          sfifo_epty_r;         // Previous Value      

// ******************************************************************
// Empty flag Register
// ******************************************************************

// Sampled Empty flag - Reset value is 1'b1 
 always @(posedge clk or negedge rst_n) 
   if (~rst_n)
     sfifo_epty_r <= 1'b1;                          
   else
     sfifo_epty_r <= sfifo_epty_emx; 

// ****************************************************************************************************************************
//                                                 FIFO Registers Instatiation
// ****************************************************************************************************************************

// Register number 0
 sfifo_8regx1cell_reg #(SF_DWIDTH,SF_CELL_NUM) sfifo_reg_0 (/*AUTO INST*/
		      // Outputs
		      .sfifo_reg_data_r	(sfifo_reg0_data_r[SF_DWIDTH-1:0]),
		      // Inputs
		      .tst_gatedclock		(tst_gatedclock),
		      .rst_n		(rst_n),
		      .clk		(clk),
		      .wdata	        (wdata[SF_DWIDTH-1:0]),
		      .sfifo_reg_wr_sel	(sfifo_reg_wr_sel[0]),
		      .cell_en		(cell_en[SF_CELL_NUM-1:0]));

// Register number 1
 sfifo_8regx1cell_reg #(SF_DWIDTH,SF_CELL_NUM) sfifo_reg_1 (/*AUTO INST*/
		      // Outputs
		      .sfifo_reg_data_r	(sfifo_reg1_data_r[SF_DWIDTH-1:0]),
		      // Inputs
		      .tst_gatedclock		(tst_gatedclock),
		      .rst_n		(rst_n),
		      .clk		(clk),
		      .wdata	        (wdata[SF_DWIDTH-1:0]),
		      .sfifo_reg_wr_sel	(sfifo_reg_wr_sel[1]),
		      .cell_en		(cell_en[SF_CELL_NUM-1:0]));

// Register number 2
 sfifo_8regx1cell_reg #(SF_DWIDTH,SF_CELL_NUM) sfifo_reg_2 (/*AUTO INST*/
		      // Outputs
		      .sfifo_reg_data_r	(sfifo_reg2_data_r[SF_DWIDTH-1:0]),
		      // Inputs
		      .tst_gatedclock		(tst_gatedclock),
		      .rst_n		(rst_n),
		      .clk		(clk),
		      .wdata	        (wdata[SF_DWIDTH-1:0]),
		      .sfifo_reg_wr_sel	(sfifo_reg_wr_sel[2]),
		      .cell_en		(cell_en[SF_CELL_NUM-1:0]));

// Register number 3
 sfifo_8regx1cell_reg #(SF_DWIDTH,SF_CELL_NUM) sfifo_reg_3 (/*AUTO INST*/
		      // Outputs
		      .sfifo_reg_data_r	(sfifo_reg3_data_r[SF_DWIDTH-1:0]),
		      // Inputs
		      .tst_gatedclock		(tst_gatedclock),
		      .rst_n		(rst_n),
		      .clk		(clk),
		      .wdata	        (wdata[SF_DWIDTH-1:0]),
		      .sfifo_reg_wr_sel	(sfifo_reg_wr_sel[3]),
		      .cell_en		(cell_en[SF_CELL_NUM-1:0]));

// Register number 4
 sfifo_8regx1cell_reg #(SF_DWIDTH,SF_CELL_NUM) sfifo_reg_4 (/*AUTO INST*/
		      // Outputs
		      .sfifo_reg_data_r	(sfifo_reg4_data_r[SF_DWIDTH-1:0]),
		      // Inputs
		      .tst_gatedclock		(tst_gatedclock),
		      .rst_n		(rst_n),
		      .clk		(clk),
		      .wdata	        (wdata[SF_DWIDTH-1:0]),
		      .sfifo_reg_wr_sel	(sfifo_reg_wr_sel[4]),
		      .cell_en		(cell_en[SF_CELL_NUM-1:0]));

// Register number 5
 sfifo_8regx1cell_reg #(SF_DWIDTH,SF_CELL_NUM) sfifo_reg_5 (/*AUTO INST*/
		      // Outputs
		      .sfifo_reg_data_r	(sfifo_reg5_data_r[SF_DWIDTH-1:0]),
		      // Inputs
		      .tst_gatedclock		(tst_gatedclock),
		      .rst_n		(rst_n),
		      .clk		(clk),
		      .wdata	        (wdata[SF_DWIDTH-1:0]),
		      .sfifo_reg_wr_sel	(sfifo_reg_wr_sel[5]),
		      .cell_en		(cell_en[SF_CELL_NUM-1:0]));

// Register number 6
 sfifo_8regx1cell_reg #(SF_DWIDTH,SF_CELL_NUM) sfifo_reg_6 (/*AUTO INST*/
		      // Outputs
		      .sfifo_reg_data_r	(sfifo_reg6_data_r[SF_DWIDTH-1:0]),
		      // Inputs
		      .tst_gatedclock		(tst_gatedclock),
		      .rst_n		(rst_n),
		      .clk		(clk),
		      .wdata	        (wdata[SF_DWIDTH-1:0]),
		      .sfifo_reg_wr_sel	(sfifo_reg_wr_sel[6]),
		      .cell_en		(cell_en[SF_CELL_NUM-1:0]));

// Register number 7
 sfifo_8regx1cell_reg #(SF_DWIDTH,SF_CELL_NUM) sfifo_reg_7 (/*AUTO INST*/
		      // Outputs
		      .sfifo_reg_data_r	(sfifo_reg7_data_r[SF_DWIDTH-1:0]),
		      // Inputs
		      .tst_gatedclock		(tst_gatedclock),
		      .rst_n		(rst_n),
		      .clk		(clk),
		      .wdata	        (wdata[SF_DWIDTH-1:0]),
		      .sfifo_reg_wr_sel	(sfifo_reg_wr_sel[7]),
		      .cell_en		(cell_en[SF_CELL_NUM-1:0]));

endmodule


