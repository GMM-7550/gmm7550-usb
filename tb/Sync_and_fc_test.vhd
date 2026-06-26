architecture Sync_and_fc of testctrl_e is
  constant pdelay : time := 1 ns;
  signal clock : integer := 0;
begin

  clock_cnt_p: process (clk48)
  begin
    if rising_edge(clk48) then
      if (reset = '1') then
        clock <= 0;
      else
        clock <= clock + 1;
      end if;
    end if;
  end process;

  testctrl_p: process (clk48)
  begin
    if rising_edge(clk48) then
      if reset = '1' then
        enable <= '0';
        bypass <= '0';
        di <= (others => '0');
      else
        case clock is
          when 0 =>
            di <= x"fc" after pdelay;
            enable <= '1' after pdelay;
          when 35 =>
            enable <= '0' after pdelay;
          when 85 =>
            std.env.stop;
          when others => null;
        end case;
      end if;
    end if;
  end process testctrl_p;

end architecture Sync_and_fc;

configuration Sync_and_fc_test of bs_nrzi_tb is
    for sim
        for testctrl_i: testctrl
            use entity work.testctrl_e(Sync_and_fc);
        end for;
    end for;
end configuration Sync_and_fc_test;
