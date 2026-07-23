library ieee;
use ieee.std_logic_1164.all;

library osvvm;
context osvvm.OsvvmContext;

entity crc16_tb is begin
end entity crc16_tb;

architecture sim of crc16_tb is
  constant clk_period : time := 20.83 ns;
  constant pdelay     : time := 1 ns;

  signal clk48 : std_logic := '1';
  signal reset : std_logic := '1';

  signal init  : std_logic := '1';

  signal din   : std_logic_vector( 7 downto 0);
  signal dout  : std_logic_vector(15 downto 0);

  signal din_valid : std_logic;

begin

  Osvvm.ClockResetPkg.CreateClock (
    Clk        => clk48,
    Period     => clk_period
    );

  Osvvm.ClockResetPkg.CreateReset (
    Reset       => reset,
    ResetActive => '1',
    Clk         => clk48,
    Period      => 2 * clk_period,
    tpd         => pdelay
    );

  main_p: process
  begin
    din_valid <= '0';
    init <= '1';
    wait until reset = '0';
    WaitForClock(clk48, 2);

    init <= '0';
    WaitForClock(clk48, 1);

    din_valid <= '1';

    din <= x"00";
    WaitForClock(clk48, 1);
    din <= x"01";
    WaitForClock(clk48, 1);
    din <= x"02";
    WaitForClock(clk48, 1);
    din <= x"03";
    WaitForClock(clk48, 1);
    din_valid <= '0';

    WaitForClock(clk48, 1);
    assert dout = x"7aef" report "CRC 16 mismatch: expected 7AEF received: " & to_hstring(dout) severity error;

    WaitForClock(clk48, 3);
    din <= (others => 'X');
    init <= '1';
    WaitForClock(clk48, 1);
    init <= '0';

    WaitForClock(clk48, 4);
    din <= x"23";
    din_valid <= '1';
    WaitForClock(clk48, 1);
    din <= (others => 'X');
    din_valid <= '0';

    WaitForClock(clk48, 1);
    din <= x"45";
    din_valid <= '1';
    WaitForClock(clk48, 1);
    din <= (others => 'X');
    din_valid <= '0';

    WaitForClock(clk48, 3);
    din <= x"67";
    din_valid <= '1';
    WaitForClock(clk48, 1);
    din <= (others => 'X');
    din_valid <= '0';

    WaitForClock(clk48, 7);
    din <= x"89";
    din_valid <= '1';
    WaitForClock(clk48, 1);
    din <= (others => 'X');
    din_valid <= '0';

    WaitForClock(clk48, 1);
    assert dout = x"1c0e" report "CRC 16 mismatch: expected 1C0E received: " & to_hstring(dout) severity error;

    WaitForClock(clk48, 2);

    std.env.stop(GetAlertCount);
  end process main_p;

  dut: entity work.crc16_gen
    port map (
      clk48      => clk48,
      init       => init,

      din        => din,
      din_valid  => din_valid,

      dout       => dout);

end architecture sim;

configuration crc16_test of crc16_tb is
  for sim
--    for dut: crc5_gen
--      use entity work.crc5_gen_e(sequential);
--    end for;
  end for;
end configuration;
