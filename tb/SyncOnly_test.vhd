architecture SyncOnly of testctrl_e is
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
            enable <= '1' after pdelay;
          when 20 =>
            enable <= '0' after pdelay;
          when 55 =>
            std.env.stop;
          when others => null;
        end case;
      end if;
    end if;
  end process testctrl_p;

end architecture SyncOnly;

configuration SyncOnly_test of bs_nrzi_tx_tb is
    for sim
        for testctrl_i: testctrl
            use entity work.testctrl_e(SyncOnly);
        end for;
    end for;
end configuration SyncOnly_test;
