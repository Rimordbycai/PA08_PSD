library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ATM_FSM is

    generic (
        ATM_ID : STD_LOGIC_VECTOR(2 downto 0) := "001"
    );

    port (
        CLK : IN STD_LOGIC;
        FSM_EN : IN STD_LOGIC;
        
        ATM_INSIDE : IN STD_LOGIC;
        ACCOUNT_ID : IN STD_LOGIC_VECTOR(4 downto 0);
        ACCOUNT_PIN : IN STD_LOGIC_VECTOR(3 downto 0);

        NOMINAL : IN INTEGER RANGE 0 to 255;
        MESSAGE_IN : IN STD_LOGIC_VECTOR(15 downto 0);

        OPTION_WS : IN STD_LOGIC; -- 0 untuk withdraw, 1 untuk store
        
        MESSAGE_OUT : OUT STD_LOGIC_VECTOR(15 downto 0);
        MESSAGE_SEND : OUT STD_LOGIC
    );
end entity ATM_FSM;


architecture rtl of ATM_FSM is
    type StateType is (IDLE, INPUT, SEND);
    SIGNAL STATE : StateType;

    ALIAS OPCODE : STD_LOGIC_VECTOR(1 downto 0) is MESSAGE_IN(15 downto 14);
    ALIAS ATM_ID : STD_LOGIC_VECTOR(2 downto 0) is MESSAGE_IN(13 downto 11);
    ALIAS ACCOUNT_ID : STD_LOGIC_VECTOR(4 downto 0) is MESSAGE_IN(10 downto 6);
    ALIAS ACCOUNT_PIN : STD_LOGIC_VECTOR(3 downto 0) is MESSAGE_IN(5 downto 2);
    ALIAS NOMINAL : STD_LOGIC_VECTOR(7 downto 0) is MESSAGE_IN(10 downto 3);

begin
    TRANSITION : PROCESS(CLK)
    begin
        if rising_edge(CLK) and FSM_EN = '1' then
            case STATE is
                when IDLE =>
                    if ATM_INSIDE = '1' then
                        STATE <= INPUT;
                    end if;

                when INPUT =>
                    
            end case;
        end if;
    end process TRANSITION;
    
    
end architecture rtl;