`timescale 1ns / 1ps
module tb_aes_top();
    reg clk, rst_n, start;
    reg [127:0] plaintext, key;
    wire busy, done;
    wire [127:0] ciphertext;

    // Instantiate Unit Under Test
    aes_top uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .plaintext(plaintext),
        .key(key),
        .busy(busy),
        .done(done),
        .ciphertext(ciphertext)
    );

    // Clock generator (100MHz)
    always #5 clk = ~clk;

    integer i, pass, fail;
    reg [127:0] expected;
    reg [127:0] test_vectors [0:17];

    // Main Test Vector Loop
    initial begin
        // NIST FIPS-197 vectors (plaintext, key, ciphertext)
        test_vectors[0]  = 128'h00112233445566778899aabbccddeeff;
        test_vectors[1]  = 128'h000102030405060708090a0b0c0d0e0f;
        test_vectors[2]  = 128'h69c4e0d86a7b0430d8cdb78070b4c55a;

        test_vectors[3]  = 128'h00000000000000000000000000000000;
        test_vectors[4]  = 128'h00000000000000000000000000000000;
        test_vectors[5]  = 128'h66e94bd4ef8a2c3b884cfa59ca342b2e;

        test_vectors[6]  = 128'hffffffffffffffffffffffffffffffff;
        test_vectors[7]  = 128'hffffffffffffffffffffffffffffffff;
        test_vectors[8]  = 128'hbcbf217cb280cf30b2517052193ab979;

        test_vectors[9]  = 128'hffffffffffffffffffffffffffffffff;
        test_vectors[10] = 128'h00000000000000000000000000000000;
        test_vectors[11] = 128'h3f5b8cc9ea855a0afa7347d23e8d664e;

        test_vectors[12] = 128'h00000000000000000000000000000000;
        test_vectors[13] = 128'h01010101010101010101010101010101;
        test_vectors[14] = 128'hb6aeaffa752dc08b51639731761aed00;

        test_vectors[15] = 128'h00112233445566778899aabbccddeeff;
        test_vectors[16] = 128'h000102030405060708090a0b0c0d0e0f;
        test_vectors[17] = 128'h69c4e0d86a7b0430d8cdb78070b4c55a;  // repeat

        // System Initialization
        clk = 0; 
        rst_n = 0; 
        start = 0;
        pass = 0; 
        fail = 0;
        
        #15 rst_n = 1; // Release reset
        #10;

        for (i = 0; i < 6; i = i + 1) begin
            // Wait for core to be completely idle before driving data
            while (busy) @(posedge clk);
            #1; // Step slightly off the clock edge to prevent race behavior

            plaintext = test_vectors[3*i];
            key       = test_vectors[3*i + 1];
            expected  = test_vectors[3*i + 2];

            @(posedge clk); start = 1;
            @(posedge clk); start = 0;
            @(posedge done);
            @(posedge clk); // Allow cleanup clock cycle

            if (ciphertext === expected) begin
                $display("Test %0d: PASS", i+1);
					 $display("  plaintext = %032h", plaintext);
                $display("  key       = %032h", key);
                $display("  expected  = %032h", expected);
                $display("  got       = %032h", ciphertext);
                pass = pass + 1;
            end else begin
                $display("Test %0d: FAIL", i+1);
                $display("  plaintext = %032h", plaintext);
                $display("  key       = %032h", key);
                $display("  expected  = %032h", expected);
                $display("  got       = %032h", ciphertext);
                fail = fail + 1;
            end
        end

        $display("Passed: %0d, Failed: %0d", pass, fail);
        // $finish;
    end

    // Waveform Generation Block
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_aes_top);
    end

endmodule
