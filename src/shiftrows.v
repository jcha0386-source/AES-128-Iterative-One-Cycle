module shiftrows (
    input  wire [127:0] state_in,
    output wire [127:0] state_out
);

    wire [7:0] s [0:15];
    wire [7:0] o [0:15];

    // Unpack 128-bit flat vector into a byte array in column-major sequence
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : unpack
            assign s[i] = state_in[127 - i*8 -: 8];
        end
    endgenerate

    // ---- Row 0: No Shift ----
    assign o[0]  = s[0];
    assign o[4]  = s[4];
    assign o[8]  = s[8];
    assign o[12] = s[12];

    // ---- Row 1: Shift Left by 1 Byte ----
    // (Col 0 gets Col 1, Col 1 gets Col 2, Col 2 gets Col 3, Col 3 gets Col 0)
    assign o[1]  = s[5];
    assign o[5]  = s[9];
    assign o[9]  = s[13];
    assign o[13] = s[1];

    // ---- Row 2: Shift Left by 2 Bytes ----
    // (Col 0 gets Col 2, Col 1 gets Col 3, Col 2 gets Col 0, Col 3 gets Col 1)
    assign o[2]  = s[10];
    assign o[6]  = s[14];
    assign o[10] = s[2];
    assign o[14] = s[6];

    // ---- Row 3: Shift Left by 3 Bytes ----
    // (Col 0 gets Col 3, Col 1 gets Col 0, Col 2 gets Col 1, Col 3 gets Col 2)
    assign o[3]  = s[15];
    assign o[7]  = s[3];
    assign o[11] = s[7];
    assign o[15] = s[11];

    // Pack the shifted bytes back into the 128-bit flat vector output
    generate
        for (i = 0; i < 16; i = i + 1) begin : pack
            assign state_out[127 - i*8 -: 8] = o[i];
        end
    endgenerate

endmodule