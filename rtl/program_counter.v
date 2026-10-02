module program_counter (
    input  wire        clk,
    input  wire        reset,
    input  wire        stall,
    input  wire [31:0] next_pc,

    output reg  [31:0] pc
);

    always @(posedge clk) begin

        if (reset) begin
            pc <= 32'h00000000;
        end

        else if (stall) begin
            pc <= pc;
        end

        else begin
            pc <= next_pc;
        end

    end

endmodule
