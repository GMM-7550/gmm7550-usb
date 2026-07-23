library ieee;
use ieee.std_logic_1164.all;

entity crc16_gen is
  port (
    clk48     : in  std_logic;
    init      : in  std_logic;

    din       : in  std_logic_vector(7 downto 0);
    din_valid : in  std_logic;

    dout      : out std_logic_vector(15 downto 0));
end entity crc16_gen;

architecture rtl of crc16_gen is
  signal crc_reg : std_logic_vector(15 downto 0);

  type ppl_data_t is array (0 to 8) of std_logic_vector(23 downto 0);
  signal ppl_data : ppl_data_t;
begin

  crc_reg_p: process(clk48) is
  begin
    if rising_edge(clk48) then
      if init = '1' then
        crc_reg <= (others => '1');
      elsif din_valid = '1' then
        crc_reg <= ppl_data(8)(crc_reg'range);
      end if;
    end if;
  end process crc_reg_p;

  ppl_data(0) <= din & crc_reg;

  ppl_g: for i in 1 to 8 generate
    -- Propogate 8 bit input data through the pipeline
    ppl_data(i)(23 downto 16) <= ppl_data(i-1)(23 downto 16);

    -- Update CRC 16
    ppl_data(i)(15 downto 0) <= "0" & ppl_data(i-1)(15 downto 1)
                                when (ppl_data(i-1)(0) xor ppl_data(i-1)(i+15)) = '0'
                                else
                                ("0" & ppl_data(i-1)(15 downto 1)) xor x"a001";
  end generate;

  dout <= not crc_reg;

end architecture rtl;
