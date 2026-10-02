module instruction_memory (
    input  wire [31:0] address,
    output wire [31:0] instruction
);

    reg [31:0] memory [0:255];

    // Load instructions from external HEX file
    initial begin
        $readmemh("program/program.hex", memory);
    end

    // Word-aligned instruction access
    assign instruction = memory[address[9:2]];

endmodule
