module control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,

    output reg        reg_write,
    output reg        mem_read,
    output reg        mem_write,
    output reg        mem_to_reg,

    output reg        alu_src,
    output reg [3:0]  alu_sel,

    output reg        branch,
    output reg        jump,

    output reg [2:0]  imm_type
);

    // ==========================================
    // RISC-V Opcodes
    // ==========================================

    localparam OP_RTYPE  = 7'b0110011;
    localparam OP_ITYPE  = 7'b0010011;
    localparam OP_LOAD   = 7'b0000011;
    localparam OP_STORE  = 7'b0100011;
    localparam OP_BRANCH = 7'b1100011;
    localparam OP_JAL    = 7'b1101111;


    // ==========================================
    // ALU Operations
    // ==========================================

    localparam ALU_ADD = 4'b0000;
    localparam ALU_SUB = 4'b0001;
    localparam ALU_AND = 4'b0010;
    localparam ALU_OR  = 4'b0011;
    localparam ALU_XOR = 4'b0100;
    localparam ALU_SLT = 4'b0101;
    localparam ALU_SLTU = 4'b0110;


    // ==========================================
    // Control Logic
    // ==========================================

    always @(*) begin

        // Default values
        reg_write = 1'b0;
        mem_read  = 1'b0;
        mem_write = 1'b0;
        mem_to_reg = 1'b0;

        alu_src = 1'b0;
        alu_sel = ALU_ADD;

        branch = 1'b0;
        jump   = 1'b0;

        imm_type = 3'b000;


        case (opcode)

            // ==================================
            // R-Type
            // ==================================

            OP_RTYPE: begin

                reg_write = 1'b1;
                alu_src   = 1'b0;

                case (funct3)

                    3'b000: begin
                        if (funct7 == 7'b0100000)
                            alu_sel = ALU_SUB;
                        else
                            alu_sel = ALU_ADD;
                    end

                    3'b111:
                        alu_sel = ALU_AND;

                    3'b110:
                        alu_sel = ALU_OR;

                    3'b100:
                        alu_sel = ALU_XOR;

                    3'b010:
                        alu_sel = ALU_SLT;

                    3'b011:
                        alu_sel = ALU_SLTU;

                    default:
                        alu_sel = ALU_ADD;

                endcase

            end


            // ==================================
            // I-Type
            // ADDI
            // ==================================

            OP_ITYPE: begin

                reg_write = 1'b1;
                alu_src   = 1'b1;
                imm_type  = 3'b000;

                case (funct3)

                    3'b000:
                        alu_sel = ALU_ADD;

                    default:
                        alu_sel = ALU_ADD;

                endcase

            end


            // ==================================
            // LW
            // ==================================

            OP_LOAD: begin

                reg_write  = 1'b1;
                mem_read   = 1'b1;
                mem_to_reg = 1'b1;

                alu_src  = 1'b1;
                alu_sel  = ALU_ADD;
                imm_type = 3'b000;

            end


            // ==================================
            // SW
            // ==================================

            OP_STORE: begin

                mem_write = 1'b1;

                alu_src  = 1'b1;
                alu_sel  = ALU_ADD;
                imm_type = 3'b001;

            end


            // ==================================
            // BEQ / BNE
            // ==================================

            OP_BRANCH: begin

                branch   = 1'b1;
                alu_src  = 1'b0;
                alu_sel  = ALU_SUB;

                imm_type = 3'b010;

            end


            // ==================================
            // JAL
            // ==================================

            OP_JAL: begin

                reg_write = 1'b1;
                jump      = 1'b1;

                imm_type = 3'b011;

            end


            default: begin

                reg_write  = 1'b0;
                mem_read   = 1'b0;
                mem_write  = 1'b0;
                mem_to_reg = 1'b0;

                alu_src = 1'b0;
                alu_sel = ALU_ADD;

                branch = 1'b0;
                jump   = 1'b0;

                imm_type = 3'b000;

            end

        endcase

    end

endmodule
