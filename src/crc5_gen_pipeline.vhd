architecture pipeline of crc5_gen_e is
  constant DATA_WIDTH_C : integer := 16;
  type ppl_data_t is array (0 to N_STAGES_G) of std_logic_vector(DATA_WIDTH_C-1 downto 0);

  signal ppl_data_i : ppl_data_t;
  signal ppl_data_o : ppl_data_t;
  signal ppl_valid  : std_logic_vector(0 to N_STAGES_G);
  signal ppl_ready  : std_logic_vector(0 to N_STAGES_G);
begin

  i_reg: entity work.generic_buffer
    generic map (
      DATA_WIDTH_G  => DATA_WIDTH_C,
      ENABLE_SKID_G => CONFIG_SKID_G(0),
      ENABLE_PIPE_G => CONFIG_PIPE_G(0))
    port map (
      clk => clk48,
      rst => reset,

      a_data  => "11111" & din,
      a_valid => din_valid,
      a_ready => din_ready,

      b_data  => ppl_data_o(0),
      b_valid => ppl_valid(0),
      b_ready => ppl_ready(0));

  ppl_g: for i in 1 to N_STAGES_G generate

    ppl_data_i(i-1) <= ppl_data_o(i-1);

    ppl_reg_i: entity work.generic_buffer
      generic map (
        DATA_WIDTH_G  => DATA_WIDTH_C,
        ENABLE_SKID_G => CONFIG_SKID_G(i),
        ENABLE_PIPE_G => CONFIG_PIPE_G(i))
      port map (
        clk => clk48,
        rst => reset,

        a_data  => ppl_data_i(i-1),
        a_valid => ppl_valid(i-1),
        a_ready => ppl_ready(i-1),

        b_data  => ppl_data_o(i),
        b_valid => ppl_valid(i),
        b_ready => ppl_ready(i));
  end generate;

  dout(15 downto 11) <= not ppl_data_o(N_STAGES_G)(15 downto 11);
  dout(10 downto  0) <=     ppl_data_o(N_STAGES_G)(10 downto  0);

  dout_valid <= ppl_valid(N_STAGES_G);
  ppl_ready(N_STAGES_G) <= dout_ready;

end architecture pipeline;
