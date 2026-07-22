-- Skid buffer
--
-- Combinatorial Data and Valid signals in A -> B direction
-- Registered A <- B Ready signal

library ieee;
use ieee.std_logic_1164.all;

entity skid_buffer is
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
end entity skid_buffer;

architecture rtl of skid_buffer is
  signal d_reg   : std_logic_vector(DATA_WIDTH_G-1 downto 0);
  signal r_valid : std_logic;
  signal init    : std_logic;
begin

  a_ready <= not r_valid;

  b_data  <= a_data when r_valid = '0' else d_reg;
  b_valid <= init and (a_valid or r_valid);

  p_init: process(clk, rst) is
  begin
    if rst = '1' then
      init <= '0';
    elsif rising_edge(clk) then
      init <= '1';
    end if;
  end process p_init;

  p_r_valid: process(clk, rst) is
  begin
    if rst = '1' then
      r_valid <= '1';
    elsif rising_edge(clk) then
      if init = '0' then
        r_valid <= '0';
      else
        if r_valid = '1' then
          if b_ready = '1' then
            r_valid <= '0';
          end if;
        else
          if a_valid = '1' and b_ready = '0' then
            r_valid <= '1';
          end if;
        end if;
      end if;
    end if;
  end process p_r_valid;

  p_d_reg: process(clk) is
  begin
    if rising_edge(clk) then
      if r_valid = '0' then
        if a_valid = '1' and b_ready = '0' then
          d_reg <= a_data;
        end if;
      end if;
    end if;
  end process p_d_reg;

end architecture rtl;
