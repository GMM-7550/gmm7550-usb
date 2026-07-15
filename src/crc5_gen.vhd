library ieee;
-- use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

architecture sequential of crc5_gen_e is
  type crc_fsm_t is (IDLE_ST, WAIT_ST, CNT_ST, RESULT_ST);
  signal crc_state : crc_fsm_t;
  signal crc_next  : crc_fsm_t;
  signal crc : std_logic_vector(4 downto 0);
  signal crc_data   : std_logic_vector(4 downto 0);
  signal crc_update : std_logic;
  signal cnt : std_logic_vector(3 downto 0);
  signal cnt_clr : std_logic;
  signal cnt_inc : std_logic;
  signal di   : std_logic_vector(10 downto 0);
  signal data : std_logic_vector(10 downto 0);
  signal d_shift : std_logic;
  signal d_load  : std_logic;
begin

  d_reg_p: process(clk48) is
  begin
    if rising_edge(clk48) then
      if reset = '1' then
        di <= (others => '0');
        data <= (others => '0');
      elsif d_load = '1' then
        di <= din;
        data <= din;
      elsif d_shift = '1' then
        data <= '0' & data(data'left downto 1);
      end if;
    end if;
  end process d_reg_p;

  cnt_p: process(clk48) is
  begin
    if rising_edge(clk48) then
      if cnt_clr = '1' then
        cnt <= (others => '0');
      elsif cnt_inc = '1' then
        cnt <= std_logic_vector(unsigned(cnt) + 1);
      end if;
    end if;
  end process cnt_p;

  crc_reg_p: process(clk48) is
  begin
    if rising_edge(clk48) then
      if crc_update = '1' then
        crc <= crc_data;
      end if;
    end if;
  end process crc_reg_p;

  crc_fsm_state_p: process(clk48, reset) is
  begin
    if reset = '1' then
      crc_state <= IDLE_ST;
    elsif rising_edge(clk48) then
      crc_state <= crc_next;
    end if;
  end process crc_fsm_state_p;

  crc_fsm_p: process(all) is
  begin
    dout_valid <= '0';
    din_ready  <= '0';

    d_load  <= '0';
    d_shift <= '0';

    crc_data <= (others => '1');
    crc_update <= '0';

    cnt_clr <= '0';
    cnt_inc <= '0';

    case crc_state is
      when IDLE_ST =>
        crc_update <= '1';
        cnt_clr <= '1';
        crc_next <= WAIT_ST;

      when WAIT_ST =>
        d_load <= din_valid;
        din_ready <= '1';
        if din_valid = '1' then
          crc_next <= CNT_ST;
        else
          crc_next <= WAIT_ST;
        end if;

      when CNT_ST =>
        cnt_inc <= '1';
        d_shift <= '1';
        crc_update <= '1';
        if (data(0) xor crc(0)) = '0' then
          crc_data <= '0' & crc(crc'left downto 1);
        else
          crc_data <= ('0' & crc(crc'left downto 1)) xor "10100";
        end if;
        if cnt = "1010" then
          crc_next <= RESULT_ST;
        else
          crc_next <= CNT_ST;
        end if;

      when RESULT_ST =>
        dout_valid <= '1';
        if dout_ready = '1' then
          crc_next <= IDLE_ST;
        else
          crc_next <= RESULT_ST;
        end if;

      when others => null;
    end case;
  end process crc_fsm_p;

  dout(10 downto  0) <= di;
  dout(15 downto 11) <= not crc;

end architecture sequential;
