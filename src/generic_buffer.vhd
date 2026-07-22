-- Generic buffer
--
-- Sequence of a Skid Buffer and a Pipeline Buffer
--
-- Each stage may be bypassed, if both stages are
-- enabled, then all the signals (data/valid/ready)
-- are registered and latency is one clock cycle

library ieee;
use ieee.std_logic_1164.all;

entity generic_buffer is
  generic (
    DATA_WIDTH_G  : integer := 8;
    ENABLE_SKID_G : boolean := true;
    ENABLE_PIPE_G : boolean := true
    );
  port (
    clk : in std_logic;
    rst : in std_logic;

    a_data  : in std_logic_vector(DATA_WIDTH_G-1 downto 0);
    a_valid : in std_logic;
    a_ready : out std_logic;

    b_data  : out std_logic_vector(DATA_WIDTH_G-1 downto 0);
    b_valid : out std_logic;
    b_ready : in  std_logic
    );
end entity generic_buffer;

architecture rtl of generic_buffer is
  signal i_data  : std_logic_vector(DATA_WIDTH_G-1 downto 0);
  signal i_valid : std_logic;
  signal i_ready : std_logic;
begin

  g_skid: if ENABLE_SKID_G generate
    i_skid: entity work.skid_buffer
      generic map (DATA_WIDTH_G  => DATA_WIDTH_G)
      port map (
        clk => clk,
        rst => rst,
        a_data  => a_data,
        a_valid => a_valid,
        a_ready => a_ready,
        b_data  => i_data,
        b_valid => i_valid,
        b_ready => i_ready
        );
  else generate
    i_data  <= a_data;
    i_valid <= a_valid;
    a_ready <= i_ready;
  end generate;

  g_pipe: if ENABLE_PIPE_G generate
    i_pipe: entity work.pipeline_buffer
      generic map (DATA_WIDTH_G  => DATA_WIDTH_G)
      port map (
        clk => clk,
        rst => rst,
        a_data  => i_data,
        a_valid => i_valid,
        a_ready => i_ready,
        b_data  => b_data,
        b_valid => b_valid,
        b_ready => b_ready
        );
  else generate
    b_data  <= i_data;
    b_valid <= i_valid;
    i_ready <= b_ready;
  end generate;

end architecture rtl;
