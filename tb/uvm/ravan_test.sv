class ravan_test extends uvm_test;
    `uvm_component_utils(ravan_test)
    ravan_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = ravan_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        test_sanity_seq seq;
        phase.raise_objection(this);
        seq = test_sanity_seq::type_id::create("seq");
        seq.start(env.sqr);
        phase.drop_objection(this);
    endtask
endclass