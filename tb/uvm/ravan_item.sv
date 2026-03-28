import uvm_pkg::*;
`include "uvm_macros.svh"

class ravan_item extends uvm_sequence_item;
    
    rand bit [5:0]  addr;
    rand bit [63:0] data; // UPDATED to 64-bit
    rand bit        is_write;

    `uvm_object_utils_begin(ravan_item)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_int(is_write, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "ravan_item");
        super.new(name);
    endfunction
    
endclass