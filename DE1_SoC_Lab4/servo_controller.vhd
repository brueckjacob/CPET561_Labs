library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity servo_controller is
  port (
    clk     : in std_logic;
    reset   : in std_logic;
    addr    : in std_logic_vector(1 downto 0);
    wr_en   : in std_logic;
    wr_data : in std_logic_vector(7 downto 0);
    rd_data : out std_logic_vector(7 downto 0);
    pwm     : out std_logic;
    irq     : out std_logic
  );
end entity servo_controller;

architecture arch of servo_controller is
  type state_type is (IDLE, MOVE_LEFT, MOVE_RIGHT);
  signal current_state, next_state        : state_type;

  signal angle_reg    : unsigned(7 downto 0);
  signal ctrl_reg     : std_logic_vector(7 downto 0);
  signal angle_cnt    : unsigned(19 downto 0);
  signal period_cnt   : unsigned(19 downto 0);
  signal pulse_width  : unsigned(19 downto 0);
  
  signal period_done  : std_logic;
  signal pulse_done   : std_logic;
  signal pulse_start  : std_logic;
  signal pwm_i        : std_logic;
  signal irq_i        : std_logic;
  
  constant Min_pulse : unsigned(19 downto 0) := to_unsigned(50_000, 20);
  constant Neutral   : unsigned(19 downto 0) := to_unsigned(75_000, 20);
  constant Max_pulse : unsigned(19 downto 0) := to_unsigned(100_000, 20);
  
  begin
    pwm <= pwm_i;
    irq <= irq_i;
    
    with angle_reg(1 downto 0) select
      pulse_width <=  Min_pulse     when "00",
                      Neutral       when "01",
                      Max_pulse     when "10",
                      Neutral       when others;
    
    
    angle_counter_proc : process(clk, reset)
    begin
      if reset = '1' then
        if rising_edge(clk) then
          angle_cnt   <= (others => '0');
          pwm_i       <= '0';
          pulse_done  <= '0';
        else
          pulse_done  <= '0';
          if pulse_start = '1' then
            angle_cnt <= (others => '0');
            pwm_i     <= '1';
          elsif pwm_i = '1' then
            if pwm_i >= pulse_width then
              pwm_i       <= '0';
              pulse_done  <= '1';
            else
              angle_cnt <= angle_cnt + 1;
            end if;
          end if;
        end if;
      end if;
    end process;
    
    period_counter_proc : process(clk, reset)
    begin
    
    end process;
    
    servo_fsm_proc : process(clk, irq_i, pwm_i)
    begin
    
    end process;
    
    servo_irq_proc : process(clk)
    begin
    
    end process;
    
    reg_logic_proc : process(clk)
    begin
    
    end process;
    
end architecture arch;