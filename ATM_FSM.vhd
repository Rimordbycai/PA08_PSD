library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ATM_FSM is
    generic (
        ATM_CONTROL_ID : STD_LOGIC_VECTOR(2 downto 0) := "001"
    );

    port (
        CLK : IN STD_LOGIC;
        FSM_EN : IN STD_LOGIC;
        
        INPUT_ID : IN STD_LOGIC_VECTOR(4 downto 0);
        INPUT_PIN : IN STD_LOGIC_VECTOR(3 downto 0);
        INPUT_NOMINAL : IN STD_LOGIC_VECTOR(7 downto 0);

        OPTION_WS : IN STD_LOGIC; -- 0 untuk withdraw, 1 untuk store
        
        MESSAGE_IN : IN STD_LOGIC_VECTOR(15 downto 0);
        
        MESSAGE_OUT : OUT STD_LOGIC_VECTOR(15 downto 0);
        MESSAGE_SEND : OUT STD_LOGIC;

        CURRENT_BALANCE : OUT STD_LOGIC_VECTOR(15 downto 0)
    );
end entity ATM_FSM;


architecture rtl of ATM_FSM is
    type StateType is (IDLE, INPUT, LOGOUT, SEND, WAIT_MESSAGE);
    SIGNAL STATE : StateType;

    SIGNAL MESSAGE_BUFFER : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

    ALIAS OPCODE : STD_LOGIC_VECTOR(1 downto 0) is MESSAGE_BUFFER(15 downto 14);
    ALIAS ATM_ID : STD_LOGIC_VECTOR(2 downto 0) is MESSAGE_BUFFER(13 downto 11);
    ALIAS ACCOUNT_ID : STD_LOGIC_VECTOR(4 downto 0) is MESSAGE_BUFFER(10 downto 6);
    ALIAS ACCOUNT_PIN : STD_LOGIC_VECTOR(3 downto 0) is MESSAGE_BUFFER(5 downto 2);
    ALIAS NOMINAL : STD_LOGIC_VECTOR(7 downto 0) is MESSAGE_BUFFER(10 downto 3);

begin

    ATM_ID <= ATM_CONTROL_ID;

    TRANSITION : PROCESS(CLK)
        VARIABLE ACCOUNT_ACTIVE_ID : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    begin
        if rising_edge(CLK) and FSM_EN = '1' then
            case STATE is
                when IDLE =>
                    if INPUT_ID /= "00000" then
                        STATE <= INPUT;
                    elsif ACCOUNT_ACTIVE_ID /= "00000" then
                        STATE <= LOGOUT;
                    end if;

                when INPUT =>
                    -- Login
                    if ACCOUNT_ACTIVE_ID = "00000" then
                        OPCODE <= "11";
                        ACCOUNT_ID <= INPUT_ID;
                        ACCOUNT_PIN <= INPUT_PIN;
                    else
                        if OPTION_WS = '0' then
                            OPCODE <= "01"; -- WITHDRAW
                        else
                            OPCODE <= "10"; -- STORE    
                        end if;

                        NOMINAL <= INPUT_NOMINAL;
                    end if;
                    STATE <= SEND;

                when LOGOUT =>
                    OPCODE <= "00";
                    ACCOUNT_ID <= ACCOUNT_ACTIVE_ID;
                    STATE <= SEND;

                when SEND =>
                    MESSAGE_OUT <= MESSAGE_BUFFER;
                    MESSAGE_SEND <= '1';
                    STATE <= WAIT_MESSAGE;

                when WAIT_MESSAGE =>
                    MESSAGE_SEND <= '0';
                    if MESSAGE_IN(15) = '1' then
                        ACCOUNT_ACTIVE_ID := INPUT_ID;
                        CURRENT_BALANCE <= '0' & MESSAGE_IN(14 downto 0);
                    else
                        CURRENT_BALANCE <= (others => '0');
                    end if;
                    STATE <= IDLE;
                    
            end case;
        end if;
    end process TRANSITION;
    
    
end architecture rtl;