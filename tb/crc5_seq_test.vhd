configuration crc5_seq_test of crc5_tb is
  for sim
    for dut: crc5_gen
      use entity work.crc5_gen_e(sequential);
    end for;
  end for;
end configuration;
