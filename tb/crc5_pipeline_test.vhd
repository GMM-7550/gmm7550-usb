-- Fully combinatorial, no registers
configuration crc5_pipeline_comb_test of crc5_tb is
  for sim
    for dut: crc5_gen
      use entity work.crc5_gen_e(pipeline)
        generic map (
          CONFIG_SKID_G => (others => false),
          CONFIG_PIPE_G => (others => false));
    end for;
  end for;
end configuration;

-- Main configuration: fully combinatorial,
-- skid buffer at the input and register at the output (1 cycle latency)
configuration crc5_pipeline_main_test of crc5_tb is
  for sim
    for dut: crc5_gen
      use entity work.crc5_gen_e(pipeline)
        generic map (
          CONFIG_SKID_G => ( 0 => true, others => false),
          CONFIG_PIPE_G => (11 => true, others => false));
    end for;
  end for;
end configuration;

-- Fully pipelined, 11 cycles latency, skid buffer at input
configuration crc5_pipeline_11_test of crc5_tb is
  for sim
    for dut: crc5_gen
      use entity work.crc5_gen_e(pipeline)
        generic map (
          CONFIG_SKID_G => (0 => true,  others => false),
          CONFIG_PIPE_G => (0 => false, others => true));
    end for;
  end for;
end configuration;

-- Fully registered: skid and pipeline register at every stage,
-- only for test
configuration crc5_pipeline_all_test of crc5_tb is
  for sim
    for dut: crc5_gen
      use entity work.crc5_gen_e(pipeline)
        generic map (
          CONFIG_SKID_G => (others => true),
          CONFIG_PIPE_G => (others => true));
    end for;
  end for;
end configuration;
