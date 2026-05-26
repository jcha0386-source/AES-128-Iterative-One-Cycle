module mixcolumns_one_column (
    input  wire [31:0] col_in,
    output wire [31:0] col_out
);

    wire [7:0] s0, s1, s2, s3;
    wire [7:0] m0, m1, m2, m3;

    assign s0 = col_in[31:24];
    assign s1 = col_in[23:16];
    assign s2 = col_in[15:8];
    assign s3 = col_in[7:0];

    // Clean, inline wire implementation of xtime to completely avoid Quartus function bugs
    wire [7:0] xtime_s0 = (s0[7]) ? ((s0 << 1) ^ 8'h1b) : (s0 << 1);
    wire [7:0] xtime_s1 = (s1[7]) ? ((s1 << 1) ^ 8'h1b) : (s1 << 1);
    wire [7:0] xtime_s2 = (s2[7]) ? ((s2 << 1) ^ 8'h1b) : (s2 << 1);
    wire [7:0] xtime_s3 = (s3[7]) ? ((s3 << 1) ^ 8'h1b) : (s3 << 1);

    // Matrix multiplication logic
    assign m0 = xtime_s0 ^ (xtime_s1 ^ s1) ^ s2 ^ s3;
    assign m1 = s0 ^ xtime_s1 ^ (xtime_s2 ^ s2) ^ s3;
    assign m2 = s0 ^ s1 ^ xtime_s2 ^ (xtime_s3 ^ s3);
    assign m3 = (xtime_s0 ^ s0) ^ s1 ^ s2 ^ xtime_s3;

    assign col_out = {m0, m1, m2, m3};

endmodule