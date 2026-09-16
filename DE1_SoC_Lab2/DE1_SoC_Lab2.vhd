library ieee;
use ieee.std_logic_1164.all;

entity DE1_SoC_Lab2 is
	port (
		CLOCK_50	: in std_logic;
		KEY 		: in std_logic_vector(3 downto 0);
		SW			: in std_logic_vector(7 downto 0);
		HEX0 		: out std_logic_vector(6 downto 0)
	);
end entity DE1_SoC_Lab2;

architecture arch of DE1_SoC_Lab2 is

	
	component nios_system is
		port (
			clk_clk            : in  std_logic                    := 'X';             -- clk
			reset_reset_n      : in  std_logic                    := 'X';             -- reset_n
			hex0_export        : out std_logic_vector(6 downto 0);                    -- export
			pushbuttons_export : in  std_logic_vector(3 downto 0) := (others => 'X'); -- export
			switches_export    : in  std_logic_vector(7 downto 0) := (others => 'X')  -- export
		);
	end component nios_system;
	
begin

	u0 : component nios_system
		port map (
			clk_clk					=> CLOCK_50,
			reset_reset_n			=> '1',
			hex0_export				=> HEX0,
			pushbuttons_export	=> KEY,
			switches_export		=> SW
		);
		
end architecture arch;