class ravan_monitor extends uvm_monitor;
    `uvm_component_utils(ravan_monitor)

    virtual ravan_if vif;
    uvm_analysis_port #(ravan_item) mon_ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        mon_ap = new("mon_ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual ravan_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "Could not get interface")
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            @(vif.mon_cb);
            if (vif.mon_cb.reg_cs) begin
                ravan_item item = ravan_item::type_id::create("item");
                item.addr = vif.mon_cb.reg_addr;
                item.is_write = vif.mon_cb.reg_we;
                
                if (item.is_write)
                    item.data = vif.mon_cb.reg_wdata;
                else
                    item.data = vif.mon_cb.reg_rdata;

                mon_ap.write(item);
            end
        end
    endtask
endclass