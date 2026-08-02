library ieee;
use ieee.std_logic_1164.all;

library cc;
use cc.gatemate.all;

entity fs_io is
  port (
    clk48 : in  std_logic;
    reset : in  std_logic;

    -- Internal signals to/from USB SIE
    tx_en   : in  std_logic;
    tx_dp   : in  std_logic;
    tx_dn   : in  std_logic;

    rxd     : out std_logic;
    rx_dp   : out std_logic;
    rx_dn   : out std_logic;

    connect : in  std_logic;
    suspend : in  std_logic;
    busdet  : out std_logic;

    -- I/O to ST micro STUSB03E transceiver
    fs_rcv  : in    std_logic;
    fs_dp   : inout std_logic;
    fs_dm   : inout std_logic;
    fs_oen  : out   std_logic;
    fs_con  : out   std_logic;
    fs_sus  : out   std_logic;
    fs_bdet : in    std_logic
    );
end entity fs_io;

architecture rtl of fs_io is
  signal tx_en_d : std_logic;
  signal fs_t    : std_logic;
  signal dp_i    : std_logic;
  signal dn_i    : std_logic;
begin

  bd_sync: entity work.ddff
    port map (
      clk => clk48,
      i => fs_bdet,
      o => busdet
    );

  rxd_sync: entity work.ddff
    port map (
      clk => clk48,
      i => fs_rcv,
      o => rxd
    );

  dp_sync: entity work.ddff
    port map (
      clk => clk48,
      i => dp_i,
      o => rx_dp
    );

  dn_sync: entity work.ddff
    port map (
      clk => clk48,
      i => dn_i,
      o => rx_dn
    );

  dp_drv_i: component CC_IOBUF
    port map (
      A => tx_dp,
      T => fs_t,
      Y => dp_i,
      IO => fs_dp
      );

  dm_drv_i: component CC_IOBUF
    port map (
      A => tx_dn,
      T => fs_t,
      Y => dn_i,
      IO => fs_dm
      );

  tx_en_p: process(clk48) is
  begin
    if rising_edge(clk48) then
      if reset = '1' then
        tx_en_d <= '0';
      else
        tx_en_d <= tx_en;
      end if;
    end if;
  end process tx_en_p;

  fs_oen <= not (tx_en or  tx_en_d);
  fs_t   <= not (tx_en and tx_en_d);

  con_p: process(clk48) is
  begin
    if rising_edge(clk48) then
      if reset = '1' then
        fs_con <= '0';
      else
        fs_con <= connect;
      end if;
    end if;
  end process con_p;

  sus_p: process(clk48) is
  begin
    if rising_edge(clk48) then
      if reset = '1' then
        fs_sus <= '1';
      else
        fs_sus <= suspend;
      end if;
    end if;
  end process sus_p;

end architecture rtl;
