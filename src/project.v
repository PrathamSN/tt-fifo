/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

module FIFO_SYNCHRONOUS#(parameter DATAWIDTH = 8, DEPTH = 8, PTRSIZE = 3, ALMOST_FULL = 6, ALMOST_EMPTY = 2 )(input clock_i, reset_i, flush_i, write_en_i, read_en_i, input [DATAWIDTH-1:0]datain_i, 
                                                                             output full_o, empty_o, output reg almost_full_o, almost_empty_o, output reg [PTRSIZE:0]peak_mark_o, output [DATAWIDTH-1:0]dataout_o);  

reg [DATAWIDTH-1:0]memory[0:DEPTH-1];
reg [PTRSIZE-1:0]write_ptr = 0;
reg [PTRSIZE-1:0]read_ptr = 0; 
reg [PTRSIZE:0]count; 
wire write_interim = (write_en_i && !full_o);

reg [DATAWIDTH-1:0]dataout_buffer;
reg valid_flag;
wire empty_interim;
wire internal_read;
assign internal_read = (!empty_interim) && (!valid_flag || read_en_i);


always @(posedge clock_i) 
begin
if (reset_i || flush_i)
begin
write_ptr <= 1'b0;
end
else   
begin
if(write_interim)  begin
memory[write_ptr]<= datain_i;      
write_ptr <= write_ptr+1'b1;
end
end
end

always@(posedge clock_i) begin
if(reset_i || flush_i) begin
read_ptr <= 1'b0;
valid_flag <= 1'b0;
dataout_buffer <= 0; 
end
else if(internal_read) 
begin
dataout_buffer <= memory[read_ptr];
read_ptr <= read_ptr+1'b1;
valid_flag <= 1'b1;
end
else 
begin
if(read_en_i && !empty_o)
valid_flag <= 1'b0;
end
end



always@(posedge clock_i) begin
if(reset_i || flush_i) begin
count <= 0;
end
else
begin
case ({write_interim, internal_read})
2'b01 : count <= count - 1'b1;
2'b10 : count <= count + 1'b1;
default : count <= count;
endcase
end
end




always @(posedge clock_i)
begin
if(reset_i || flush_i)
begin
almost_full_o <= 1'b0;
almost_empty_o <= 1'b1;
end
else
begin
if (count >= ALMOST_FULL)
almost_full_o <= 1'b1;
else 
almost_full_o <= 1'b0;

if(count<= ALMOST_EMPTY)
almost_empty_o <= 1'b1;
else 
almost_empty_o <= 1'b0;
end
end

always @(posedge clock_i)
begin
if (reset_i || flush_i)
peak_mark_o <= 0;
else if(count > peak_mark_o)
peak_mark_o <= count;
else begin
if (count <= peak_mark_o)
peak_mark_o <= peak_mark_o;
end
end

assign full_o = (write_ptr + 1'b1 == read_ptr) ? 1'b1 : 1'b0;
assign empty_interim = (read_ptr == write_ptr) ? 1'b1 : 1'b0;
assign empty_o = !valid_flag;
assign dataout_o = dataout_buffer;


endmodule
