module pipeline_cpu (
    input wire clk,
    input wire reset
);

    // =========================================================
    // IF STAGE
    // =========================================================

    wire [31:0] pc;
    reg  [31:0] next_pc;

    wire [31:0] instruction;

    wire pc_write;
    wire if_id_write;
    wire if_id_flush;
    wire id_ex_flush;

    program_counter pc_unit (
        .clk     (clk),
        .reset   (reset),
        .stall   (!pc_write),
        .next_pc (next_pc),
        .pc      (pc)
    );

    instruction_memory imem (
        .address     (pc),
        .instruction (instruction)
    );


    // =========================================================
    // IF/ID PIPELINE REGISTER
    // =========================================================

    wire [31:0] if_id_pc;
    wire [31:0] if_id_instruction;

    if_id_register if_id (
        .clk            (clk),
        .reset          (reset),
        .stall          (!if_id_write),
        .flush          (if_id_flush),

        .pc_in          (pc),
        .instruction_in (instruction),

        .pc_out         (if_id_pc),
        .instruction_out(if_id_instruction)
    );


    // =========================================================
    // ID STAGE
    // =========================================================

    wire [6:0] opcode;
    wire [4:0] rs1_id;
    wire [4:0] rs2_id;
    wire [4:0] rd_id;

    wire [2:0] funct3_id;
    wire [6:0] funct7_id;

    assign opcode    = if_id_instruction[6:0];
    assign rd_id     = if_id_instruction[11:7];
    assign funct3_id = if_id_instruction[14:12];
    assign rs1_id    = if_id_instruction[19:15];
    assign rs2_id    = if_id_instruction[24:20];
    assign funct7_id = if_id_instruction[31:25];


    // =========================================================
    // CONTROL UNIT
    // =========================================================

    wire       reg_write_id;
    wire       mem_read_id;
    wire       mem_write_id;
    wire       mem_to_reg_id;

    wire       alu_src_id;
    wire       branch_id;
    wire       jump_id;

    wire [3:0] alu_sel_id;
    wire [2:0] imm_type_id;

    control_unit control (
        .opcode     (opcode),
        .funct3     (funct3_id),
        .funct7     (funct7_id),

        .reg_write  (reg_write_id),
        .mem_read   (mem_read_id),
        .mem_write  (mem_write_id),
        .mem_to_reg (mem_to_reg_id),

        .alu_src    (alu_src_id),
        .alu_sel    (alu_sel_id),

        .branch     (branch_id),
        .jump       (jump_id),

        .imm_type   (imm_type_id)
    );


    // =========================================================
    // REGISTER FILE
    // =========================================================

    wire [31:0] rs1_data_id;
    wire [31:0] rs2_data_id;

    wire [31:0] write_back_data;

    register_file registers (
        .clk        (clk),
        .reset      (reset),

        .rs1        (rs1_id),
        .rs2        (rs2_id),

        .read_data1 (rs1_data_id),
        .read_data2 (rs2_data_id),

        .reg_write  (wb_reg_write),
        .rd         (wb_rd),
        .write_data (write_back_data)
    );


    // =========================================================
    // IMMEDIATE GENERATOR
    // =========================================================

    wire [31:0] immediate_id;

    immediate_generator imm_gen (
        .instruction(if_id_instruction),
        .imm_type    (imm_type_id),
        .immediate   (immediate_id)
    );


    // =========================================================
    // HAZARD DETECTION
    // =========================================================

    wire hazard_stall;

    hazard_detection_unit hazard_unit (
        .rs1_id       (rs1_id),
        .rs2_id       (rs2_id),

        .rd_ex        (id_ex_rd),
        .mem_read_ex  (id_ex_mem_read),

        .stall        (hazard_stall),
        .pc_write     (pc_write),
        .if_id_write  (if_id_write),
        .id_ex_flush  (id_ex_flush)
    );


    // =========================================================
    // ID/EX PIPELINE REGISTER
    // =========================================================

    wire [31:0] id_ex_pc;
    wire [31:0] id_ex_rs1_data;
    wire [31:0] id_ex_rs2_data;
    wire [31:0] id_ex_immediate;

    wire [4:0] id_ex_rs1;
    wire [4:0] id_ex_rs2;
    wire [4:0] id_ex_rd;

    wire [2:0] id_ex_funct3;
    wire [6:0] id_ex_funct7;

    wire id_ex_reg_write;
    wire id_ex_mem_read;
    wire id_ex_mem_write;
    wire id_ex_mem_to_reg;

    wire id_ex_alu_src;
    wire id_ex_branch;
    wire id_ex_jump;

    wire [3:0] id_ex_alu_sel;

    id_ex_register id_ex (
        .clk            (clk),
        .reset          (reset),
        .flush          (id_ex_flush | ex_control_flush),

        .pc_in          (if_id_pc),
        .rs1_data_in    (rs1_data_id),
        .rs2_data_in    (rs2_data_id),
        .immediate_in   (immediate_id),

        .rs1_in         (rs1_id),
        .rs2_in         (rs2_id),
        .rd_in          (rd_id),

        .funct3_in      (funct3_id),
        .funct7_in      (funct7_id),

        .reg_write_in   (reg_write_id),
        .mem_read_in    (mem_read_id),
        .mem_write_in   (mem_write_id),
        .mem_to_reg_in  (mem_to_reg_id),

        .alu_src_in     (alu_src_id),
        .branch_in      (branch_id),
        .jump_in        (jump_id),

        .alu_sel_in     (alu_sel_id),

        .pc_out         (id_ex_pc),
        .rs1_data_out   (id_ex_rs1_data),
        .rs2_data_out   (id_ex_rs2_data),
        .immediate_out  (id_ex_immediate),

        .rs1_out        (id_ex_rs1),
        .rs2_out        (id_ex_rs2),
        .rd_out         (id_ex_rd),

        .funct3_out     (id_ex_funct3),
        .funct7_out     (id_ex_funct7),

        .reg_write_out  (id_ex_reg_write),
        .mem_read_out   (id_ex_mem_read),
        .mem_write_out  (id_ex_mem_write),
        .mem_to_reg_out (id_ex_mem_to_reg),

        .alu_src_out    (id_ex_alu_src),
        .branch_out     (id_ex_branch),
        .jump_out       (id_ex_jump),

        .alu_sel_out    (id_ex_alu_sel)
    );


    // =========================================================
    // FORWARDING UNIT
    // =========================================================

    wire [1:0] forward_a;
    wire [1:0] forward_b;

    forwarding_unit forwarding (
        .rs1_ex        (id_ex_rs1),
        .rs2_ex        (id_ex_rs2),

        .rd_mem        (ex_mem_rd),
        .reg_write_mem (ex_mem_reg_write),

        .rd_wb         (wb_rd),
        .reg_write_wb  (wb_reg_write),

        .forward_a     (forward_a),
        .forward_b     (forward_b)
    );


    // =========================================================
    // EX STAGE OPERANDS
    // =========================================================

    reg [31:0] alu_input_a;
    reg [31:0] forwarded_rs2;

    always @(*) begin

        case (forward_a)

            2'b10:
                alu_input_a = ex_mem_alu_result;

            2'b01:
                alu_input_a = write_back_data;

            default:
                alu_input_a = id_ex_rs1_data;

        endcase

    end


    always @(*) begin

        case (forward_b)

            2'b10:
                forwarded_rs2 = ex_mem_alu_result;

            2'b01:
                forwarded_rs2 = write_back_data;

            default:
                forwarded_rs2 = id_ex_rs2_data;

        endcase

    end


    wire [31:0] alu_input_b;

    assign alu_input_b =
        id_ex_alu_src ? id_ex_immediate : forwarded_rs2;


    // =========================================================
    // ALU
    // =========================================================

    wire [31:0] alu_result;
    wire        alu_zero;

    alu alu_unit (
        .a       (alu_input_a),
        .b       (alu_input_b),
        .alu_sel (id_ex_alu_sel),

        .result  (alu_result),
        .zero    (alu_zero)
    );


    // =========================================================
    // BRANCH / JUMP LOGIC
    // =========================================================

    reg branch_condition;

    always @(*) begin

        branch_condition = 1'b0;

        if (id_ex_branch) begin

            case (id_ex_funct3)

                // BEQ
                3'b000:
                    branch_condition =
                        (alu_input_a == forwarded_rs2);

                // BNE
                3'b001:
                    branch_condition =
                        (alu_input_a != forwarded_rs2);

                default:
                    branch_condition = 1'b0;

            endcase

        end

    end


    wire branch_taken;

    assign branch_taken =
        branch_condition | id_ex_jump;


    wire [31:0] branch_target;

    assign branch_target =
        id_ex_pc + id_ex_immediate;


    // Flush younger instructions after control transfer
    wire ex_control_flush;

    assign ex_control_flush = branch_taken;


    assign if_id_flush = branch_taken;


    // =========================================================
    // NEXT PC
    // =========================================================

    always @(*) begin

        next_pc = pc + 32'd4;

        if (branch_taken)
            next_pc = branch_target;

    end


    // =========================================================
    // EX/MEM PIPELINE REGISTER
    // =========================================================

    wire [31:0] ex_mem_alu_result;
    wire [31:0] ex_mem_rs2_data;
    wire [31:0] ex_mem_pc_plus4;

    wire [4:0] ex_mem_rd;

    wire ex_mem_branch_taken;
    wire [31:0] ex_mem_branch_target;

    wire ex_mem_reg_write;
    wire ex_mem_mem_read;
    wire ex_mem_mem_write;
    wire ex_mem_mem_to_reg;

    ex_mem_register ex_mem (
        .clk             (clk),
        .reset           (reset),

        .alu_result_in   (alu_result),
        .rs2_data_in     (forwarded_rs2),
        .pc_plus4_in     (id_ex_pc + 32'd4),

        .rd_in           (id_ex_rd),

        .branch_taken_in (branch_taken),
        .branch_target_in(branch_target),

        .reg_write_in    (id_ex_reg_write),
        .mem_read_in     (id_ex_mem_read),
        .mem_write_in    (id_ex_mem_write),
        .mem_to_reg_in   (id_ex_mem_to_reg),

        .alu_result_out  (ex_mem_alu_result),
        .rs2_data_out    (ex_mem_rs2_data),
        .pc_plus4_out    (ex_mem_pc_plus4),

        .rd_out          (ex_mem_rd),

        .branch_taken_out(ex_mem_branch_taken),
        .branch_target_out(ex_mem_branch_target),

        .reg_write_out   (ex_mem_reg_write),
        .mem_read_out    (ex_mem_mem_read),
        .mem_write_out   (ex_mem_mem_write),
        .mem_to_reg_out  (ex_mem_mem_to_reg)
    );


    // =========================================================
    // DATA MEMORY
    // =========================================================

    wire [31:0] memory_read_data;

    data_memory dmem (
        .clk       (clk),
        .reset     (reset),

        .mem_read  (ex_mem_mem_read),
        .mem_write (ex_mem_mem_write),

        .address   (ex_mem_alu_result),
        .write_data(ex_mem_rs2_data),

        .read_data (memory_read_data)
    );


    // =========================================================
    // MEM/WB PIPELINE REGISTER
    // =========================================================

    wire [31:0] wb_memory_data;
    wire [31:0] wb_alu_result;
    wire [31:0] wb_pc_plus4;

    wire [4:0] wb_rd;

    wire wb_reg_write;
    wire wb_mem_to_reg;
    wire wb_jump;

    mem_wb_register mem_wb (
        .clk             (clk),
        .reset           (reset),

        .memory_data_in  (memory_read_data),
        .alu_result_in   (ex_mem_alu_result),
        .pc_plus4_in     (ex_mem_pc_plus4),

        .rd_in           (ex_mem_rd),

        .reg_write_in    (ex_mem_reg_write),
        .mem_to_reg_in   (ex_mem_mem_to_reg),
        .jump_in         (id_ex_jump),

        .memory_data_out (wb_memory_data),
        .alu_result_out  (wb_alu_result),
        .pc_plus4_out    (wb_pc_plus4),

        .rd_out          (wb_rd),

        .reg_write_out   (wb_reg_write),
        .mem_to_reg_out  (wb_mem_to_reg),
        .jump_out        (wb_jump)
    );


    // =========================================================
    // WRITE-BACK STAGE
    // =========================================================

    assign write_back_data =
        wb_jump ? wb_pc_plus4 :
        wb_mem_to_reg ? wb_memory_data :
        wb_alu_result;


endmodule
