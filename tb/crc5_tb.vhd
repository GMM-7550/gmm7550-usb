library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity crc5_tb is begin
end entity crc5_tb;

architecture sim of crc5_tb is
  constant clk_period : time := 20.83 ns;
  constant pdelay     : time := 1 ns;

  component data11 is
    generic (MAX_DATA : integer := 32);
    port (
      clk48 : in  std_logic;
      reset : in  std_logic;
      data  : out std_logic_vector(10 downto 0);
      valid : out std_logic;
      ready : in  std_logic);
  end component data11;

  signal clk48 : std_logic := '1';
  signal reset : std_logic := '1';
  signal din   : std_logic_vector(10 downto 0);
  signal dout  : std_logic_vector(15 downto 0);

  signal i_valid : std_logic;
  signal i_ready : std_logic;
  signal o_valid : std_logic;
  signal o_ready : std_logic;
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

  o_ready <= not reset after pdelay;

  testctrl_i: component data11
    port map (
      clk48 => clk48,
      reset => reset,
      data  => din,
      valid => i_valid,
      ready => i_ready);

  dut: entity work.crc5_gen
    port map (
      clk48      => clk48,
      reset      => reset,

      din        => din,
      din_valid  => i_valid,
      din_ready  => i_ready,

      dout       => dout,
      dout_valid => o_valid,
      dout_ready => o_ready);

  print_p: process (clk48) is
  begin
    if rising_edge(clk48) then
      report to_hstring(dout);
    end if;
  end process;

end architecture sim;
