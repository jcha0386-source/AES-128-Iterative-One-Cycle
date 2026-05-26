module mixcolumns (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);

    genvar i;

    generate
        for (i = 0; i < 4; i = i + 1) begin : gen_mix
            mixcolumns_one_column u_col (
                .col_in (state_in [127 - 32*i -: 32]),
                .col_out(state_out[127 - 32*i -: 32])
            );
        end
    endgenerate

endmodule