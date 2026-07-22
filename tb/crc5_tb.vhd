library ieee;
use ieee.std_logic_1164.all;

library osvvm;
context osvvm.OsvvmContext;
use osvvm.ScoreboardPkg_slv.all;

library osvvm_AXI4;
context osvvm_AXI4.AxiStreamContext;

use std.textio.all;

entity crc5_tb is
  generic (
    CRC5_FILENAME: string  := "./sim/crc5.txt";
    INSERT_ERROR : boolean := false;
    USE_RANDOM   : boolean := true;
    DEBUG_PRINT  : boolean := false);
begin
end entity crc5_tb;

architecture sim of crc5_tb is
  constant clk_period : time := 20.83 ns;
  constant pdelay     : time := 1 ns;

  component crc5_gen is
    port (
      clk48      : in  std_logic;
      reset      : in  std_logic;
      din        : in  std_logic_vector(10 downto 0);
      din_valid  : in  std_logic;
      din_ready  : out std_logic;
      dout       : out std_logic_vector(15 downto 0);
      dout_valid : out std_logic;
      dout_ready : in  std_logic);
  end component crc5_gen;

  signal StreamTxRec, StreamRxRec : StreamRecType(
      DataToModel   (10 downto 0),
      DataFromModel (15 downto 0),
      ParamToModel  (3 downto 0),
      ParamFromModel(3 downto 0)
    );

  signal SB : ScoreBoardIDType;

  signal stop_rx : boolean := false;

  signal clk48 : std_logic := '1';
  signal reset : std_logic := '1';
  signal din   : std_logic_vector(10 downto 0);
  signal dout  : std_logic_vector(15 downto 0);

  signal i_valid : std_logic;
  signal i_ready : std_logic;
  signal o_valid : std_logic;
  signal o_ready : std_logic;

  -- Unused AXI Stream signals
  signal id, dest, user, keep, strb : std_logic_vector(0 downto 0);
  signal last : std_logic;

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

  din_p: process
    file crc5_values : text;
    variable iline   : line;
    variable crc     : std_logic_vector(15 downto 0);
  begin
    SetUseRandomDelays(StreamTxRec, USE_RANDOM);
    file_open(crc5_values, CRC5_FILENAME, read_mode);
    SetAlertLogName("CRC5_Test");
    SB <= NewID("CRC5_SB");

    wait until reset = '0';
    WaitForClock(StreamTxRec, 2);

    while not endfile(crc5_values) loop
          readline(crc5_values, iline);
          hread(iline, crc);
          Push(SB, crc);
          Send(StreamTxRec, crc(10 downto 0));
    end loop;

    WaitForClock(StreamTxRec, 25); -- > 2 * max. latency (11 clocks)
    stop_rx <= true;
    WaitForClock(StreamTxRec, 5);
    ReportAlerts;
    std.env.stop(GetAlertCount);
  end process din_p;

  dout_p: process
    variable crc : std_logic_vector(15 downto 0);
  begin
    SetUseRandomDelays(StreamRxRec, USE_RANDOM);
    while not stop_rx loop
      Get(StreamRxRec, crc);

      if INSERT_ERROR then
        if crc = x"2f10" then
          crc := x"2e10";
        end if;
      end if;

      Check(SB, crc);
    end loop;
  end process dout_p;

  tx_i: AxiStreamTransmitter
    generic map (
      tperiod_Clk    => clk_period
      )
    port map (
      Clk       => clk48,
      nReset    => reset,

      TData     => din,
      TValid    => i_valid,
      TReady    => i_ready,

      TID       => id,
      TDest     => dest,
      TUser     => user,
      TStrb     => strb,
      TKeep     => keep,
      TLast     => last,

      TransRec  => StreamTxRec
      );

  rx_i: AxiStreamReceiver
    generic map (
      tperiod_Clk    => clk_period
      )
    port map (
      Clk       => clk48,
      nReset    => reset,

      TData     => dout,
      TValid    => o_valid,
      TReady    => o_ready,

      TID       => id,
      TDest     => dest,
      TUser     => user,
      TStrb     => strb,
      TKeep     => keep,
      TLast     => last,

      TransRec  => StreamRxRec
      );

  dut: component crc5_gen
    port map (
      clk48      => clk48,
      reset      => reset,

      din        => din,
      din_valid  => i_valid,
      din_ready  => i_ready,

      dout       => dout,
      dout_valid => o_valid,
      dout_ready => o_ready);

  dbg_print: if DEBUG_PRINT generate
    print_p: process (clk48) is
    begin
      if rising_edge(clk48) then
        if o_valid = '1' then
          report to_hstring(dout);
        end if;
      end if;
    end process;
  end generate;

end architecture sim;
