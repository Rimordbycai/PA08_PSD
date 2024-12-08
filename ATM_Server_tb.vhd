library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Account_Record.all;

entity ATM_Server_tb is
end entity ATM_Server_tb;

architecture Behavioral of ATM_Server_tb is
    -- Clock period constant
    constant CLK_PERIOD : time := 100 ps;

    -- Components declarations
    component ATM_FSM
        generic (
            ATM_CONTROL_ID : STD_LOGIC_VECTOR(2 downto 0)
        );
        port (
            CLK : IN STD_LOGIC;
            FSM_EN : IN STD_LOGIC;

            INPUT_ID : IN STD_LOGIC_VECTOR(4 downto 0);
            INPUT_PIN : IN STD_LOGIC_VECTOR(3 downto 0);
            INPUT_NOMINAL : IN STD_LOGIC_VECTOR(7 downto 0);

            OPTION_WS : IN STD_LOGIC; -- 0: withdraw, 1: store
            
            MESSAGE_IN : IN STD_LOGIC_VECTOR(15 downto 0);
            
            MESSAGE_OUT : OUT STD_LOGIC_VECTOR(15 downto 0);
            MESSAGE_SEND : OUT STD_LOGIC;

            CURRENT_BALANCE : OUT STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;

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
    signal FSM_EN : STD_LOGIC := '1';

    -- ATM Signals
    signal ATM_INPUT_ID : STD_LOGIC_VECTOR(4 downto 0) := "00010";
    signal ATM_INPUT_PIN : STD_LOGIC_VECTOR(3 downto 0) := "0101";
    signal ATM_INPUT_NOMINAL : STD_LOGIC_VECTOR(7 downto 0) := "00000000";
    signal ATM_OPTION_WS : STD_LOGIC := '1';
    signal ATM_MESSAGE_OUT : STD_LOGIC_VECTOR(15 downto 0);
    signal ATM_MESSAGE_SEND : STD_LOGIC;
    signal ATM_CURRENT_BALANCE : STD_LOGIC_VECTOR(15 downto 0);

    -- Server Signals
    signal SERVER_MESSAGE_IN : STD_LOGIC_VECTOR(15 downto 0);
    signal SERVER_MESSAGE_OUT : STD_LOGIC_VECTOR(15 downto 0);
    signal SERVER_SEND_MESSAGE : STD_LOGIC;

    signal ACCOUNT_DATA : Account := (
        ID => "00010", 
        PIN => "0101", 
        ATM => "000", 
        MONEY => (others => '0')
    );
    signal ACCOUNT_UPDATE : Account;
    signal ACCOUNT_WRITE : STD_LOGIC;

begin
    -- Clock generation process
    process
    begin
        CLK <= '1';
        wait for CLK_PERIOD / 2;
        CLK <= '0';
        wait for CLK_PERIOD / 2;
    end process;

    -- Instantiate ATM_FSM
    ATM: ATM_FSM
        generic map (
            ATM_CONTROL_ID => "001"
        )
        port map (
            CLK => CLK,
            FSM_EN => FSM_EN,
            INPUT_ID => ATM_INPUT_ID,
            INPUT_PIN => ATM_INPUT_PIN,
            INPUT_NOMINAL => ATM_INPUT_NOMINAL,
            OPTION_WS => ATM_OPTION_WS,
            MESSAGE_IN => SERVER_MESSAGE_OUT,
            MESSAGE_OUT => ATM_MESSAGE_OUT,
            MESSAGE_SEND => ATM_MESSAGE_SEND,
            CURRENT_BALANCE => ATM_CURRENT_BALANCE
        );

    -- Instantiate Server_FSM
    SERVER: Server_FSM
        port map (
            CLK => CLK,
            FSM_EN => FSM_EN,
            ACCOUNT_DATA => ACCOUNT_DATA,
            MESSAGE_IN => ATM_MESSAGE_OUT,
            ACCOUNT_ADDRESS_ID => open,
            ACCOUNT_UPDATE => ACCOUNT_UPDATE,
            ACCOUNT_WRITE => ACCOUNT_WRITE,
            MESSAGE_OUT => SERVER_MESSAGE_OUT,
            SEND_MESSAGE => SERVER_SEND_MESSAGE
        );

    -- Test stimulus process
    stimulus: process
    begin
        -- Cycle 1: Login
        ATM_INPUT_ID <= "00010";
        ATM_INPUT_PIN <= "0101"; -- Correct PIN
        wait for CLK_PERIOD * 20;

        -- Cycle 2: Store money
        ATM_OPTION_WS <= '1'; -- Store
        ATM_INPUT_NOMINAL <= "00101000"; -- Store 40 units
        wait for CLK_PERIOD * 20;

        -- Cycle 3: Withdraw money
        ATM_OPTION_WS <= '0'; -- Withdraw
        ATM_INPUT_NOMINAL <= "00011000"; -- Withdraw 24 units
        wait for CLK_PERIOD * 20;

        -- Cycle 4: Logout
        ATM_INPUT_ID <= (others => '0');
        wait for CLK_PERIOD * 20;

        -- End simulation
        wait;
    end process;

end architecture Behavioral;
