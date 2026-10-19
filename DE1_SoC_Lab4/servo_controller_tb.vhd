library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Testbench for servo_controller (Lab 4)
-- Verifies:
--   * pulse width increases to max, then decreases to min
--   * IRQ is raised at the max and min limits
--   * IRQ stays high until a register write, and the write clears it
--   * writes to both registers change the sweep limits
-- Requires servo_controller to have generics PERIOD_COUNT and STEP_SIZE.

entity servo_controller_tb is
end entity servo_controller_tb;

architecture sim of servo_controller_tb is

  constant CLK_PERIOD       : time    := 20 ns;     -- 50 MHz
  constant SIM_PERIOD_COUNT : natural := 120_000;   -- shortened frame (must exceed max pulse)
  constant SIM_STEP_SIZE    : natural := 10_000;    -- big steps so sweeps finish quickly

  signal clk       : std_logic := '0';
  signal reset_n   : std_logic := '0';
  signal address   : std_logic := '0';
  signal write     : std_logic := '0';
  signal writedata : std_logic_vector(31 downto 0) := (others => '0');
  signal out_wave  : std_logic;
  signal irq       : std_logic;

  signal sim_done  : boolean := false;

begin

  -- Clock (stops when the test is finished so the simulation ends)
  clk <= not clk after CLK_PERIOD / 2 when not sim_done else '0';

  -- Device under test
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

  -- Monitor: report the high time of every output pulse, in clock cycles
  pulse_monitor : process
    variable t_rise : time;
  begin
    wait until rising_edge(out_wave);
    t_rise := now;
    wait until falling_edge(out_wave);
    report "out_wave pulse width = "
           & integer'image((now - t_rise) / CLK_PERIOD) & " clocks";
  end process;

  -- Stimulus
  stim : process

    -- One-clock register write, like the Avalon bus will do in Lab 5
    procedure bus_write(addr : std_logic; data : natural) is
    begin
      wait until rising_edge(clk);
      address   <= addr;
      writedata <= std_logic_vector(to_unsigned(data, 32));
      write     <= '1';
      wait until rising_edge(clk);
      write     <= '0';
    end procedure;

    -- Wait for the IRQ, failing if it never arrives
    procedure wait_for_irq(msg : string) is
    begin
      wait until irq = '1' for 20 ms;
      assert irq = '1'
        report "TIMEOUT waiting for IRQ: " & msg severity failure;
      report "IRQ raised: " & msg;
    end procedure;

    -- Confirm a write cleared the IRQ
    procedure check_irq_cleared is
    begin
      wait until rising_edge(clk);
      wait until rising_edge(clk);
      assert irq = '0'
        report "IRQ was NOT cleared by the register write" severity error;
      report "IRQ cleared by write";
    end procedure;

  begin
    -- Reset
    reset_n <= '0';
    wait for 100 ns;
    reset_n <= '1';
    report "Reset released: sweeping right from 50,000 toward 100,000";

    -- Pass 1: sweep right to the default max
    wait_for_irq("max reached (100,000)");

    -- IRQ must hold while nobody acknowledges it
    wait for 1 us;
    assert irq = '1'
      report "IRQ did not stay high while waiting for a write" severity error;

    -- Acknowledge by writing a new MIN (register 0)
    bus_write('0', 60_000);
    check_irq_cleared;
    report "Wrote min = 60,000: sweeping left, should stop at 60,000";

    -- Pass 2: sweep left to the new min
    wait_for_irq("min reached (60,000)");

    -- Acknowledge by writing a new MAX (register 1)
    bus_write('1', 80_000);
    check_irq_cleared;
    report "Wrote max = 80,000: sweeping right, should stop at 80,000";

    -- Pass 3: sweep right to the new max
    wait_for_irq("max reached (80,000)");

    -- Restore the default min and let it start back left
    bus_write('0', 50_000);
    check_irq_cleared;
    wait for 3 ms;

    report "Testbench complete";
    sim_done <= true;
    wait;
  end process;

end architecture sim;
