module FIR#(
    parameter in_width=20,
    parameter out_width=20,
    parameter taps=65,
    parameter coeff_width=18,
    parameter frac_width= 14,
    parameter acc_width=in_width+coeff_width+ $clog2(taps),
    parameter coeff_file="fir_coeffs_q144.hex",
    parameter prod_width=in_width+coeff_width
    )(
    input clk,rst,
    input signed [in_width-1:0] data_in,
    input valid_data_in,
    output reg signed [out_width-1:0] data_out,
    output reg data_valid_out
    );
    integer i,j;
    reg signed [coeff_width-1:0] coeff[0:taps-1];
    reg signed [in_width-1:0] delay_line [0:taps-2];
    reg signed [prod_width-1:0] prod_data[0:taps-1] ;
    wire signed [acc_width-1:0] acc_scaled;
     reg signed [acc_width-1:0] acc_comb;
     
    initial begin
        $readmemh(coeff_file, coeff);
    end
    always@(*) begin
        for (j=0; j<taps;j=j +1) begin
            if (j==0)
                prod_data[j]=$signed(data_in)*$signed(coeff[j]);
            else
                prod_data[j] =$signed(delay_line[j-1])*$signed(coeff[j]);
        end      
       acc_comb =0;
        for (j=0; j<taps;j=j+1) begin
            acc_comb=acc_comb+{{(acc_width-prod_width){prod_data[j][prod_width-1]}},prod_data[j]};
        end
    end 
    assign acc_scaled =acc_comb>>>frac_width;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_out<= 0;
            data_valid_out<=0;
             for(i=0;i<taps-1;i=i+1) 
                delay_line[i]<=0;
        end
        else begin
            data_valid_out<=valid_data_in;
            if (valid_data_in) begin
                data_out <=acc_scaled[out_width-1:0];
                for (i=taps-2;i>0;i=i-1)
                    delay_line[i]<=delay_line[i-1];
                delay_line[0]<=data_in;
            end
        end
    end
endmodule

