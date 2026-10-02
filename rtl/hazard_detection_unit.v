module hazard_detection_unit (
    // Instruction currently in ID stage
    input wire [4:0] rs1_id,
    input wire [4:0] rs2_id,

    // Instruction currently in EX stage
    input wire [4:0] rd_ex,
    input wire        mem_read_ex,

    // Control outputs
    output reg        stall,
    output reg        pc_write,
    output reg        if_id_write,
    output reg        id_ex_flush
);

    always @(*) begin

        // Default: normal pipeline operation
        stall       = 1'b0;
        pc_write    = 1'b1;
        if_id_write = 1'b1;
        id_ex_flush = 1'b0;


        // ==========================================
        // Load-Use Hazard Detection
        // ==========================================

        if (mem_read_ex &&
            (rd_ex != 5'd0) &&
            ((rd_ex == rs1_id) ||
             (rd_ex == rs2_id))) begin

            // Stall the PC
            pc_write = 1'b0;

            // Hold IF/ID
            if_id_write = 1'b0;

            // Insert bubble into ID/EX
            id_ex_flush = 1'b1;

            stall = 1'b1;

        end

    end

endmodule
