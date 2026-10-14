module CIC_integrator#(
    parameter in_width=2,
    parameter N =3,
    parameter M=1,
    parameter R=2048,
    parameter width=in_width+N*$clog2(R*M)
)(
    input clk,rst ,
    input signed [width-1:0] data_in,
    output reg signed [width-1:0] data_out
    );
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            data_out<=0;          
        end
        else begin
            data_out<=data_out+data_in;
        end
    end
endmodule
