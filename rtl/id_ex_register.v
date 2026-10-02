module id_ex_register (
    input wire        clk,
    input wire        reset,
    input wire        flush,

    // Data from ID stage
    input wire [31:0] pc_in,
    input wire [31:0] rs1_data_in,
    input wire [31:0] rs2_data_in,
    input wire [31:0] immediate_in,

    input wire [4:0]  rs1_in,
    input wire [4:0]  rs2_in,
    input wire [4:0]  rd_in,

    // Instruction information
    input wire [2:0]  funct3_in,
    input wire [6:0]  funct7_in,

    // Control signals
    input wire        reg_write_in,
    input wire        mem_read_in,
    input wire        mem_write_in,
    input wire        mem_to_reg_in,
    input wire        alu_src_in,
    input wire        branch_in,
    input wire        jump_in,

    input wire [3:0]  alu_sel_in,

    // Data to EX stage
    output reg [31:0] pc_out,
    output reg [31:0] rs1_data_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] immediate_out,

    output reg [4:0]  rs1_out,
    output reg [4:0]  rs2_out,
    output reg [4:0]  rd_out,

    output reg [2:0]  funct3_out,
    output reg [6:0]  funct7_out,

    // Control signals
    output reg        reg_write_out,
    output reg        mem_read_out,
    output reg        mem_write_out,
    output reg        mem_to_reg_out,
    output reg        alu_src_out,
    output reg        branch_out,
    output reg        jump_out,

    output reg [3:0]  alu_sel_out
);

    always @(posedge clk) begin

        if (reset) begin

            pc_out          <= 32'd0;
            rs1_data_out    <= 32'd0;
            rs2_data_out    <= 32'd0;
            immediate_out   <= 32'd0;

            rs1_out         <= 5'd0;
            rs2_out         <= 5'd0;
            rd_out          <= 5'd0;

            funct3_out      <= 3'd0;
            funct7_out      <= 7'd0;

            reg_write_out   <= 1'b0;
            mem_read_out    <= 1'b0;
            mem_write_out   <= 1'b0;
            mem_to_reg_out  <= 1'b0;

            alu_src_out     <= 1'b0;
            branch_out      <= 1'b0;
            jump_out        <= 1'b0;

            alu_sel_out     <= 4'd0;

        end

        else if (flush) begin

            // Insert bubble into EX stage

            pc_out          <= 32'd0;
            rs1_data_out    <= 32'd0;
            rs2_data_out    <= 32'd0;
            immediate_out   <= 32'd0;

            rs1_out         <= 5'd0;
            rs2_out         <= 5'd0;
            rd_out          <= 5'd0;

            funct3_out      <= 3'd0;
            funct7_out      <= 7'd0;

            reg_write_out   <= 1'b0;
            mem_read_out    <= 1'b0;
            mem_write_out   <= 1'b0;
            mem_to_reg_out  <= 1'b0;

            alu_src_out     <= 1'b0;
            branch_out      <= 1'b0;
            jump_out        <= 1'b0;

            alu_sel_out     <= 4'd0;

        end

        else begin

            pc_out          <= pc_in;
            rs1_data_out    <= rs1_data_in;
            rs2_data_out    <= rs2_data_in;
            immediate_out   <= immediate_in;

            rs1_out         <= rs1_in;
            rs2_out         <= rs2_in;
            rd_out          <= rd_in;

            funct3_out      <= funct3_in;
            funct7_out      <= funct7_in;

            reg_write_out   <= reg_write_in;
            mem_read_out    <= mem_read_in;
            mem_write_out   <= mem_write_in;
            mem_to_reg_out  <= mem_to_reg_in;

            alu_src_out     <= alu_src_in;
            branch_out      <= branch_in;
            jump_out        <= jump_in;

            alu_sel_out     <= alu_sel_in;

        end

    end

endmodule
