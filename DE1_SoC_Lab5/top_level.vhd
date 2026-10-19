library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
  port (
    CLOCK_50  : in  std_logic;
    KEY       : in  std_logic_vector(3 downto 0);
    SW        : in  std_logic_vector(7 downto 0);
    HEX0      : out std_logic_vector(6 downto 0);
    HEX1      : out std_logic_vector(6 downto 0);
    HEX2      : out std_logic_vector(6 downto 0);
    HEX3      : out std_logic_vector(6 downto 0);
    HEX4      : out std_logic_vector(6 downto 0);
    HEX5      : out std_logic_vector(6 downto 0);
    GPIO_0    : out std_logic_vector(35 downto 0);
    LEDR      : out std_logic_vector(9 downto 0)
  );
end entity top_level;

architecture top of top_level is
  
  component nios_system is
		port (
			clk_clk            : in  std_logic                    := 'X';             -- clk
			reset_reset_n      : in  std_logic                    := 'X';             -- reset_n
			switches_export    : in  std_logic_vector(7 downto 0) := (others => 'X'); -- export
			pushbuttons_export : in  std_logic_vector(3 downto 0) := (others => 'X'); -- export
			hex0_export        : out std_logic_vector(6 downto 0);                    -- export
			hex1_export        : out std_logic_vector(6 downto 0);                    -- export
			hex2_export        : out std_logic_vector(6 downto 0);                    -- export
			hex4_export        : out std_logic_vector(6 downto 0);                    -- export
			hex5_export        : out std_logic_vector(6 downto 0);                    -- export
      out_wave_ext_addr  : out std_logic
		);
	end component nios_system;
  
begin 

  u0 : component nios_system
		port map (
			clk_clk            => CLOCK_50,
			reset_reset_n      => KEY(0),
			switches_export    => SW,
			pushbuttons_export => KEY,
			hex0_export        => HEX0,
			hex1_export        => HEX1,
			hex2_export        => HEX2,
			hex4_export        => HEX4,
			hex5_export        => HEX5,
			out_wave_ext_addr  => GPIO_0(0)
		);
  
  HEX3 <= (others => '1');
    
  GPIO_0(35 downto 1) <= (others => '0');
  LEDR(9 downto 0)    <= (others => '0');

end architecture top;