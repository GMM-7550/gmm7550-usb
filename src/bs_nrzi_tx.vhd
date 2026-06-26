library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bs_nrzi_tx is
  port (
    clk48  : in  std_logic;
    reset  : in  std_logic;
    enable : in  std_logic;
    bypass : in  std_logic;
    di     : in  std_logic_vector(7 downto 0);
    ready  : out std_logic;
    tx_dp  : out std_logic;
    tx_dn  : out std_logic;
    tx_en  : out std_logic);
end entity bs_nrzi_tx;

architecture rtl of bs_nrzi_tx is
  type tx_fsm_t is (IDLE_ST, SYNC_ST, ACTIVE_ST, ACTIVE_EXIT_ST,
                    EOP_SE0_1_ST, EOP_SE0_2_ST, EOP_J_ST);
  signal tx_fsm_state : tx_fsm_t;
  signal tx_fsm_next  : tx_fsm_t;

  signal s_reg    : std_logic_vector(7 downto 0);
  signal s_load   : std_logic;
  signal s_shift  : std_logic;

  signal clk_cnt  : std_logic_vector(1 downto 0);
  signal bit_mark : std_logic;
  signal byte_mark: std_logic;

  signal bit_cnt  : std_logic_vector(2 downto 0);
  signal bit_cnt_clr : std_logic;
  signal bit_cnt_inc : std_logic;

  signal one_cnt  : std_logic_vector(2 downto 0);
  signal one_cnt_clr : std_logic;
  signal one_cnt_inc : std_logic;

  signal stuff0   : std_logic;
  signal txd      : std_logic;
  signal se0      : std_logic;
  signal force_J  : std_logic;
begin

  bit_mark_p: process(clk48)
  begin
    if rising_edge(clk48) then
      if reset = '1' or tx_en = '0' then
        clk_cnt <= "00";
        bit_mark <= '0';
      else
        case clk_cnt is
          when "00" => clk_cnt <= "01";
                       bit_mark <= '1';
          when "01" => clk_cnt <= "11";
                       bit_mark <= '0';
          when "11" => clk_cnt <= "10";
                       bit_mark <= '0';
          when "10" => clk_cnt <= "00";
                       bit_mark <= '0';
          when others => null;
        end case;
      end if;
    end if;
  end process bit_mark_p;

  s_reg_p: process (clk48)
  begin
    if rising_edge(clk48) then
      if tx_en = '0' then
        s_reg <= x"80"; -- SYNC pattern
      else
        if s_load = '1' then
          s_reg <= di;
        elsif s_shift = '1' then
          s_reg(6 downto 0) <= s_reg(7 downto 1);
        end if;
      end if;
    end if;
  end process s_reg_p;

  bit_cnt_p: process (clk48)
  begin
    if rising_edge(clk48) then
      if bit_cnt_clr = '1' then
        bit_cnt <= (others => '0');
      elsif bit_cnt_inc = '1' then
        bit_cnt <= std_logic_vector(unsigned(bit_cnt) + 1);
      end if;
    end if;
  end process bit_cnt_p;

  one_cnt_p: process (clk48)
  begin
    if rising_edge(clk48) then
      if one_cnt_clr = '1' then
        one_cnt <= (others => '0');
      elsif one_cnt_inc = '1' then
        one_cnt <= std_logic_vector(unsigned(one_cnt) + 1);
      end if;
    end if;
  end process one_cnt_p;

  tx_p: process (txd, se0, tx_en)
  begin
    if tx_en = '0' then
      tx_dp <= '1';
      tx_dn <= '0';
    else
      if se0 = '1' then
        tx_dp <= '0';
        tx_dn <= '0';
      elsif force_J = '1' then
        tx_dp <= '1';
        tx_dn <= '0';
      else
        if bypass = '0' then
          tx_dp <= txd;
          tx_dn <= not txd;
        else
          tx_dp <= s_reg(0);
          tx_dn <= not s_reg(0);
        end if;
      end if;
    end if;
  end process tx_p;

  txd_p : process (clk48)
  begin
    if rising_edge (clk48) then
      if reset = '1' or tx_en = '0' then
        txd <= '1';
      elsif bit_mark = '1' and (s_reg(0) = '0' or stuff0 = '1') then
        txd <= not txd;
      end if;
    end if;
  end process txd_p;

  tx_state_p: process (clk48, reset)
  begin
    if reset = '1' then
      tx_fsm_state <= IDLE_ST;
    elsif rising_edge(clk48) then
      tx_fsm_state <= tx_fsm_next;
    end if;
  end process tx_state_p;

  tx_fsm_p: process (all)
  begin
    tx_fsm_next <= IDLE_ST;

    tx_en   <= '1';
    se0     <= '0';
    force_J <= '0';

    s_shift <= '0';
    s_load  <= '0';

    bit_cnt_clr <= '0';

    case tx_fsm_state is
      when IDLE_ST =>
        tx_en <= '0';
        bit_cnt_clr <= '1';
        if enable = '1' then
          tx_fsm_next <= SYNC_ST;
        else
          tx_fsm_next <= IDLE_ST;
        end if;

      when SYNC_ST =>
        s_shift <= bit_mark;
        if byte_mark = '1' then
          if enable = '1' then
            s_load <= '1';
            tx_fsm_next <= ACTIVE_ST;
          else
            tx_fsm_next <= ACTIVE_EXIT_ST;
          end if;
        else
          tx_fsm_next <= SYNC_ST;
        end if;

      when ACTIVE_ST =>
        s_shift <= bit_mark and not stuff0;
        if byte_mark = '1' then
          if enable = '1' then
            s_load <= '1';
            tx_fsm_next <= ACTIVE_ST;
          else
            tx_fsm_next <= ACTIVE_EXIT_ST;
          end if;
        else
          tx_fsm_next <= ACTIVE_ST;
        end if;

      when ACTIVE_EXIT_ST =>
        if bit_mark = '1' and stuff0 = '0' then
          tx_fsm_next <= EOP_SE0_1_ST;
        else
          tx_fsm_next <= ACTIVE_EXIT_ST;
        end if;

      when EOP_SE0_1_ST =>
        se0 <= '1';
        if bit_mark = '1' then
          tx_fsm_next <= EOP_SE0_2_ST;
        else
          tx_fsm_next <= EOP_SE0_1_ST;
        end if;

      when EOP_SE0_2_ST =>
        se0 <= '1';
        if bit_mark = '1' then
          tx_fsm_next <= EOP_J_ST;
        else
          tx_fsm_next <= EOP_SE0_2_ST;
        end if;

      when EOP_J_ST =>
        force_J <= '1';
        if bit_mark = '1' then
          tx_fsm_next <= IDLE_ST;
        else
          tx_fsm_next <= EOP_J_ST;
        end if;

      when others => null;
    end case;
  end process tx_fsm_p;

  byte_mark <= '1' when bit_mark = '1' and bit_cnt = "111" and stuff0 = '0' else '0';

  bit_cnt_inc <= '1' when bit_mark = '1' and (tx_fsm_state = SYNC_ST or tx_fsm_state = ACTIVE_ST)
                          and stuff0 = '0'
                     else '0';

  one_cnt_inc <= '1' when bit_cnt_inc = '1' and s_reg(0) = '1' else '0';
  one_cnt_clr <= '1' when tx_en = '0' or (bit_mark = '1' and (s_reg(0) = '0'  or stuff0 = '1')) else '0';

  ready  <= s_load;

  stuff0 <= '1' when tx_en = '1'  and one_cnt = "110" and bit_mark = '1' and bypass = '0' else '0';

end architecture rtl;
