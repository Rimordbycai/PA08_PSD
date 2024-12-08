library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Account_Record.all;

entity Server_FSM_tb is
end entity Server_FSM_tb;

architecture Behavioral of Server_FSM_tb is
    -- Clock period constant
    constant CLK_PERIOD : time := 100 ps;

    -- Component declaration
    component Server_FSM
        port (
            CLK : IN STD_LOGIC;
            FSM_EN : IN STD_LOGIC;
            ACCOUNT_DATA : IN Account;
            MESSAGE_IN : IN STD_LOGIC_VECTOR(15 downto 0);

            ACCOUNT_ADDRESS_ID : OUT STD_LOGIC_VECTOR(4 downto 0);
            ACCOUNT_UPDATE : OUT Account;
            ACCOUNT_WRITE : OUT STD_LOGIC;

            MESSAGE_OUT : OUT STD_LOGIC_VECTOR(15 downto 0);
            SEND_MESSAGE : OUT STD_LOGIC
        );
    end component;

    -- Signals
    signal CLK : STD_LOGIC := '0';
    signal FSM_EN : STD_LOGIC := '0';
    signal ACCOUNT_DATA : Account := (
        ID => "00010",      -- ID 2
        PIN => "0101",      -- PIN 5
        ATM => "000",       -- Not logged into any ATM
        MONEY => (others => '0')  -- Initial money = 0
    );
    signal MESSAGE_IN : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

    signal ACCOUNT_ADDRESS_ID : STD_LOGIC_VECTOR(4 downto 0);
    signal ACCOUNT_UPDATE : Account;
    signal ACCOUNT_WRITE : STD_LOGIC;
    signal MESSAGE_OUT : STD_LOGIC_VECTOR(15 downto 0);
    signal SEND_MESSAGE : STD_LOGIC;

begin
    -- Clock generation process
    process
    begin
        CLK <= '1';
        wait for CLK_PERIOD / 2;
        CLK <= '0';
        wait for CLK_PERIOD / 2;
    end process;

    -- Instantiate the DUT (Device Under Test)
    DUT: Server_FSM
        port map (
            CLK => CLK,
            FSM_EN => FSM_EN,
            ACCOUNT_DATA => ACCOUNT_DATA,
            MESSAGE_IN => MESSAGE_IN,

            ACCOUNT_ADDRESS_ID => ACCOUNT_ADDRESS_ID,
            ACCOUNT_UPDATE => ACCOUNT_UPDATE,
            ACCOUNT_WRITE => ACCOUNT_WRITE,
            MESSAGE_OUT => MESSAGE_OUT,
            SEND_MESSAGE => SEND_MESSAGE
        );

    -- Test stimulus process
    stimulus: process
    begin
        -- Reset and Initialization
        FSM_EN <= '0';
        wait for CLK_PERIOD * 2;

        -- Cycle 1: LOGIN
        FSM_EN <= '1';
        MESSAGE_IN <= "1100100010000100";  -- LOGIN opcode, ATM_ID=3, ACCOUNT_ID=2, PIN=5
        wait for CLK_PERIOD * 3;

        -- Cycle 2: LOGIN with incorrect PIN
        MESSAGE_IN <= "1100100010010100";  -- LOGIN opcode, ATM_ID=3, ACCOUNT_ID=2, PIN=10
        wait for CLK_PERIOD * 3;

        -- Cycle 3: STORE money
        MESSAGE_IN <= "1000100001010000";  -- STORE opcode, ATM_ID=3, ACCOUNT_ID=2, MONEY=10
        wait for CLK_PERIOD * 3;

        -- Cycle 4: WITHDRAW money
        MESSAGE_IN <= "0100100000101000";  -- WITHDRAW opcode, ATM_ID=3, ACCOUNT_ID=2, MONEY=5
        wait for CLK_PERIOD * 3;

        -- Cycle 5: LOGOUT
        MESSAGE_IN <= "0000100010000000";  -- LOGOUT opcode, ATM_ID=3, ACCOUNT_ID=2
        wait for CLK_PERIOD * 3;

        -- End simulation
        FSM_EN <= '0';
        wait;
    end process;

end architecture Behavioral;
