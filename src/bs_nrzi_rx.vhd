library ieee;
use ieee.std_logic_1164.all;

entity bs_nrzi_rx is
  port (
    clk48  : in  std_logic;
    reset  : in  std_logic;
    enable : in  std_logic;

    rxd    : in  std_logic;
    rx_dp  : in  std_logic;
    rx_dn  : in  std_logic;

    do     : out std_logic_vector(7 downto 0);
    valid  : out std_logic;
    active : out std_logic;
    bs_err : out std_logic;
    fr_err : out std_logic);
end entity bs_nrzi_rx;

architecture rtl of bs_nrzi_rx is
  signal se0 : std_logic;
begin

  se0 <= '1' when rx_dp = '0' and rx_dn = '0' else '0';

  -- do <= (others => '0');
  -- valid  <= '0';
  -- active <= '0';
  -- bs_err <= '0';
  -- fr_err <= '0';

end architecture rtl;
