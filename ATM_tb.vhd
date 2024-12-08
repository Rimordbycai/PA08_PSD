library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ATM_tb is
end entity ATM_tb;

architecture sim of ATM_tb is
    -- Clock period
    constant CLOCK_PERIOD : time := 100 ps;

    -- Signals for ATM
    signal CLK               : std_logic := '0';
    signal INPUT_ID          : std_logic_vector(4 downto 0) := (others => '0');
    signal INPUT_PIN         : std_logic_vector(3 downto 0) := (others => '0');
    signal INPUT_NOMINAL     : std_logic_vector(7 downto 0) := (others => '0');
    signal OPTION_WS         : std_logic := '0'; -- 0 = Withdraw, 1 = Store
    signal CURRENT_BALANCE   : std_logic_vector(15 downto 0);
    signal SLAVE_SELECT      : std_logic := '1';
    signal SDI               : std_logic := '1';
    signal LINE_BUSY         : std_logic := '0';
    signal SDO               : std_logic;
    signal SENDING           : std_logic;

    -- Server response signals
    signal RECEIVED          : std_logic := '0';
    signal MESSAGE_RECEIVE   : std_logic_vector(15 downto 0) := (others => '0');

    -- Component instantiation
    component ATM
        generic (
            ATM_CONTROL_ID : STD_LOGIC_VECTOR(2 downto 0) := "001"
        );
        port (
            CLK : IN std_logic;
            INPUT_ID : IN std_logic_vector(4 downto 0);
            INPUT_PIN : IN std_logic_vector(3 downto 0);
            INPUT_NOMINAL : IN std_logic_vector(7 downto 0);
            OPTION_WS : IN std_logic;
            CURRENT_BALANCE : OUT std_logic_vector(15 downto 0);
            SLAVE_SELECT : IN std_logic;
            SDI : IN std_logic;
            LINE_BUSY : INOUT std_logic;
            SDO : OUT std_logic;
            SENDING : OUT std_logic
        );
    end component;

begin
    -- Clock generation
    clk_gen : process
    begin
        while true loop
            CLK <= '0';
            wait for CLOCK_PERIOD / 2;
            CLK <= '1';
            wait for CLOCK_PERIOD / 2;
        end loop;
    end process;

    -- Instantiate the ATM
    UUT_ATM : ATM
        port map (
            CLK => CLK,
            INPUT_ID => INPUT_ID,
            INPUT_PIN => INPUT_PIN,
            INPUT_NOMINAL => INPUT_NOMINAL,
            OPTION_WS => OPTION_WS,
            CURRENT_BALANCE => CURRENT_BALANCE,
            SLAVE_SELECT => SLAVE_SELECT,
            SDI => SDI,
            LINE_BUSY => LINE_BUSY,
            SDO => SDO,
            SENDING => SENDING
        );

    -- Simulate server response
    server_response : process
    begin
        wait until SENDING = '1'; -- Wait until ATM sends data
        wait for CLOCK_PERIOD * 2; -- Simulate a delay

        -- Mock server sending data back to the ATM
        MESSAGE_RECEIVE <= x"0028"; -- Example: Server responds with new balance (40 in decimal)
        RECEIVED <= '1'; -- Indicate data received

        wait for CLOCK_PERIOD * 2;
        RECEIVED <= '0'; -- Clear received flag
    end process;

    -- Test process
    test_process : process
    begin
        -- Initial balance check
        wait for CLOCK_PERIOD * 10;
        assert CURRENT_BALANCE = x"0000" 
            report "Initial balance should be zero" severity error;

        -- Simulate storing money
        INPUT_ID <= "00001"; -- User ID
        INPUT_PIN <= "1111"; -- User PIN
        INPUT_NOMINAL <= "00101000"; -- Store 40 (in decimal)
        OPTION_WS <= '1'; -- Store
        SLAVE_SELECT <= '0'; -- Select the slave (ATM)
        wait for CLOCK_PERIOD * 20;

        -- Check balance after storing
        assert CURRENT_BALANCE = x"0028" 
            report "Balance after storing 40 is incorrect!" severity error;

        -- Simulate withdrawing money
        INPUT_NOMINAL <= "00001000"; -- Withdraw 8 (in decimal)
        OPTION_WS <= '0'; -- Withdraw
        wait for CLOCK_PERIOD * 20;

        -- Mock server response for withdrawal
        MESSAGE_RECEIVE <= x"0020"; -- Example: New balance 32 in decimal
        RECEIVED <= '1';
        wait for CLOCK_PERIOD * 2;
        RECEIVED <= '0';

        -- Check balance after withdrawal
        assert CURRENT_BALANCE = x"0020" 
            report "Balance after withdrawing 8 is incorrect!" severity error;

        -- End simulation
        wait for CLOCK_PERIOD * 20;
        assert false report "Simulation completed successfully!" severity note;
        wait;
    end process;
end architecture sim;
