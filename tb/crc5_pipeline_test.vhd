configuration crc5_pipeline_test of crc5_tb is
  for sim
    for dut: crc5_gen
      use entity work.crc5_gen_e(pipeline)
        generic map (
          CONFIG_SKID_G => (0  => true, others => false),
          CONFIG_PIPE_G => (others => true));
    end for;
  end for;
end configuration;
