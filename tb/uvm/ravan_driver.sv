class ravan_driver extends uvm_driver #(ravan_item);
    `uvm_component_utils(ravan_driver)

    virtual ravan_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual ravan_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "Could not get interface")
    endfunction

    task run_phase(uvm_phase phase);
        // Initialize Signals
        vif.drv_cb.reg_cs <= 0;
        vif.drv_cb.reg_we <= 0;
        
        forever begin
            seq_item_port.get_next_item(req);
            drive_item(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_item(ravan_item item);
        @(vif.drv_cb);
        vif.drv_cb.reg_addr  <= item.addr;
        vif.drv_cb.reg_cs    <= 1;
        
        if (item.is_write) begin
            vif.drv_cb.reg_we    <= 1;
            vif.drv_cb.reg_wdata <= item.data;
            @(vif.drv_cb); // One cycle access
        end else begin
            vif.drv_cb.reg_we    <= 0;
            @(vif.drv_cb); // Wait for read data
            // In a real bus, you might wait for 'ready', but here it's 1-cycle latency
            item.data = vif.drv_cb.reg_rdata; 
        end
        
        vif.drv_cb.reg_cs <= 0;
        vif.drv_cb.reg_we <= 0;
        @(vif.drv_cb); // Idle cycle
    endtask
endclass