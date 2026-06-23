library ieee;
use ieee.std_logic_1164.all;

library std;

entity bs_nrzi_tx_tb is
end entity bs_nrzi_tx_tb;

architecture sim of bs_nrzi_tx_tb is
  constant clk_period : time := 20.83 ns;
  constant pdelay     : time := 1 ns;

  component testctrl is
    port (
      clk48  : in  std_logic;
      reset  : in  std_logic;
      enable : out std_logic;
      bypass : out std_logic;
      di : out std_logic_vector(7 downto 0));
  end component testctrl;

  signal clk48  : std_logic := '1';
  signal reset  : std_logic;
  signal clock  : integer := 0;

  signal enable : std_logic;
  signal bypass : std_logic;
  signal di     : std_logic_vector(7 downto 0);
  signal ready  : std_logic;
  signal tx_dp  : std_logic;
  signal tx_dn  : std_logic;
  signal tx_en  : std_logic;
begin

  clk48 <= not clk48 after clk_period / 2;

  reset_p: process
  begin
    reset <= '1';
    wait until rising_edge(clk48);
    wait until rising_edge(clk48);
    reset <= '0' after pdelay;
    wait;
  end process;

  clk_cnt_p: process (clk48)
  begin
    if rising_edge(clk48) then
      if reset = '1' then
        clock <= 0;
      else
        clock <= clock + 1 after pdelay;
      end if;
    end if;
  end process clk_cnt_p;

  testctrl_i: component testctrl
    port map (
      clk48 => clk48,
      reset => reset,
      enable => enable,
      bypass => bypass,
      di => di);

  dut: entity work.bs_nrzi_tx
    port map (
      clk48  => clk48,
      reset  => reset,
      enable => enable,
      bypass => bypass,
      ready  => ready,
      di     => di,
      tx_dp  => tx_dp,
      tx_dn  => tx_dn,
      tx_en  => tx_en
      );

end architecture sim;
