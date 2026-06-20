library ieee;
use ieee.std_logic_1164.all;

entity ddff is
  port (
    clk : in  std_logic;
    i   : in  std_logic;
    o   : out std_logic);
end entity ddff;

architecture rtl of ddff is
  signal d1, d2 : std_logic;
begin
  double_ff_p: process(clk) is
  begin
    if rising_edge(clk) then
      d1 <= i;
      d2 <= d1;
    end if;
  end process double_ff_p;

  o <= d2;
end architecture rtl;
