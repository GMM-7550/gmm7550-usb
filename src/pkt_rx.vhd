library ieee;
use ieee.std_logic_1164.all;

entity pkt_rx is
  port (
    clk48  : in  std_logic;
    reset  : in  std_logic;

    data   : in  std_logic_vector(7 downto 0);
    valid  : in  std_logic;
    active : in  std_logic;
    rx_err : in  std_logic;

    tkn_sof   : out std_logic;
    tkn_in    : out std_logic;
    tkn_out   : out std_logic;
    tkn_setup : out std_logic;

    tkn_d0    : out std_logic;
    tkn_d1    : out std_logic;

    tkn_ack   : out std_logic;
    tkn_nak   : out std_logic;

    frame_num : out std_logic_vector(10 downto 0);
    rx_addr   : out std_logic_vector(6 downto 0);
    rx_endp   : out std_logic_vector(3 downto 0);

    pkt_err   : out std_logic);
end entity pkt_rx;

architecture rtl of pkt_rx is
  -- type pkt_fsm_t is (IDLE_ST, SYNC_ST);
  -- signal pkt_state : pkt_fsm_t;
  -- signal pkt_next  : pkt_fsm_t;
begin

  frame_num <= (others => '0');
  rx_addr   <= (others => '0');
  rx_endp   <= (others => '0');

  tkn_sof <= '0';
  tkn_in  <= '0';
  tkn_out <= '0';
  tkn_setup <= '0';
  tkn_d0  <= '0';
  tkn_d1  <= '0';
  tkn_ack <= '0';
  tkn_nak <= '0';

  pkt_err <= '0';

end architecture rtl;
