module subbytes (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : gen_sbox
            sbox u_sbox (
                .a(state_in[8*i +: 8]),
                .d(state_out[8*i +: 8])
            );
        end
    endgenerate
endmodule