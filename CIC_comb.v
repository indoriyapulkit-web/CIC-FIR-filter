module CIC_comb#(
    parameter in_width=2    ,
    parameter N =3,
    parameter M=1,
    parameter R=2048,
    parameter width=in_width+N*$clog2(R*M)
)(
    input clk,rst,sample_en,
    input signed [width-1:0] data_in,
    output  signed [width-1:0] data_out 
    );
    integer i ;
    
    reg signed [width-1:0]data_in_pipe [0:M-1];
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            for(i=0;i<M;i=i+1) 
                  data_in_pipe[i]<=0;
        end
        else begin
            if(sample_en) begin
                data_in_pipe[0]<=data_in;
            for(i=1;i<M;i=i+1) 
                data_in_pipe[i]<=data_in_pipe[i-1];
        end
        end
    end
    assign data_out=data_in-data_in_pipe[M-1];
endmodule
