`include "timescale.v"
// synopsys translate_on


module interrupt_controller(irq,rst_n,clk,if_pc,mem_pc,intctl_epc,intctl_status,intctl_cause,iack,id2intctl_status);			
			input [5:0]	irq;
			input 	rst_n;
			input 	clk;
			input 	if_pc; // The PC of IF Stage
			input	mem_pc;// The PC of MEM Stage
			input	[31:0] id2intctl_status; // Read the value from CP0 Registers-Status (cpr12)
			
			output 	[31:0] intctl_epc; // Update value to CP0 Registers-EPC (cpr14)
			output 	[31:0] intctl_cause; // Update CP0 Registers-Cause (cpr13) 
			output 	[31:0] intctl_status; // Update CP0 Registers-Cause (cpr12)
			output  iack; // Reference to LAB5 slide p.15
			
			reg   	[31:0]	intctl_epc;
			reg   	[31:0]	intctl_cause;
			reg		  [31:0]	intctl_status;

			wire    [31:0]	if_pc;
			wire    [31:0]	mem_pc;
			reg				iack;
			
		
		always@(negedge clk or negedge rst_n)
        begin	
			if(~rst_n)
					begin //Initialize to zero
					iack <= 1'b0;
					intctl_epc <= 32'b0;
					intctl_status <= 32'b0;
					intctl_cause <= 32'b0;
					end
			else if((irq & id2intctl_status[15:10])& id2intctl_status[0]) //check that IRQ occur and corresponded cpr12 (cp0-register status) is enable
					begin
					intctl_epc <= if_pc;			//save PC (if_pc or mem_pc ? think about it)
					intctl_status<=	id2intctl_status & 32'hFFFFFFFE; //disable interrupt
					intctl_cause[15:10] <= irq & id2intctl_status[15:10]; //record the reason for the exception in the Cause register.
					iack <=	1'b1;					//Ack to interrupt
					end
			else   
					begin
						if(if_pc == 32'h00001000) //Program is "already into" ISR.
							begin
								iack <= 1'b0;
							end
						else  intctl_epc <= intctl_epc;
					end
		end
endmodule