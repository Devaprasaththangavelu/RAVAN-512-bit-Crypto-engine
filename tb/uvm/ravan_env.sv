class ravan_env extends uvm_env;
    `uvm_component_utils(ravan_env)
    
    ravan_driver    drv;
    ravan_monitor   mon;
    ravan_scoreboard scb;
    uvm_sequencer #(ravan_item) sqr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        drv = ravan_driver::type_id::create("drv", this);
        mon = ravan_monitor::type_id::create("mon", this);
        scb = ravan_scoreboard::type_id::create("scb", this);
        sqr = uvm_sequencer#(ravan_item)::type_id::create("sqr", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
        mon.mon_ap.connect(scb.m_imp);
    endfunction
endclass