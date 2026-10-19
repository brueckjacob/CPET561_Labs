library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity servo_controller_tb is
end entity servo_controller_tb;

architecture sim of servo_controller_tb is

  constant CLK_PERIOD       : time    := 20 ns;
  constant SIM_PERIOD_COUNT : natural := 120_000;
  constant SIM_STEP_SIZE    : natural := 10_000;
  signal clk       : std_logic := '0';
  signal reset_n   : std_logic := '0';
  signal address   : std_logic := '0';
  signal write     : std_logic := '0';
  signal writedata : std_logic_vector(31 downto 0) := (others => '0');
  signal out_wave  : std_logic;
  signal irq       : std_logic;

  signal sim_done  : boolean := false;

begin

  clk <= not clk after CLK_PERIOD / 2 when not sim_done else '0';

  dut : entity work.servo_controller
    generic map (
      PERIOD_COUNT => SIM_PERIOD_COUNT,
      STEP_SIZE    => SIM_STEP_SIZE
    )
    port map (
      clk       => clk,
      reset_n   => reset_n,
      address   => address,
      write     => write,
      writedata => writedata,
      out_wave  => out_wave,
      irq       => irq
    );

  pulse_monitor : process
    variable t_rise : time;
  begin
    wait until rising_edge(out_wave);
    t_rise := now;
  end process;

  -- Stimulus
  stim : process

    procedure bus_write(addr : std_logic; data : natural) is
    begin
      wait until rising_edge(clk);
      address   <= addr;
      writedata <= std_logic_vector(to_unsigned(data, 32));
      write     <= '1';
      wait until rising_edge(clk);
      write     <= '0';
    end procedure;

    procedure wait_for_irq() is
    begin
      wait until irq = '1' for 20 ms;
      assert irq = '1'
    end procedure;

    -- Confirm a write cleared the IRQ
    procedure check_irq_cleared is
    begin
      wait until rising_edge(clk);
      wait until rising_edge(clk);
      assert irq = '0'
    end procedure;

  begin
    reset_n <= '0';
    wait for 100 ns;
    reset_n <= '1';

    -- Pass 1: sweep right to the default max
    wait_for_irq();

    -- IRQ must hold while nobody acknowledges it
    wait for 1 us;
    assert irq = '1'
	
    -- Acknowledge by writing a new MIN (register 0)
    bus_write('0', 60_000);
    check_irq_cleared;

    -- Pass 2: sweep left to the new min
    wait_for_irq();

    -- Acknowledge by writing a new MAX (register 1)
    bus_write('1', 80_000);
    check_irq_cleared;

    -- Pass 3: sweep right to the new max
    wait_for_irq();

    -- Restore the default min and let it start back left
    bus_write('0', 50_000);
    check_irq_cleared;
    wait for 3 ms;

    report "Testbench complete";
    sim_done <= true;
    wait;
  end process;

end architecture sim;
