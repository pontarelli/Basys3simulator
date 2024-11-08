// DESCRIPTION: Verilator generated Verilog
// Wrapper module for DPI protected library
// This module requires libsecret_top.a or libsecret_top.so to work
// See instructions in your simulator for how to use DPI libraries

module secret_top (
        input logic clk
        , input logic reset
        , input logic KEYSIG_DATA
        , input logic KEYSIG_CLK
        , input logic up
        , input logic down
        , input logic left
        , input logic right
        , output logic [3:0]  an
        , output logic [7:0]  seg
        , output logic h_sync
        , output logic v_sync
        , output logic [3:0]  R_VAL
        , output logic [3:0]  G_VAL
        , output logic [3:0]  B_VAL
        , input logic [15:0]  sw
        , output logic [15:0]  LED
    );
    
    // Precision of submodule (commented out to avoid requiring timescale on all modules)
    // timeunit 1ns;
    // timeprecision 1ps;
    
    // Checks to make sure the .sv wrapper and library agree
    import "DPI-C" function void secret_top_protectlib_check_hash(int protectlib_hash__V);
    
    // Creates an instance of the library module at initial-time
    // (one for each instance in the user's design) also evaluates
    // the library module's initial process
    import "DPI-C" function chandle secret_top_protectlib_create(string scope__V);
    
    // Updates all non-clock inputs and retrieves the results
    import "DPI-C" function longint secret_top_protectlib_combo_update (
        chandle handle__V
        , input logic KEYSIG_DATA
        , input logic KEYSIG_CLK
        , input logic up
        , input logic down
        , output logic [3:0]  an
        , output logic [7:0]  seg
        , output logic h_sync
        , output logic v_sync
        , output logic [3:0]  R_VAL
        , output logic [3:0]  G_VAL
        , output logic [3:0]  B_VAL
        , input logic [15:0]  sw
        , output logic [15:0]  LED
    );
    
    // Updates all clocks and retrieves the results
    import "DPI-C" function longint secret_top_protectlib_seq_update(
        chandle handle__V
        , input logic clk
        , input logic reset
        , output logic [3:0]  an
        , output logic [7:0]  seg
        , output logic h_sync
        , output logic v_sync
        , output logic [3:0]  R_VAL
        , output logic [3:0]  G_VAL
        , output logic [3:0]  B_VAL
        , output logic [15:0]  LED
    );
    
    // Need to convince some simulators that the input to the module
    // must be evaluated before evaluating the clock edge
    import "DPI-C" function void secret_top_protectlib_combo_ignore(
        chandle handle__V
        , input logic KEYSIG_DATA
        , input logic KEYSIG_CLK
        , input logic up
        , input logic down
        , input logic [15:0]  sw
    );
    
    // Evaluates the library module's final process
    import "DPI-C" function void secret_top_protectlib_final(chandle handle__V);
    
    // verilator tracing_off
    chandle handle__V;
    time last_combo_seqnum__V;
    time last_seq_seqnum__V;

    logic [3:0]  an_combo__V;
    logic [7:0]  seg_combo__V;
    logic h_sync_combo__V;
    logic v_sync_combo__V;
    logic [3:0]  R_VAL_combo__V;
    logic [3:0]  G_VAL_combo__V;
    logic [3:0]  B_VAL_combo__V;
    logic [15:0]  LED_combo__V;
    logic [3:0]  an_seq__V;
    logic [7:0]  seg_seq__V;
    logic h_sync_seq__V;
    logic v_sync_seq__V;
    logic [3:0]  R_VAL_seq__V;
    logic [3:0]  G_VAL_seq__V;
    logic [3:0]  B_VAL_seq__V;
    logic [15:0]  LED_seq__V;
    logic [3:0]  an_tmp__V;
    logic [7:0]  seg_tmp__V;
    logic h_sync_tmp__V;
    logic v_sync_tmp__V;
    logic [3:0]  R_VAL_tmp__V;
    logic [3:0]  G_VAL_tmp__V;
    logic [3:0]  B_VAL_tmp__V;
    logic [15:0]  LED_tmp__V;
    // Hash value to make sure this file and the corresponding
    // library agree
    localparam int protectlib_hash__V = 32'd2023643392;

    initial begin
        secret_top_protectlib_check_hash(protectlib_hash__V);
        handle__V = secret_top_protectlib_create($sformatf("%m"));
    end
    
    // Combinatorialy evaluate changes to inputs
    always @* begin
        last_combo_seqnum__V = secret_top_protectlib_combo_update(
            handle__V
            , KEYSIG_DATA
            , KEYSIG_CLK
            , up
            , down
            , an_combo__V
            , seg_combo__V
            , h_sync_combo__V
            , v_sync_combo__V
            , R_VAL_combo__V
            , G_VAL_combo__V
            , B_VAL_combo__V
            , sw
            , LED_combo__V
        );
    end
    
    // Evaluate clock edges
    always @(posedge clk or negedge clk, posedge reset or negedge reset) begin
        secret_top_protectlib_combo_ignore(
            handle__V
            , KEYSIG_DATA
            , KEYSIG_CLK
            , up
            , down
            , sw
        );
        last_seq_seqnum__V <= secret_top_protectlib_seq_update(
            handle__V
            , clk
            , reset
            , an_tmp__V
            , seg_tmp__V
            , h_sync_tmp__V
            , v_sync_tmp__V
            , R_VAL_tmp__V
            , G_VAL_tmp__V
            , B_VAL_tmp__V
            , LED_tmp__V
        );
        an_seq__V <= an_tmp__V;
        seg_seq__V <= seg_tmp__V;
        h_sync_seq__V <= h_sync_tmp__V;
        v_sync_seq__V <= v_sync_tmp__V;
        R_VAL_seq__V <= R_VAL_tmp__V;
        G_VAL_seq__V <= G_VAL_tmp__V;
        B_VAL_seq__V <= B_VAL_tmp__V;
        LED_seq__V <= LED_tmp__V;
    end
    
    // Select between combinatorial and sequential results
    always @* begin
        if (last_seq_seqnum__V > last_combo_seqnum__V) begin
            an = an_seq__V;
            seg = seg_seq__V;
            h_sync = h_sync_seq__V;
            v_sync = v_sync_seq__V;
            R_VAL = R_VAL_seq__V;
            G_VAL = G_VAL_seq__V;
            B_VAL = B_VAL_seq__V;
            LED = LED_seq__V;
        end
        else begin
            an = an_combo__V;
            seg = seg_combo__V;
            h_sync = h_sync_combo__V;
            v_sync = v_sync_combo__V;
            R_VAL = R_VAL_combo__V;
            G_VAL = G_VAL_combo__V;
            B_VAL = B_VAL_combo__V;
            LED = LED_combo__V;
        end
    end
    
    final secret_top_protectlib_final(handle__V);
    
endmodule
