module key_expansion (
    input  wire [127:0] round_key_in,
    input  wire [3:0]   round_index,   
    output wire [127:0] round_key_out
);

    wire [31:0] w0, w1, w2, w3;
    
    // Split the incoming 128-bit key into 4 distinct 32-bit words
    assign w0 = round_key_in[127:96]; // Column 0
    assign w1 = round_key_in[95:64];  // Column 1
    assign w2 = round_key_in[63:32];  // Column 2
    assign w3 = round_key_in[31:0];   // Column 3

    // RotWord step: Cyclic left shift of the 4 bytes within word w3
    // If w3 = [B0, B1, B2, B3], then rotword becomes [B1, B2, B3, B0]
    wire [31:0] rotword = {w3[23:16], w3[15:8], w3[7:0], w3[31:24]};

    // SubWord step: Pass each byte of the rotated word through an S-Box instance
    wire [7:0] sb0, sb1, sb2, sb3;
    sbox u_sb0 (.a(rotword[31:24]), .d(sb0));
    sbox u_sb1 (.a(rotword[23:16]), .d(sb1));
    sbox u_sb2 (.a(rotword[15:8]),  .d(sb2));
    sbox u_sb3 (.a(rotword[7:0]),   .d(sb3));
    wire [31:0] subword = {sb0, sb1, sb2, sb3};

    // Rcon selection logic matched directly to active FSM execution indexes
    reg [31:0] rcon;
    always @(*) begin
        case (round_index)
            4'd1:    rcon = 32'h01000000; // Round 1 Rcon
            4'd2:    rcon = 32'h02000000;
            4'd3:    rcon = 32'h04000000;
            4'd4:    rcon = 32'h08000000;
            4'd5:    rcon = 32'h10000000;
            4'd6:    rcon = 32'h20000000;
            4'd7:    rcon = 32'h40000000;
            4'd8:    rcon = 32'h80000000;
            4'd9:    rcon = 32'h1b000000;
            4'd10:   rcon = 32'h36000000; // Round 10 Rcon
            default: rcon = 32'h00000000;
        endcase
    end

    // Compute the next 4 words for the new round key
    wire [31:0] new_w0 = w0 ^ subword ^ rcon;
    wire [31:0] new_w1 = w1 ^ new_w0;
    wire [31:0] new_w2 = w2 ^ new_w1;
    wire [31:0] new_w3 = w3 ^ new_w2;

    // Concatenate columns back to standard 128-bit array layout
    assign round_key_out = {new_w0, new_w1, new_w2, new_w3};

endmodule