`timescale 1ns/1ps
interface spi_if(input logic clk);
  logic rst;
  logic start;
  logic [7:0]master_data_in;
  logic [7:0]slave_data_in;
  logic data_ready;
  wire [7:0]master_data_out;
  wire [7:0]slave_data_out;
  wire mosi,miso,sclk,cs;
  wire busy,done,data_valid;

  clocking drv_cb @(posedge clk);
    output start;
    output master_data_in;
    output slave_data_in;
    output data_ready;
    input master_data_out;
    input slave_data_out;
    input busy;
    input done;
    input data_valid;
  endclocking

  clocking mon_cb @(posedge clk);
    input start;
    input master_data_in;
    input slave_data_in;
    input data_ready;
    input master_data_out;
    input slave_data_out;
    input mosi;
    input miso;
    input sclk;
    input cs;
    input busy;
    input done;
    input data_valid;
  endclocking

  modport DRV(clocking drv_cb,input clk,input rst);
  modport MON(clocking mon_cb,input clk,input rst);
endinterface

class spi_transaction;
  rand bit [7:0]master_tx;
  rand bit [7:0]slave_tx;
  bit [7:0]master_rx;
  bit [7:0]slave_rx;

  function void display(string tag);
    $display("[%s] MSTR_TX=%0h SLV_TX=%0h MSTR_RX=%0h SLV_RX=%0h",
              tag,master_tx,slave_tx,master_rx,slave_rx);
  endfunction
endclass

class spi_generator;
  mailbox #(spi_transaction) gen2drv;

  function new(mailbox #(spi_transaction) gen2drv);
    this.gen2drv=gen2drv;
  endfunction

      task run();
    spi_transaction tr;

    tr=new();
    tr.master_tx=8'h00;
    tr.slave_tx=8'h10;
    tr.display("GEN_CORNER1");
    gen2drv.put(tr);
    #100;

    tr=new();
    tr.master_tx=8'hFF;
    tr.slave_tx=8'h80;
    tr.display("GEN_CORNER2");
    gen2drv.put(tr);
    #100;

    tr=new();
    tr.master_tx=8'hAA;
    tr.slave_tx=8'hF0;
    tr.display("GEN_CORNER3");
    gen2drv.put(tr);
    #100;

    tr=new();
    tr.master_tx=8'h55;
    tr.slave_tx=8'h10;
    tr.display("GEN_CORNER4");
    gen2drv.put(tr);
    #100;

    tr=new();
    tr.master_tx=8'h10;
    tr.slave_tx=8'h10;
    tr.display("GEN_X1");
    gen2drv.put(tr);
    #100;

    tr=new();
    tr.master_tx=8'h10;
    tr.slave_tx=8'h80;
    tr.display("GEN_X2");
    gen2drv.put(tr);
    #100;

    tr=new();
    tr.master_tx=8'h10;
    tr.slave_tx=8'hF0;
    tr.display("GEN_X3");
    gen2drv.put(tr);
    #100;

    tr=new();
    tr.master_tx=8'h55;
    tr.slave_tx=8'h10;
    tr.display("GEN_X4");
    gen2drv.put(tr);
    #100;

    tr=new();
    tr.master_tx=8'h55;
    tr.slave_tx=8'h80;
    tr.display("GEN_X5");
    gen2drv.put(tr);
    #100;

    tr=new();
    tr.master_tx=8'h55;
    tr.slave_tx=8'hF0;
    tr.display("GEN_X6");
    gen2drv.put(tr);
    #100;

    tr=new();
    tr.master_tx=8'hF0;
    tr.slave_tx=8'h10;
    tr.display("GEN_X7");
    gen2drv.put(tr);
    #100;

    tr=new();
    tr.master_tx=8'hF0;
    tr.slave_tx=8'h80;
    tr.display("GEN_X8");
    gen2drv.put(tr);
    #100;

    tr=new();
    tr.master_tx=8'hF0;
    tr.slave_tx=8'hF0;
    tr.display("GEN_X9");
    gen2drv.put(tr);
    #100;
  endtask
endclass

typedef class spi_coverage;
class spi_driver;
  virtual spi_if.DRV vif;
  mailbox #(spi_transaction) gen2drv;
  mailbox #(spi_transaction) drv2scb;
  spi_coverage cov;

  function new(
    virtual spi_if.DRV vif,
    mailbox #(spi_transaction) gen2drv,
    mailbox #(spi_transaction) drv2scb,
    spi_coverage cov
  );
    this.vif=vif;
    this.gen2drv=gen2drv;
    this.drv2scb=drv2scb;
    this.cov=cov;
  endfunction

  task run();
    spi_transaction tr;
    forever begin
      gen2drv.get(tr);
      @(vif.drv_cb);
      vif.drv_cb.master_data_in<=tr.master_tx;
      vif.drv_cb.slave_data_in<=tr.slave_tx;
      vif.drv_cb.data_ready<=1'b1;
      vif.drv_cb.start<=1'b0;
      @(vif.drv_cb);
      vif.drv_cb.start<=1'b1;
      @(vif.drv_cb);
      vif.drv_cb.start<=1'b0;

      begin : wait_done
        automatic bit found=0;

        while(!found) begin
          @(vif.drv_cb);

          if(vif.drv_cb.done)
            found=1;
        end
      end
      tr.master_rx=vif.drv_cb.master_data_out;
      tr.slave_rx=vif.drv_cb.slave_data_out;

      cov.sample(tr);

      drv2scb.put(tr);

      $display("[DRIVER] MSTR_TX=%0h SLV_TX=%0h MSTR_RX=%0h SLV_RX=%0h",
                tr.master_tx,tr.slave_tx,tr.master_rx,tr.slave_rx);
    end
  endtask
endclass

class spi_monitor;
  virtual spi_if.MON vif;
  mailbox #(spi_transaction) mon2scb;
  function new(
    virtual spi_if.MON vif,
    mailbox #(spi_transaction) mon2scb
  );
    this.vif=vif;
    this.mon2scb=mon2scb;
  endfunction

  task run();
    spi_transaction tr;

    forever begin
      begin : mon_wait
        automatic bit found=0;

        while(!found) begin
          @(vif.mon_cb);

          if(vif.mon_cb.done)
            found=1;
        end
      end

      tr=new();
      tr.master_tx=vif.mon_cb.master_data_in;
      tr.slave_tx=vif.mon_cb.slave_data_in;
      tr.master_rx=vif.mon_cb.master_data_out;
      tr.slave_rx=vif.mon_cb.slave_data_out;
      mon2scb.put(tr);
      $display("[MONITOR] MSTR_TX=%0h SLV_TX=%0h MSTR_RX=%0h SLV_RX=%0h",
                tr.master_tx,tr.slave_tx,tr.master_rx,tr.slave_rx);
    end
  endtask
endclass

class spi_scoreboard;
  mailbox #(spi_transaction) drv2scb;
  mailbox #(spi_transaction) mon2scb;
  int pass_cnt=0;
  int fail_cnt=0;

  function new(
    mailbox #(spi_transaction) drv2scb,
    mailbox #(spi_transaction) mon2scb
  );
    this.drv2scb=drv2scb;
    this.mon2scb=mon2scb;
  endfunction

  task check(string label,bit [7:0]exp,bit [7:0]act);
    if(exp==act) begin
      $display("[SCOREBOARD] PASS %-12s EXP=%0h ACT=%0h",label,exp,act);
      pass_cnt++;
    end
    else begin
      $display("[SCOREBOARD] FAIL %-12s EXP=%0h ACT=%0h",label,exp,act);
      fail_cnt++;
    end
  endtask

  task run();
    spi_transaction dtr,mtr;
    fork
      forever begin
        mon2scb.get(mtr);
      end
      forever begin
        drv2scb.get(dtr);

        check("MASTER_RX:",dtr.slave_tx,dtr.master_rx);

        check("SLAVE_RX: ",dtr.master_tx,dtr.slave_rx);
      end
    join
  endtask

  function void report();
    $display("[SCOREBOARD] TOTAL PASS=%0d  FAIL=%0d",
              pass_cnt,fail_cnt);
  endfunction
endclass

class spi_coverage;
  spi_transaction tr;

  covergroup spi_cg;

    MASTER_TX: coverpoint tr.master_tx {
      bins LOW={[8'h00:8'h3F]};
      bins MID={[8'h40:8'hAF]};
      bins HIGH={[8'hB0:8'hFF]};
    }

    SLAVE_TX: coverpoint tr.slave_tx {
      bins LOW={[8'h00:8'h3F]};
      bins MID={[8'h40:8'hAF]};
      bins HIGH={[8'hB0:8'hFF]};
    }

    CORNERS: coverpoint tr.master_tx {
      bins ZERO={8'h00};
      bins ALL_ONE={8'hFF};
      bins ALT_AA={8'hAA};
      bins ALT_55={8'h55};
    }

    TX_CROSS: cross MASTER_TX,SLAVE_TX;

  endgroup

  function new();
    spi_cg=new();
  endfunction

  task sample(spi_transaction t);
    tr=t;
    spi_cg.sample();

    $display("[COVERAGE] CURRENT=%0.2f%%",
              spi_cg.get_inst_coverage());
  endtask

  function real get_cov();
    return spi_cg.get_inst_coverage();
  endfunction
endclass

module spi_assertions(spi_if vif);

  property p_cs_reset;
    @(posedge vif.clk)
    vif.rst |-> (vif.cs==1'b1);
  endproperty

  assert property(p_cs_reset)
    else $error("[ASSERT] CS NOT HIGH DURING RESET");

  property p_done_reset;
    @(posedge vif.clk)
    vif.rst |-> (vif.done==1'b0);
  endproperty

  assert property(p_done_reset)
    else $error("[ASSERT] DONE ACTIVE DURING RESET");

  property p_sclk_when_cs_low;
    @(posedge vif.clk)
    (vif.cs==1'b1) |-> (vif.sclk==1'b0);
  endproperty

  assert property(p_sclk_when_cs_low)
    else $error("[ASSERT] SCLK TOGGLED WHILE CS HIGH");

  property p_done_cs_high;
    @(posedge vif.clk)
    vif.done |-> (vif.cs==1'b1);
  endproperty

  assert property(p_done_cs_high)
    else $error("[ASSERT] CS NOT HIGH WHEN DONE");

endmodule

module tb_spi_vip;
  logic clk;

  always #5 clk=~clk;

  spi_if vif(clk);

  spi_master master_inst(
    .clk(clk),
    .rst(vif.rst),
    .start(vif.start),
    .data_in(vif.master_data_in),
    .miso(vif.miso),
    .mosi(vif.mosi),
    .sclk(vif.sclk),
    .cs(vif.cs),
    .data_out(vif.master_data_out),
    .busy(vif.busy),
    .done(vif.done)
  );

  spi_slave slave_inst(
    .clk(clk),
    .rst(vif.rst),
    .sclk(vif.sclk),
    .mosi(vif.mosi),
    .cs(vif.cs),
    .data_in(vif.slave_data_in),
    .data_ready(vif.data_ready),
    .miso(vif.miso),
    .data_out(vif.slave_data_out),
    .data_valid(vif.data_valid)
  );

  spi_assertions sa(vif);
  mailbox #(spi_transaction) gen2drv,drv2scb,mon2scb;
  spi_generator gen;
  spi_driver drv;
  spi_monitor mon;
  spi_scoreboard scb;
  spi_coverage cov;

  initial begin
    clk=0;
    gen2drv=new();
    drv2scb=new();
    mon2scb=new();
    cov=new();
    gen=new(gen2drv);
    drv=new(vif,gen2drv,drv2scb,cov);
    mon=new(vif,mon2scb);
    scb=new(drv2scb,mon2scb);

    vif.rst=1'b1;
    vif.start=1'b0;
    vif.master_data_in=8'h00;
    vif.slave_data_in=8'h00;
    vif.data_ready=1'b0;

    repeat(5) @(posedge clk);
    vif.rst=1'b0;

    fork
      gen.run();
      drv.run();
      mon.run();
      scb.run();
    join_none
    #500_000;

    scb.report();

    $display("========================================");
    $display("[TB] FINAL FUNCTIONAL COVERAGE = %0.2f%%",
             cov.get_cov());
    $display("========================================");

    $display("MASTER_TX = %0.2f%%",
             cov.spi_cg.MASTER_TX.get_coverage());

    $display("SLAVE_TX  = %0.2f%%",
             cov.spi_cg.SLAVE_TX.get_coverage());

    $display("CORNERS   = %0.2f%%",
             cov.spi_cg.CORNERS.get_coverage());

    $display("TX_CROSS  = %0.2f%%",
             cov.spi_cg.TX_CROSS.get_coverage());

    $display("[TB] Simulation complete");
    $finish;
  end

endmodule
