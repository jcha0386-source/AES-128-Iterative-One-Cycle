// aes_top.v
// Iterative AES-128 encryption core (one round per clock cycle)
// Interface: start/busy/done, plaintext/key inputs, ciphertext output
module aes_top (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [127:0] plaintext,
    input  wire [127:0] key,
    output reg         busy,
    output reg         done,
    output reg  [127:0] ciphertext
);

    reg [3:0] round;          // current round 
    reg [127:0] state;        // internal state 
    reg [127:0] round_key;    // current round key

    // Internal signals for AES round functions
    wire [127:0] sub_out;     // after SubBytes
    wire [127:0] shift_out;   // after ShiftRows
    wire [127:0] mix_out;     // after MixColumns (for full rounds)
    wire [127:0] next_key;    // next round key from key expansion

    // Instantiate the sub-modules
    subbytes u_subbytes (
        .state_in(state),
        .state_out(sub_out)
    );

    shiftrows u_shiftrows (
        .state_in(sub_out),
        .state_out(shift_out)
    );

    mixcolumns u_mixcolumns (
        .state_in(shift_out),
        .state_out(mix_out)
    );

    key_expansion u_key_expansion (
        .round_key_in(round_key),
        .round_index(round),      // round
        .round_key_out(next_key)
    );
	 
    // FSM Datapath
    // Corrected sequential state execution pipeline
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            busy       <= 1'b0;
            done       <= 1'b0;
            round      <= 4'd0;
            state      <= 128'd0;
            round_key  <= 128'd0;
            ciphertext <= 128'd0;
        end else begin
            done <= 1'b0; // Default flag status

            if (!busy && start) begin
                // Capture inputs and apply initial AddRoundKey (Round 0)
                busy      <= 1'b1;
                round     <= 4'd1;
                state     <= plaintext ^ key;
                round_key <= key; 
            end else if (busy) begin
                case (round)
                    4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd6, 4'd7, 4'd8, 4'd9: begin
                        // Use next_key immediately to perform AddRoundKey for this round
                        state     <= mix_out ^ next_key;
                        // Save it so it becomes the stable base for the NEXT round's calculations
                        round_key <= next_key;
                        round     <= round + 4'd1;
                    end

                    4'd10: begin
                        // Final round skips MixColumns step
                        ciphertext <= shift_out ^ next_key;
                        busy       <= 1'b0;
                        done       <= 1'b1;
                        round      <= 4'd0;
                    end

                    default: begin
                        busy  <= 1'b0;
                        round <= 4'd0;
                    end
                endcase
            end
        end
    end
endmodule