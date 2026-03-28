class ravan_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ravan_scoreboard)

    uvm_analysis_imp #(ravan_item, ravan_scoreboard) m_imp;

    // Associative array to store results for specific inputs
    // Key: 32-bit Address (which dictates mode Enc/Dec + Input Data variation)
    // Value: 64-bit Result
    bit [63:0] ref_results [int];

    function new(string name, uvm_component parent);
        super.new(name, parent);
        m_imp = new("m_imp", this);
    endfunction

    function void write(ravan_item item);
        // We only score Read transactions from the Result Registers
        if (!item.is_write) begin
            if (item.addr == 6'h20) begin
                `uvm_info("SCB", $sformatf("Captured Result Lower: %h", item.data), UVM_HIGH)
            end
            if (item.addr == 6'h21) begin
                `uvm_info("SCB", $sformatf("Captured Result Upper: %h", item.data), UVM_HIGH)
            end
        end
    endfunction
endclass