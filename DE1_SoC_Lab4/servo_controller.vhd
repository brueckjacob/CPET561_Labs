library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity servo_controller is
  generic (
    PERIOD_COUNT  : natural := 1_000_000;
    STEP_SIZE     : natural := 500
  );

  port (
    clk         : in  std_logic;
    reset_n     : in  std_logic;
    address     : in  std_logic;
    write       : in  std_logic;
    writedata   : in  std_logic_vector(31 downto 0);
    out_wave    : out std_logic;
    irq         : out std_logic
  );
end entity servo_controller;

architecture arch of servo_controller is
  type state_type is (S_INT, MOVE_LEFT, MOVE_RIGHT);
  signal state        : state_type;

  signal period_cnt     : unsigned(19 downto 0);
  signal pulse_width    : unsigned(19 downto 0);
  signal min_angle_reg  : unsigned(31 downto 0);
  signal max_angle_reg  : unsigned(31 downto 0);
  
  signal pulse_start  : std_logic;
  signal pwm_i        : std_logic;
  signal irq_i        : std_logic;
  signal last_dir     : std_logic := '0';
  
  constant Min_pulse 	: unsigned(19 downto 0) := to_unsigned(50_000, 20);
  constant Max_pulse 	: unsigned(19 downto 0) := to_unsigned(100_000, 20);
  constant Max_period	: unsigned(19 downto 0) := to_unsigned(PERIOD_COUNT, 20);
  constant STEP       : unsigned(19 downto 0) := to_unsigned(STEP_SIZE, 20);
  
  begin
    out_wave <= pwm_i;
    irq <= irq_i;
    
    pwm_i <= '1' when period_cnt < pulse_width else '0';
    
    -- Angle counter process
    angle_counter_proc : process(clk, reset_n)
    begin
      if reset_n = '0' then
        pulse_width   <= Min_pulse;
  
      elsif rising_edge(clk) then
      
        if pulse_start = '1' then

          if state = MOVE_RIGHT then
            pulse_width <= pulse_width + STEP;
            
          elsif state = MOVE_LEFT then
            pulse_width <= pulse_width - STEP;
            
          end if;
        end if;
      end if;
    end process;
    
    -- Period counter process
    period_counter_proc : process(clk, reset_n)
    begin
		if reset_n = '0' then
			period_cnt	<= (others =>  '0');
			pulse_start	<= '0';
			
		elsif rising_edge(clk) then
			pulse_start	<= '0';
			
      if period_cnt = Max_period - 1 then
        period_cnt  <= (others => '0');
        pulse_start <= '1';
       
      else
        period_cnt <= period_cnt + 1;
      end if;
     end if;
    end process;
    
    -- Servo Finite State Machine
    servo_fsm_proc : process(clk, reset_n)
    begin
      if reset_n = '0' then
        state <= MOVE_RIGHT;
        last_dir <= '0';
        
      elsif rising_edge(clk) then
        case state is
          when MOVE_RIGHT =>
            if irq_i = '1' then
              last_dir <= '1';
              state <= S_INT;
            end if;
            
          when MOVE_LEFT =>
            if irq_i = '1' then
              last_dir <= '0';
              state <= S_INT;
            end if;
          
          when S_INT =>
            if write = '1' then
              if last_dir = '0' then
                state <= MOVE_RIGHT;
              else
                state <= MOVE_LEFT;
              end if;
            end if;
            
          when others =>
            state <= MOVE_RIGHT;
        end case;
      end if;
    end process;
    
    -- Servo interrupt process
    servo_irq_proc : process(clk, reset_n)
    begin
      if reset_n = '0' then
        irq_i <= '0';
      
      elsif rising_edge(clk) then
        if  (state = MOVE_RIGHT and pulse_width >= max_angle_reg) or
            (state = MOVE_LEFT and pulse_width <= min_angle_reg) then
          irq_i <= '1';
          
        elsif write = '1' then 
          irq_i <= '0';
        end if;
      end if;
    end process;
    
    -- Register logic process
    reg_logic_proc : process(clk, reset_n)
    begin
      if reset_n = '0' then
        min_angle_reg <= to_unsigned(50_000, 32);
        max_angle_reg <= to_unsigned(100_000, 32);
        
      elsif rising_edge(clk) then
        if write = '1' then
          if address = '0' then
            min_angle_reg <= unsigned(writedata);
            
          else
            max_angle_reg <= unsigned(writedata);
          end if;
        end if;
      end if;
    end process;
    
end architecture arch;