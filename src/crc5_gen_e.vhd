library ieee;
use ieee.std_logic_1164.all;

entity crc5_gen_e is
  generic (
    N_STAGES_G : integer := 11;
    CONFIG_SKID_G : boolean_vector(0 to N_STAGES_G) := (others => false);
    CONFIG_PIPE_G : boolean_vector(0 to N_STAGES_G) := (others => false));
  port (
    clk48      : in  std_logic;
    reset      : in  std_logic;

    din        : in  std_logic_vector(10 downto 0);
    din_valid  : in  std_logic;
    din_ready  : out std_logic;

    dout       : out std_logic_vector(15 downto 0);
    dout_valid : out std_logic;
    dout_ready : in  std_logic);
end entity crc5_gen_e;
