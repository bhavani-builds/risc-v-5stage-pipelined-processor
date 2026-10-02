module forwarding_unit (
    // Source registers of instruction in EX stage
    input wire [4:0] rs1_ex,
    input wire [4:0] rs2_ex,

    // Destination register of instruction in MEM stage
    input wire [4:0] rd_mem,
    input wire        reg_write_mem,

    // Destination register of instruction in WB stage
    input wire [4:0] rd_wb,
    input wire        reg_write_wb,

    // Forwarding controls
    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);

    always @(*) begin

        // Default:
        // 00 = use original register value
        forward_a = 2'b00;
        forward_b = 2'b00;


        // ==========================================
        // Forward from MEM stage
        // ==========================================

        if (reg_write_mem &&
            (rd_mem != 5'd0) &&
            (rd_mem == rs1_ex)) begin

            forward_a = 2'b10;

        end

        if (reg_write_mem &&
            (rd_mem != 5'd0) &&
            (rd_mem == rs2_ex)) begin

            forward_b = 2'b10;

        end


        // ==========================================
        // Forward from WB stage
        // ==========================================

        if (reg_write_wb &&
            (rd_wb != 5'd0) &&
            (rd_wb == rs1_ex) &&
            !(reg_write_mem &&
              (rd_mem != 5'd0) &&
              (rd_mem == rs1_ex))) begin

            forward_a = 2'b01;

        end

        if (reg_write_wb &&
            (rd_wb != 5'd0) &&
            (rd_wb == rs2_ex) &&
            !(reg_write_mem &&
              (rd_mem != 5'd0) &&
              (rd_mem == rs2_ex))) begin

            forward_b = 2'b01;

        end

    end

endmodule
