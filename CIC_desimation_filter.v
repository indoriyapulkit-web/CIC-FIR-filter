module CIC_decimation_filter #(
    parameter in_width=2,
    parameter N =3,
    parameter M=1,
    parameter R=2048,
    parameter width=in_width+N*$clog2(R*M),
    parameter input_signed=1,
    parameter count_width=(R > 1)?$clog2(R):1,
    parameter out_width=20
)(
    input clk,rst,
    input signed [in_width-1:0] data_in,
    output reg signed [out_width-1:0] data_out,    
    output reg data_valid
    );
    localparam OUT_SHIFT =(width > out_width) ? (width - out_width) : 0;
    wire signed [width-1:0] data_ext;
    wire signed [width-1:0] int_stage[0:N];
    reg signed [width-1:0] decim_in;
    wire signed [width-1:0] comb_stage [0:N];
    genvar i,j;
    
    generate 
        if (input_signed!= 0) begin:sign_ext
            assign data_ext={{(width-in_width){data_in[in_width-1]}},data_in};
        end
        else begin :zero_ext
            assign data_ext ={{(width-in_width){1'b0}},data_in};
        end
    endgenerate
    
    assign int_stage[0]=data_ext;
    generate 
        for(i=0;i<N;i=i+1) begin
            CIC_integrator#(.in_width(in_width), .N(N), .M(M), .R(R), .width(width)) c(clk, rst,int_stage[i],int_stage[i+1]);
        end
        endgenerate
        
    reg [count_width-1:0]deci_count;
    reg deci_en;
    
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            deci_en<=0;
            deci_count<=0;
        end
        else begin
            if(deci_count==R-1) begin
                deci_count<=0;
                deci_en<=1;
            end
            else begin
                deci_en<=0;
                deci_count<=deci_count+1;
            end
        end
    end
    
    always@(posedge clk or posedge rst) begin
        if(rst) 
            decim_in<=0;
        else 
            decim_in<=int_stage[N];
    end
    
    assign comb_stage[0]=decim_in;
    generate 
        for(j=0;j<N;j=j+1) begin
            CIC_comb#(.in_width(in_width), .N(N), .M(M), .R(R), .width(width)) d(clk,rst,deci_en,comb_stage[j],comb_stage[j+1]);
            end
    endgenerate
     
    always @(posedge clk or posedge rst) begin
        if (rst)
            data_valid<=0;
        else
            data_valid<=deci_en;
    end
    always @(posedge clk or posedge rst) begin
        if (rst)
            data_out<=0;
        else if (deci_en)
            data_out<=$signed(comb_stage[N])>>>OUT_SHIFT;
    end
endmodule
