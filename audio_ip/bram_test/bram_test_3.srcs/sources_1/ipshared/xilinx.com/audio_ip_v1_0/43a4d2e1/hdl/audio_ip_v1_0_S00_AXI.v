
`timescale 1 ns / 1 ps

	module audio_ip_v1_0_S00_AXI #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line

		// Width of S_AXI data bus
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		// Width of S_AXI address bus
		parameter integer C_S_AXI_ADDR_WIDTH	= 5
	)
	(
		// Users to add ports here
        output AUD_PWM,
        output aud_vcc,
		// User ports ends
		// Do not modify the ports beyond this line

		// Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Write channel Protection type. This signal indicates the
    		// privilege and security level of the transaction, and whether
    		// the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Write address valid. This signal indicates that the master signaling
    		// valid write address and control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that the slave is ready
    		// to accept an address and associated control signals.
		output wire  S_AXI_AWREADY,
		// Write data (issued by master, acceped by Slave) 
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte lanes hold
    		// valid data. There is one write strobe bit for each eight
    		// bits of the write data bus.    
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write valid. This signal indicates that valid write
    		// data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    		// can accept the write data.
		output wire  S_AXI_WREADY,
		// Write response. This signal indicates the status
    		// of the write transaction.
		output wire [1 : 0] S_AXI_BRESP,
		// Write response valid. This signal indicates that the channel
    		// is signaling a valid write response.
		output wire  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    		// can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address (issued by master, acceped by Slave)
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Protection type. This signal indicates the privilege
    		// and security level of the transaction, and whether the
    		// transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Read address valid. This signal indicates that the channel
    		// is signaling valid read address and control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that the slave is
    		// ready to accept an address and associated control signals.
		output wire  S_AXI_ARREADY,
		// Read data (issued by slave)
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of the
    		// read transfer.
		output wire [1 : 0] S_AXI_RRESP,
		// Read valid. This signal indicates that the channel is
    		// signaling the required read data.
		output wire  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    		// accept the read data and response information.
		input wire  S_AXI_RREADY
	);
    //user registers and variables
    reg [7:0] input_to_PWM;
    //reg [11:0] pwm_input_update_count = 12'b100011011011; //each pwm load is valid for 2267 cycles
    reg [11:0] pwm_input_current_count= 12'b000000000000;
    reg [11:0] update_count_reg;
    always@(*)begin
        update_count_reg=update_count[11:0];
    end
    //reg new_data=1'b0;
    //reg start_new_data=1'b0;
    
    reg got_new_data=1'b0;
    reg [1:0] stage;
    
    //reg [31:0] address_counted;
    reg vcc=1'b1;
    //reg [11:0]wait_count;
    //reg wait_1;
    //reg loaded=1'b0;
    
    initial begin
       stage=2'b00;
    end
    
    
    
    
	// AXI4LITE signals
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awready;
	reg  	axi_wready;
	reg [1 : 0] 	axi_bresp;
	reg  	axi_bvalid;
	reg [C_S_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arready;
	reg [C_S_AXI_DATA_WIDTH-1 : 0] 	axi_rdata;
	reg [1 : 0] 	axi_rresp;
	reg  	axi_rvalid;

	// Example-specific design signals
	// local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	// ADDR_LSB is used for addressing 32/64 bit registers/memories
	// ADDR_LSB = 2 for 32 bits (n downto 2)
	// ADDR_LSB = 3 for 64 bits (n downto 3)
	localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
	localparam integer OPT_MEM_ADDR_BITS = 2;
	//----------------------------------------------
	//-- Signals for user logic register space example
	//------------------------------------------------
	//-- Number of Slave Registers 5
	reg [C_S_AXI_DATA_WIDTH-1:0]	update_count;//first_address
	reg [C_S_AXI_DATA_WIDTH-1:0]	current_address;//current_address
	reg [C_S_AXI_DATA_WIDTH-1:0]	data_to_pwm;
	reg [C_S_AXI_DATA_WIDTH-1:0]	address_count;
	reg [C_S_AXI_DATA_WIDTH-1:0]	get_new_data;//signal master to send new data to data_to_pwm
	wire	 slv_reg_rden;
	wire	 slv_reg_wren;
	reg [C_S_AXI_DATA_WIDTH-1:0]	 reg_data_out;
	integer	 byte_index;

	// I/O Connections assignments

	assign S_AXI_AWREADY	= axi_awready;
	assign S_AXI_WREADY	= axi_wready;
	assign S_AXI_BRESP	= axi_bresp;
	assign S_AXI_BVALID	= axi_bvalid;
	assign S_AXI_ARREADY	= axi_arready;
	assign S_AXI_RDATA	= axi_rdata;
	assign S_AXI_RRESP	= axi_rresp;
	assign S_AXI_RVALID	= axi_rvalid;
	// Implement axi_awready generation
	// axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	// de-asserted when reset is low.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	        begin
	          // slave is ready to accept write address when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_awready <= 1'b1;
	        end
	      else           
	        begin
	          axi_awready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_awaddr latching
	// This process is used to latch the address when both 
	// S_AXI_AWVALID and S_AXI_WVALID are valid. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_awaddr <= 0;
	    end 
	  else
	    begin    
	      if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID)
	        begin
	          // Write Address latching 
	          axi_awaddr <= S_AXI_AWADDR;
	        end
	    end 
	end       

	// Implement axi_wready generation
	// axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	// S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	// de-asserted when reset is low. 

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_wready <= 1'b0;
	    end 
	  else
	    begin    
	      if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID)
	        begin
	          // slave is ready to accept write data when 
	          // there is a valid write address and write data
	          // on the write address and data bus. This design 
	          // expects no outstanding transactions. 
	          axi_wready <= 1'b1;
	        end
	      else
	        begin
	          axi_wready <= 1'b0;
	        end
	    end 
	end       

	// Implement memory mapped register select and write logic generation
	// The write data is accepted and written to memory mapped registers when
	// axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	// select byte enables of slave registers while writing.
	// These registers are cleared when reset (active low) is applied.
	// Slave register write enable is asserted when valid address and data are available
	// and the slave is ready to accept the write address and write data.
	assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      update_count<= 0;
	      current_address <= 0;
	      data_to_pwm <= 0;
	      address_count <= 0;
	      get_new_data <= 0;
	    end 
	  else begin
	    if (slv_reg_wren)
	      begin
	        case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	          3'h0:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 0
	                update_count[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          3'h1:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 1
	                current_address[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          3'h2:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 2
	                data_to_pwm[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	                got_new_data<=1;
	                
	              end  
	          3'h3:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 3
	                address_count[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	              end  
	          3'h4:
	            for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
	              if ( S_AXI_WSTRB[byte_index] == 1 ) begin
	                // Respective byte enables are asserted as per write strobes 
	                // Slave register 4
	                get_new_data[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
	                //got_new_data<=1;
	              end  
	          default : begin
	                      update_count <= update_count;
	                      current_address <= current_address;
	                      data_to_pwm <= data_to_pwm;
	                      address_count <= address_count;
	                      get_new_data <= get_new_data;
	                    end
	        endcase
	      end
	      else begin
	       //logic to read, update and do stuff
	           if(got_new_data==1)begin
	               // exert get_new_data only after all 4 bytes have been sent to the pwm
	               //decide which 8 bits to send
	               //current decision, 32bit reversed endian
	               
	               if(stage==2'b00)begin
	                   input_to_PWM<=data_to_pwm[31:24];                         
	                   get_new_data<=0;
	                   if(pwm_input_current_count<update_count_reg)begin
	                       pwm_input_current_count<=pwm_input_current_count+1;
	                        /*
	                        if(start_new_data==0)begin
	                            input_to_PWM<=data_to_pwm[31:24];
                                new_data<=1;
                                start_new_data<=1;
                            end
                            else begin
                                new_data<=0;
                            end
                            */
	                   end
	                   else begin
	                       stage<=2'b01;
	                       pwm_input_current_count<=0;
	                       //start_new_data<=0;
	                   end
	               end
	               
	               if(stage==2'b01)begin
	                   input_to_PWM<=data_to_pwm[23:16];
	                   get_new_data<=0;
	                   if(pwm_input_current_count<update_count_reg)begin
	                       pwm_input_current_count<=pwm_input_current_count+1;
	                       /*
	                       if(start_new_data==0)begin
	                            input_to_PWM<=data_to_pwm[23:16];
                                new_data<=1;
                                start_new_data<=1;
                           end
                           else begin
                                new_data<=0;
                           end
                           */
	                   end
	                   else begin
	                       stage<=2'b10;
	                       pwm_input_current_count<=0;
	                       //start_new_data<=0;
	                   end
	               end
	               
	               if(stage==2'b10)begin
	                   input_to_PWM<=data_to_pwm[15:8];
	                   get_new_data<=0;
	                   //change
	                   //got_new_data<=0;
	                   if(pwm_input_current_count<update_count_reg)begin
	                       pwm_input_current_count<=pwm_input_current_count+1;
	                       /*
	                       if(start_new_data==0)begin
	                            input_to_PWM<=data_to_pwm[15:8];
                                new_data<=1;
                                start_new_data<=1;
                           end
                           else begin
                                new_data<=0;
                           end
                           */
	                   end
	                   else begin
	                       stage<=2'b11;
	                       pwm_input_current_count<=0;
	                       //start_new_data<=0;
	                   end
	               end
	               
	               if(stage==2'b11)begin
	                   input_to_PWM<=data_to_pwm[7:0];
	                   get_new_data<=1;
	                   //got_new_data<=0;
	                   if(pwm_input_current_count<update_count_reg)begin
	                       pwm_input_current_count<=pwm_input_current_count+1;
	                       /*
	                       if(start_new_data==0)begin
	                            input_to_PWM<=data_to_pwm[7:0];
                                new_data<=1;
                                start_new_data<=1;
                           end
                           else begin
                                new_data<=0;
                           end
                           */
	                   end
	                   else begin
	                       stage<=2'b00;
	                       got_new_data<=0;
	                       //start_new_data<=0;
	                       pwm_input_current_count<=0;
	                   end
	               end
	           end
	      end
	  end
	end    

	// Implement write response logic generation
	// The write response and response valid signals are asserted by the slave 
	// when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	// This marks the acceptance of address and indicates the status of 
	// write transaction.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_bvalid  <= 0;
	      axi_bresp   <= 2'b0;
	    end 
	  else
	    begin    
	      if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
	        begin
	          // indicates a valid write response is available
	          axi_bvalid <= 1'b1;
	          axi_bresp  <= 2'b0; // 'OKAY' response 
	        end                   // work error responses in future
	      else
	        begin
	          if (S_AXI_BREADY && axi_bvalid) 
	            //check if bready is asserted while bvalid is high) 
	            //(there is a possibility that bready is always asserted high)   
	            begin
	              axi_bvalid <= 1'b0; 
	            end  
	        end
	    end
	end   

	// Implement axi_arready generation
	// axi_arready is asserted for one S_AXI_ACLK clock cycle when
	// S_AXI_ARVALID is asserted. axi_awready is 
	// de-asserted when reset (active low) is asserted. 
	// The read address is also latched when S_AXI_ARVALID is 
	// asserted. axi_araddr is reset to zero on reset assertion.

	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_arready <= 1'b0;
	      axi_araddr  <= 32'b0;
	    end 
	  else
	    begin    
	      if (~axi_arready && S_AXI_ARVALID)
	        begin
	          // indicates that the slave has acceped the valid read address
	          axi_arready <= 1'b1;
	          // Read address latching
	          axi_araddr  <= S_AXI_ARADDR;
	        end
	      else
	        begin
	          axi_arready <= 1'b0;
	        end
	    end 
	end       

	// Implement axi_arvalid generation
	// axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	// S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	// data are available on the axi_rdata bus at this instance. The 
	// assertion of axi_rvalid marks the validity of read data on the 
	// bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	// is deasserted on reset (active low). axi_rresp and axi_rdata are 
	// cleared to zero on reset (active low).  
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rvalid <= 0;
	      axi_rresp  <= 0;
	    end 
	  else
	    begin    
	      if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
	        begin
	          // Valid read data is available at the read data bus
	          axi_rvalid <= 1'b1;
	          axi_rresp  <= 2'b0; // 'OKAY' response
	        end   
	      else if (axi_rvalid && S_AXI_RREADY)
	        begin
	          // Read data is accepted by the master
	          axi_rvalid <= 1'b0;
	        end                
	    end
	end    

	// Implement memory mapped register select and read logic generation
	// Slave register read enable is asserted when valid address is available
	// and the slave is ready to accept the read address.
	assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
	always @(*)
	begin
	      // Address decoding for reading registers
	      case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
	        3'h0   : reg_data_out <= update_count;
	        3'h1   : reg_data_out <= current_address;
	        3'h2   : reg_data_out <= data_to_pwm;
	        3'h3   : reg_data_out <= address_count;
	        3'h4   : reg_data_out <= get_new_data;
	        default : reg_data_out <= 0;
	      endcase
	end

	// Output register or memory read data
	always @( posedge S_AXI_ACLK )
	begin
	  if ( S_AXI_ARESETN == 1'b0 )
	    begin
	      axi_rdata  <= 0;
	    end 
	  else
	    begin    
	      // When there is a valid read address (S_AXI_ARVALID) with 
	      // acceptance of read address by the slave (axi_arready), 
	      // output the read dada 
	      if (slv_reg_rden)
	        begin
	          axi_rdata <= reg_data_out;     // register read data
	        end   
	    end
	end    
    
    
    
    //user logic - pwm
    
	// Add user logic here
      pwm_module pwm(
          .clk(S_AXI_ACLK),
          .PWM_in(input_to_PWM),
          .PWM_out(AUD_PWM),
          .max_ramp(update_count_reg)
          
          //.new_data_to_pwm(new_data)
      );
	// User logic ends
	//always@(posedge S_AXI_ACLK)begin
	   
	//   PWM[10:0]<=data_to_pwm[10:0];
	   
	//end
	
  
    assign aud_vcc=1'b1;
	endmodule
