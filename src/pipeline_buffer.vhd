-- Pipeline buffer
--
-- Registered Data and Valid signals in A -> B direction
-- Combinatorial A <- B Ready signal

library ieee;
use ieee.std_logic_1164.all;

entity pipeline_buffer is
  generic (
    DATA_WIDTH_G : integer := 8
    );
  port (
    clk : in std_logic;
    rst : in std_logic;

    a_data : in std_logic_vector(DATA_WIDTH_G-1 downto 0);
    a_valid : in std_logic;
    a_ready : out std_logic;

    b_data  : out std_logic_vector(DATA_WIDTH_G-1 downto 0);
    b_valid : out std_logic;
    b_ready : in  std_logic
    );
end entity pipeline_buffer;

architecture rtl of pipeline_buffer is
  signal d_reg : std_logic_vector(DATA_WIDTH_G-1 downto 0);
  signal v_reg : std_logic;
  signal ready : std_logic;
  signal init    : std_logic;
begin

  b_data  <= d_reg;
  b_valid <= v_reg;

  ready <= init and (not v_reg or (v_reg and b_ready));

  a_ready <= ready;

  p_init: process(clk, rst) is
  begin
    if rst = '1' then
      init <= '0';
    elsif rising_edge(clk) then
      init <= '1';
    end if;
  end process p_init;

  p_d_reg: process(clk) is
  begin
    if rising_edge(clk) then
      if a_valid = '1' and ready = '1' then
        d_reg <= a_data;
      end if;
    end if;
  end process p_d_reg;

  p_v_reg: process(clk, rst) is
  begin
    if rst = '1' then
      v_reg <= '0';
    elsif rising_edge(clk) then
      if ready = '1' then
        v_reg <= a_valid;
      end if;
    end if;
  end process p_v_reg;

end architecture rtl;
