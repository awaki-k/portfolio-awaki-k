`timescale 1ns / 1ps

// based on  https://github.com/pConst/basic_verilog.git

// !!!!!!!!!!!!!!!!!!!!!!!!!!! ATTENTION !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//Hello! This is a collection of verilog systemverilog synthesizable modules.
//All the code is highly reusable across typical FPGA projects and mainstream FPGA vendors.
//Please feel free to contact me in case you found any code issues.
//Also, give me a pleasure, tell me if the code has got succesfully implemented in your hobby, scientific or industrial projects!

//Konstantin Pavlov, pavlovconst@gmail.com

//The code is licensed under CC BY-SA 4_0.
//You can remix, transform, and build upon the material for any purpose, even commercially
//You must provide the name of the creator and distribute your contributions under the same license as the original
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

module AdderTree #(
  parameter INPUTS_NUM = 32,
  parameter IDATA_WIDTH = 1,
  parameter STAGE_DEPTH = 3,

  parameter STAGES_NUM = $clog2(INPUTS_NUM),
  parameter INPUTS_NUM_INT = 2 ** STAGES_NUM,
  parameter ODATA_WIDTH = IDATA_WIDTH + STAGES_NUM
)(
  input clk,
  input reset,
  input wen,
  input logic [INPUTS_NUM-1:0][IDATA_WIDTH-1:0] idata,
  output logic [ODATA_WIDTH-1:0] odata
);

logic [STAGES_NUM:0][INPUTS_NUM_INT-1:0][ODATA_WIDTH-1:0] data;

// generating tree
genvar stage, adder;
generate
  for( stage = 0; stage <= STAGES_NUM; stage++ ) begin: stage_gen

    localparam ST_OUT_NUM = INPUTS_NUM_INT >> stage;
    localparam ST_WIDTH = IDATA_WIDTH + stage;

    if( stage == '0 ) begin
      // stege 0 is actually module inputs
      for( adder = 0; adder < ST_OUT_NUM; adder++ ) begin: inputs_gen

        always_comb begin
          if( adder < INPUTS_NUM ) begin
            data[stage][adder][ST_WIDTH-1:0] <= idata[adder][ST_WIDTH-1:0];
            data[stage][adder][ODATA_WIDTH-1:ST_WIDTH] <= '0;
          end else begin
            data[stage][adder][ODATA_WIDTH-1:0] <= '0;
          end
        end // always_comb

      end // for
    end else begin
      // all other stages hold adders outputs
      for( adder = 0; adder < ST_OUT_NUM; adder++ ) begin: adder_gen

        if ( stage % STAGE_DEPTH == 0 ) begin
             //always_comb begin       // is also possible here
            always_ff@(posedge clk) begin
              if( reset ) begin
                data[stage][adder][ODATA_WIDTH-1:0] <= '0;
              end else begin
                if (wen) begin
                    data[stage][adder][ST_WIDTH-1:0] <=
                            $signed(data[stage-1][adder*2][(ST_WIDTH-1)-1:0]) +
                            $signed(data[stage-1][adder*2+1][(ST_WIDTH-1)-1:0]);
                end
              end
            end // always
        end
        else begin
            always_comb begin       // is also possible here
                data[stage][adder][ST_WIDTH-1:0] <=
                        $signed(data[stage-1][adder*2][(ST_WIDTH-1)-1:0]) +
                        $signed(data[stage-1][adder*2+1][(ST_WIDTH-1)-1:0]);
            end // always                
        end

      end // for
    end // if stage
  end // for
endgenerate

assign odata = data[STAGES_NUM][0];

endmodule

