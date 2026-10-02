module immediate_generator (
    input  wire [31:0] instruction,
    input  wire [2:0]  imm_type,

    output reg [31:0] immediate
);

    always @(*) begin

        case (imm_type)

            // I-Type
            3'b000:
                immediate = {{20{instruction[31]}},
                             instruction[31:20]};

            // S-Type
            3'b001:
                immediate = {{20{instruction[31]}},
                             instruction[31:25],
                             instruction[11:7]};

            // B-Type
            3'b010:
                immediate = {{19{instruction[31]}},
                             instruction[31],
                             instruction[7],
                             instruction[30:25],
                             instruction[11:8],
                             1'b0};

            // J-Type
            3'b011:
                immediate = {{11{instruction[31]}},
                             instruction[31],
                             instruction[19:12],
                             instruction[20],
                             instruction[30:21],
                             1'b0};

            default:
                immediate = 32'd0;

        endcase

    end

endmodule
