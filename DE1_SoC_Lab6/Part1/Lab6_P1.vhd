library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

ENTITY lab6_P1 is
  port (
    CLOCK_50 : in  std_logic;
    KEY      : in  std_logic;
    LEDR     : out std_logic_vector(7 downto 0)
   );
end entity lab6_P1;

architecture arch of lab6_P1 is

	component nios_system is
		port (
			clk_clk             : in  std_logic                    := 'X'; -- clk
			reset_reset_n       : in  std_logic                    := 'X'; -- reset_n
			leds_export         : out std_logic_vector(7 downto 0);        -- export
			pushbuttons_export  : in  std_logic                    := 'X'  -- export
		);
	end component nios_system;
  
begin

	u0 : component nios_system
		port map (
			clk_clk             => CLOCK_50,          --      clk.clk
			reset_reset_n       => '1',               --    reset.reset_n
			leds_export         => LEDR,              --     leds.export
			pushbuttons_export  => KEY                -- switches.export
		);
    
end architecture arch;