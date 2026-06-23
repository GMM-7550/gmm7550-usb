library ieee;
use ieee.std_logic_1164.all;

entity testctrl_e is
  port (
    clk48  : in  std_logic;
    reset  : in  std_logic;
    enable : out std_logic;
    bypass : out std_logic;
    di : out std_logic_vector(7 downto 0));
end entity testctrl_e;
