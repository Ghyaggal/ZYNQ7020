module line_shift(
	input 			clk,
	input           de_i,
 
	input   [7:0]  data_i,    //当前行的数据
	output  [7:0]  data1_o,   //前一行的数据
	output  [7:0]  data2_o    //前前一行的数据
);
 
//reg define
reg  [2:0] de_dly;
reg  [10:0]  ram_rd_addr;
reg  [10:0]  ram_rd_addr_d0;
reg  [10:0]  ram_rd_addr_d1;
reg  [7:0]  data_i_d0;
reg  [7:0]  data_i_d1;
reg  [7:0]  data_i_d2;
reg  [7:0]  data1_o_d0;
 
//在数据到来时，RAM的读地址累加
always@(posedge clk)begin
	if(de_i)
		ram_rd_addr <= ram_rd_addr + 1 ;	
	else
		ram_rd_addr <= 0 ;
end
 
//将数据使能延迟两拍
always@(posedge clk) begin
	de_dly <= {de_dly[1:0], de_i};
end
 
//将RAM地址延迟2拍
always@(posedge clk ) begin
	ram_rd_addr_d0 <= ram_rd_addr;
	ram_rd_addr_d1 <= ram_rd_addr_d0;
end
 
//输入数据延迟3拍送入RAM
always@(posedge clk)begin
	data_i_d0 <= data_i;
	data_i_d1 <= data_i_d0;
	data_i_d2 <= data_i_d1;
end
 
//用于存储前一行图像的RAM
DRAM DRAM_inst1( 
    .clka   (clk),
    .wea    (de_dly[2]),    
    .addra  (ram_rd_addr_d1), 
    .dia    (data_i_d2),     

    .clkb   (clk),  
    .addrb  (ram_rd_addr),    
	.dob    (data1_o) 
);

//寄存前一行图像的数据
always@(posedge clk)begin
	data1_o_d0  <= data1_o;
end
 
//用于存储前前一行图像的RAM
DRAM DRAM_inst2( 
    .clka   (clk),
    .wea    (de_dly[1]),    
    .addra  (ram_rd_addr_d0), 
    .dia    (data1_o_d0),     

    .clkb   (clk),  
    .addrb  (ram_rd_addr),    
	.dob    (data2_o) 
);

endmodule