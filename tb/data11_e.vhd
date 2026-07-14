library ieee;
use ieee.std_logic_1164.all;

entity data11_e is
  generic (MAX_DATA : integer := 32);
  port (
    clk48 : in  std_logic;
    reset : in  std_logic;
    data  : out std_logic_vector(10 downto 0);
    valid : out std_logic;
    ready : in  std_logic);
end entity data11_e;
