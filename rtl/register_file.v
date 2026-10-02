module register_file (
    input  wire        clk,
    input  wire        reset,

    // Read ports
    input  wire [4:0]  rs1,
    input  wire [4:0]  rs2,

    output wire [31:0] read_data1,
    output wire [31:0] read_data2,

    // Write port
    input  wire        reg_write,
    input  wire [4:0]  rd,
    input  wire [31:0] write_data
);

    reg [31:0] registers [0:31];

    integer i;

    // Asynchronous register reads
    assign read_data1 =
        (rs1 == 5'd0) ? 32'd0 : registers[rs1];

    assign read_data2 =
        (rs2 == 5'd0) ? 32'd0 : registers[rs2];

    // Synchronous register write
    always @(posedge clk) begin

        if (reset) begin

            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'd0;

        end

        else if (reg_write && (rd != 5'd0)) begin

            registers[rd] <= write_data;

        end

    end

endmodule
