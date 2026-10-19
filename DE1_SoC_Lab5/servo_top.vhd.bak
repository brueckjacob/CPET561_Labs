library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity servo_top is
  port (
    CLOCK_50  : in  std_logic;
    KEY       : in  std_logic_vector(3 downto 0);
    GPIO_0    : out std_logic_vector(35 downto 0);
    LEDR      : out std_logic_vector(9 downto 0)
  );
end entity servo_top;

architecture top of servo_top is
  constant MIN_COUNT : std_logic_vector(31 downto 0) := x"0000C350";
  
  component servo_controller is
    port (
      clk         : in  std_logic;
      reset_n     : in  std_logic;
      address     : in  std_logic;
      write       : in  std_logic;
      writedata   : in  std_logic_vector(31 downto 0);
      out_wave    : out std_logic;
      irq         : out std_logic
    );
  end component;
  
begin 
  
  u_servo : servo_controller
    port map (
      clk       =>  CLOCK_50,
      reset_n   =>  KEY(0),
      address   =>  '0',
      write     =>  '1',
      writedata =>  MIN_COUNT,
      out_wave  =>  GPIO_0(0),
      irq       =>  LEDR(0)
    );
    
  GPIO_0(35 downto 1) <= (others => '0');
  LEDR(9 downto 1)    <= (others => '0');

end architecture top;