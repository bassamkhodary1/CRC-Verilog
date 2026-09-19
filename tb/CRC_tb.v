`timescale 1ns / 1ps

module CRC_tb;

    // =========================================================
    // Testbench Signals
    // =========================================================
    reg  Data;
    reg  Active;
    reg  Clk;
    reg  Rst;

    wire Crc;
    wire Valid;

    // =========================================================
    // File Handles
    // =========================================================
    integer input_file;
    integer expected_file;

    integer input_status;
    integer expected_status;

    // =========================================================
    // Test Variables
    // =========================================================
    reg [7:0] data_byte;
    reg [7:0] expected_crc;
    reg [7:0] actual_crc;

    integer bit_index;
    integer frame_count;
    integer pass_count;
    integer fail_count;
    integer test_enable;

    // =========================================================
    // DUT
    // =========================================================
    CRC DUT (
        .Data   (Data),
        .Active (Active),
        .Clk    (Clk),
        .Rst    (Rst),
        .Crc    (Crc),
        .Valid  (Valid)
    );

    // =========================================================
    // Clock Generation
    // 10 ns Period
    // =========================================================
    initial begin
        Clk = 1'b0;

        forever #5 Clk = ~Clk;
    end

    // =========================================================
    // Main Test
    // =========================================================
    initial begin

        // -----------------------------------------------------
        // Initial Values
        // -----------------------------------------------------
        Data        = 1'b0;
        Active      = 1'b0;
        Rst         = 1'b0;

        frame_count = 0;
        pass_count  = 0;
        fail_count  = 0;
        test_enable = 1;

        // -----------------------------------------------------
        // Open DATA File
        // -----------------------------------------------------
        input_file = $fopen("sim/DATA_h.txt", "r");

        if (input_file == 0) begin
            $display("ERROR: Cannot open DATA_h.txt");
            $finish;
        end

        // -----------------------------------------------------
        // Open Expected CRC File
        // -----------------------------------------------------
        expected_file = $fopen("sim/Expec_Out_h.txt", "r");

        if (expected_file == 0) begin
            $display("ERROR: Cannot open Expec_Out_h.txt");

            $fclose(input_file);

            $finish;
        end

        // =====================================================
        // Header
        // =====================================================

        $display("");
        $display("==============================================");
        $display("              CRC TESTBENCH START");
        $display("==============================================");
        $display("");

        // =====================================================
        // RESET
        // =====================================================

        $display("Applying Reset...");

        Rst    = 1'b0;
        Active = 1'b0;
        Data   = 1'b0;

        // Hold reset for a few nanoseconds
        #10;

        // Release reset
        Rst = 1'b1;

        // -----------------------------------------------------
        // IMPORTANT:
        // Wait for a complete clock cycle after reset release.
        // This gives the DUT registers a clean starting point.
        // -----------------------------------------------------

        @(posedge Clk);
        #1;

        $display("Reset Released.");
        $display("DUT initialized.");
        $display("----------------------------------------------");

        // =====================================================
        // TEST FRAMES
        // =====================================================

        while (test_enable) begin

            // -------------------------------------------------
            // Read Input Byte
            // -------------------------------------------------

            input_status = $fscanf(
                input_file,
                "%h",
                data_byte
            );

            if (input_status != 1) begin

                test_enable = 0;

            end

            else begin

                // -------------------------------------------------
                // Read Expected CRC
                // -------------------------------------------------

                expected_status = $fscanf(
                    expected_file,
                    "%h",
                    expected_crc
                );

                if (expected_status != 1) begin

                    $display("");
                    $display(
                        "ERROR: Missing expected CRC for frame %0d",
                        frame_count + 1
                    );

                    fail_count  = fail_count + 1;
                    test_enable = 0;

                end

                else begin

                    // =============================================
                    // FRAME START
                    // =============================================

                    frame_count = frame_count + 1;

                    $display("");
                    $display("==============================================");
                    $display("FRAME %0d", frame_count);
                    $display("==============================================");

                    $display(
                        "Input    = %02h",
                        data_byte
                    );

                    $display(
                        "Expected = %02h",
                        expected_crc
                    );

                    $display("----------------------------------------------");

                    // =============================================
                    // INPUT PHASE
                    // LSB FIRST
                    // =============================================

                    Active = 1'b1;

                    for (
                        bit_index = 0;
                        bit_index < 8;
                        bit_index = bit_index + 1
                    ) begin

                        // ------------------------------------------------
                        // Put DATA on the line before rising edge
                        // ------------------------------------------------

                        @(negedge Clk);

                        Data = data_byte[bit_index];

                        // ------------------------------------------------
                        // DUT samples DATA at rising edge
                        // ------------------------------------------------

                        @(posedge Clk);

                        #1;

                        $display(
                            "DATA  Bit[%0d] = %b",
                            bit_index,
                            Data
                        );

                    end

                    // =============================================
                    // END INPUT PHASE
                    // =============================================

                    // Change Active away from the sampling edge
                    @(negedge Clk);

                    Active = 1'b0;
                    Data   = 1'b0;

                    $display("----------------------------------------------");
                    $display("Input phase finished.");
                    $display("CRC output phase started.");
                    $display("----------------------------------------------");

                    // =============================================
                    // OUTPUT PHASE
                    // LSB FIRST
                    // =============================================

                    actual_crc = 8'b0;

                    for (
                        bit_index = 0;
                        bit_index < 8;
                        bit_index = bit_index + 1
                    ) begin

                        // ------------------------------------------------
                        // Crc is registered.
                        //
                        // Therefore wait for rising edge first,
                        // then sample Crc.
                        // ------------------------------------------------

                        @(posedge Clk);

                        #1;

                        // ------------------------------------------------
                        // Check Valid
                        // ------------------------------------------------

                        if (!Valid) begin

                            $display(
                                "WARNING: Valid LOW at CRC Bit[%0d]",
                                bit_index
                            );

                        end

                        // ------------------------------------------------
                        // Store CRC bit
                        // LSB first
                        // ------------------------------------------------

                        actual_crc[bit_index] = Crc;

                        $display(
                            "CRC   Bit[%0d] = %b    Valid = %b",
                            bit_index,
                            Crc,
                            Valid
                        );

                    end

                    // =============================================
                    // COMPARE RESULT
                    // =============================================

                    $display("----------------------------------------------");

                    $display(
                        "Actual   = %02h",
                        actual_crc
                    );

                    $display(
                        "Expected = %02h",
                        expected_crc
                    );

                    if (actual_crc === expected_crc) begin

                        pass_count = pass_count + 1;

                        $display("RESULT   = PASS");

                    end

                    else begin

                        fail_count = fail_count + 1;

                        $display("RESULT   = FAIL");

                    end

                    $display("==============================================");

                    // =============================================
                    // WAIT FOR DUT TO RETURN TO SEED
                    // =============================================

                    @(posedge Clk);
                    #1;

                end
            end

        end

        // =====================================================
        // CLOSE FILES
        // =====================================================

        $fclose(input_file);
        $fclose(expected_file);

        // =====================================================
        // FINAL REPORT
        // =====================================================

        $display("");
        $display("");
        $display("==============================================");
        $display("                 TEST COMPLETE");
        $display("==============================================");

        $display(
            "Total Frames = %0d",
            frame_count
        );

        $display(
            "PASS         = %0d",
            pass_count
        );

        $display(
            "FAIL         = %0d",
            fail_count
        );

        $display("----------------------------------------------");

        if (fail_count == 0)
            $display("FINAL RESULT = *** PASS ***");
        else
            $display("FINAL RESULT = *** FAIL ***");

        $display("==============================================");
        $display("");

        $finish;

    end

endmodule