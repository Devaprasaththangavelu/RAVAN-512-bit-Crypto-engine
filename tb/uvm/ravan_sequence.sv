class test_sanity_seq extends uvm_sequence;
    `uvm_object_utils(test_sanity_seq)
    ravan_item item;

    function new(string name = "test_sanity_seq");
        super.new(name);
    endfunction

    task body();
        bit [63:0] captured_result;

        `uvm_info("SEQ", "Starting 64-bit Sanity Sequence...", UVM_LOW)

        // 1. Write Key (8 writes of 64-bits = 512 bits)
        // Address 0x00 to 0x07
        for (int i=0; i<8; i++) begin
            `uvm_do_with(item, { addr == i; is_write == 1; data == 64'h11112222_33334444; })
        end

        // 2. Write Target Address (Address 0x08)
        // Even address (ends in 0) = Encrypt Mode (based on your interconnect logic)
        `uvm_do_with(item, { addr == 6'h08; is_write == 1; data == 64'h00000000_00001230; })
        
        `uvm_info("SEQ", "Key and Address Loaded. Waiting for Pipeline...", UVM_LOW)

        // 3. Wait for processing (Latency simulation)
        #5000ns; 

        // 4. Read Result (Address 0x10)
        // The result is now a SINGLE 64-bit read.
        `uvm_do_with(item, { addr == 6'h10; is_write == 0; })
        captured_result = item.data;

        `uvm_info("SEQ", $sformatf("FINAL RESULT: %h", captured_result), UVM_LOW)

        if (captured_result !== 0) 
            `uvm_info("SEQ", "PASS: Result detected.", UVM_LOW)
        else
            `uvm_error("SEQ", "FAIL: Result is Zero or Unknown!")

    endtask
endclass