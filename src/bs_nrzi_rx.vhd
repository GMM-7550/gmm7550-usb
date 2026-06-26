library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bs_nrzi_rx is
  port (
    clk48  : in  std_logic;
    reset  : in  std_logic;
    -- enable : in  std_logic;

    rxd    : in  std_logic;
    rx_dp  : in  std_logic;
    rx_dn  : in  std_logic;

    do     : out std_logic_vector(7 downto 0);
    valid  : out std_logic;
    active : out std_logic;
    rx_err : out std_logic;
    bs_err : out std_logic;
    fr_err : out std_logic);
end entity bs_nrzi_rx;

architecture rtl of bs_nrzi_rx is
  type rx_fsm_t is (IDLE_ST, SYNC_ST, ACTIVE_ST,
                    ERR_SYNC_ST, ERR_TIME_ST, ERR_BS_ST, ERR_FRAME_ST,
                    EOP_ST);
  signal rx_fsm_state : rx_fsm_t;
  signal rx_fsm_next  : rx_fsm_t;

  signal se0     : std_logic;
  signal se0d    : std_logic;
  signal rxdd    : std_logic;
  signal rx_edge : std_logic;

  signal cdr     : std_logic_vector(2 downto 0);
  signal data    : std_logic;
  signal bit_err : std_logic;
  signal bit_stb : std_logic;

  signal byte_mark : std_logic;

  signal bit_cnt : std_logic_vector(2 downto 0);
  signal bit_cnt_inc : std_logic;
  signal bit_cnt_clr : std_logic;

  signal one_cnt : std_logic_vector(2 downto 0);
  signal one_cnt_inc : std_logic;
  signal one_cnt_clr : std_logic;

  signal s_reg : std_logic_vector(7 downto 0);
  signal s_reg_shift : std_logic;

begin

  se0 <= '1' when rx_dp = '0' and rx_dn = '0' else '0';

  se0d_p: process (clk48)
  begin
    if rising_edge(clk48) then
      se0d <= se0;
    end if;
  end process se0d_p;

  rxdd_p: process (clk48)
  begin
    if rising_edge(clk48) then
      rxdd <= rxd;
    end if;
  end process rxdd_p;

  rx_edge <= '1' when (rxd = '0' and rxdd = '1') or (rxd = '1' and rxdd = '0') else '0';

  cdr_p: process (clk48)
  begin
    bit_stb <= '0';
    bit_err <= '0';

    if rising_edge(clk48) then
      if reset = '1' then
        cdr  <= "000";
        data <= '0';
      else
        case cdr is

          when "000" =>
            if rx_edge then
              cdr <= "001";
              data <= '0';
              bit_stb <= '1';
            else
              cdr <= "000";
              bit_stb <= '0';
            end if;

          when "001" =>
            if rx_edge then
              cdr <= "000";
              bit_err <= '1';
            else
              cdr <= "010";
            end if;

          when "010" =>
            if rx_edge then
              cdr <= "000";
              bit_err <= '1';
            else
              cdr <= "011";
            end if;

          when "011" =>
            if rx_edge then
              data <= '0';
              cdr <= "001";
              if not (se0 or se0d) then
                bit_stb <= '1';
              end if;
            else
              cdr <= "100";
            end if;

          when "100" =>
            if rx_edge then
              data <= '0';
              cdr <= "001";
              if not (se0 or se0d) then
                bit_stb <= '1';
              end if;
            else
              cdr <= "101";
            end if;

          when "101" =>
            if rx_edge then
              data <= '0';
              cdr <= "001";
              if not (se0 or se0d) then
                bit_stb <= '1';
              end if;
            else
              data <= '1';
              cdr <= "010";
              if not (se0 or se0d) then
                bit_stb <= '1';
              end if;
            end if;

          when others =>
            cdr <= "000";
        end case;
      end if;
    end if;

  end process cdr_p;

  bit_cnt_p: process (clk48)
  begin
    if rising_edge(clk48) then
      if reset = '1' or bit_cnt_clr = '1' then
        bit_cnt <= "000";
      elsif bit_cnt_inc = '1' then
        bit_cnt <= std_logic_vector(unsigned(bit_cnt) + 1);
      end if;
    end if;
  end process bit_cnt_p;

  one_cnt_p: process (clk48)
  begin
    if rising_edge(clk48) then
      if reset = '1' or one_cnt_clr = '1' then
        one_cnt <= "000";
      elsif one_cnt_inc = '1' then
        one_cnt <= std_logic_vector(unsigned(one_cnt) + 1);
      end if;
    end if;
  end process one_cnt_p;

  rx_fsm_state_p: process (clk48, reset)
  begin
    if reset = '1' then
      rx_fsm_state <= IDLE_ST;
    elsif rising_edge(clk48) then
      rx_fsm_state <= rx_fsm_next;
    end if;
  end process rx_fsm_state_p;

  rx_fsm_p: process (all)
  begin
    rx_fsm_next <= IDLE_ST;

    case rx_fsm_state is

      when IDLE_ST =>
        if rx_edge = '1' then
          rx_fsm_next <= SYNC_ST;
        end if;

      when SYNC_ST =>
        if rx_edge = '1' then
          if bit_cnt = "001" or bit_cnt = "010" then
            rx_fsm_next <= ERR_TIME_ST;
          end if;
        else
          null;
        end if;

      when others => null;
    end case;
  end process rx_fsm_p;

  do <= s_reg;

  -- valid  <= '0';
  -- active <= '0';
  -- bs_err <= '0';
  -- fr_err <= '0';

end architecture rtl;
