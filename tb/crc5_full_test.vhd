library ieee;
use ieee.numeric_std.all;

architecture sim of data11_e is
begin
  din_p: process (clk48)
    variable cnt : integer;
  begin
    if rising_edge(clk48) then
      if reset = '1' then
        cnt := 0;
        valid <= '0';
      else
        if cnt = MAX_DATA then
          valid <= '0';
          std.env.stop;
        else
          valid <= '1';
          data <= std_logic_vector(to_unsigned(cnt, data'length));
          if ready = '1' then
            cnt := cnt + 1;
          end if;
        end if;
      end if;
    end if;
  end process din_p;
end architecture sim;

configuration crc5_full_test of crc5_tb is
  for sim
    for testctrl_i: data11
      use entity work.data11_e(sim)
        generic map (MAX_DATA => 2048);
    end for;
  end for;
end configuration;

configuration crc5_short_test of crc5_tb is
  for sim
    for testctrl_i: data11
      use entity work.data11_e(sim)
        generic map (MAX_DATA => 32);
    end for;
  end for;
end configuration;
