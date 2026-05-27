`default_nettype none
/* verilator lint_off UNUSED */

module tt_um_aes_128_wrapper (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered or selected
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - active low
);

    // --- DECLARED AT THE TOP TO FIX MODELSIM COMPILE ERRORS ---
    wire core_busy;
    wire core_done;
    wire [127:0] core_ciphertext;

    // Control Pin Mapping via bidirectional IOs
    assign uio_oe = 8'b00000011; // uio_out[0] and uio_out[1] are outputs
    assign uio_out[0] = core_busy;
    assign uio_out[1] = core_done;
    assign uio_out[7:2] = 6'b000000;

    wire start_pulse = uio_in[2]; 
    wire load_ptext  = uio_in[3]; 
    wire load_key    = uio_in[4]; 
    wire [3:0] byte_idx = uio_in[7:4]; 

    // Shift/Storage Registers for 128-bit interfaces
    reg [127:0] r_plaintext;
    reg [127:0] r_key;

    // Your exact original, clean linear byte-loading assignment
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_plaintext <= 128'd0;
            r_key       <= 128'd0;
        end else begin
            if (load_ptext) begin
                r_plaintext[127 - (byte_idx * 8) -: 8] <= ui_in;
            end
            if (load_key) begin
                r_key[127 - (byte_idx * 8) -: 8] <= ui_in;
            end
        end
    end

    // Your exact original output streaming assignment
    assign uo_out = core_ciphertext[127 - (byte_idx * 8) -: 8];

    // Instantiate the AES-128 core
    aes_top u_aes_core (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_pulse),
        .plaintext(r_plaintext),
        .key(r_key),
        .busy(core_busy),
        .done(core_done),
        .ciphertext(core_ciphertext)
    );

endmodule
