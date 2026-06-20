library ieee;
use ieee.std_logic_1164.all;

entity ddff_tb is
end entity ddff_tb;

architecture sim of ddff_tb is
  signal clk : std_logic := '1';
  signal i : std_logic;
  signal o : std_logic;
begin

  clk <= not clk after 5 ns;

  input_p: process
  begin
    i <= '0';
    wait for 7 ns;
    i <= not i;
    wait for 7 ns;
    i <= not i;
    for iter in 1 to 20 loop
      wait for 15 ns ;
      i <= not i;
    end loop;
    wait;
  end process input_p;

  dut: entity work.ddff
    port map (
      clk => clk,
      i => i,
      o => o);

end architecture sim;
