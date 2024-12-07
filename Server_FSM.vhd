library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.Account_Record.all;

entity Server_FSM is
    port (
        CLK : IN STD_LOGIC;
        FSM_EN : IN STD_LOGIC;
        ACCOUNT_DATA : IN ACCOUNT;
        MESSAGE_IN : IN STD_LOGIC_VECTOR(15 downto 0);        

        ACCOUNT_ADDRESS_ID : OUT STD_LOGIC_VECTOR(4 downto 0);
        ACCOUNT_UPDATE : OUT ACCOUNT;
        ACCOUNT_WRITE : OUT STD_LOGIC;
        
        MESSAGE_OUT : OUT STD_LOGIC_VECTOR(15 downto 0);
        SEND_MESSAGE : OUT STD_LOGIC := '0' 
    );
end entity Server_FSM;

architecture rtl of Server_FSM is
    type StateType is (IDLE, EXECUTE, RESPONSE);
    SIGNAL STATE : StateType;

    ALIAS OPCODE : STD_LOGIC_VECTOR(1 downto 0) is MESSAGE_IN(15 downto 14);
    ALIAS ATM_ID : STD_LOGIC_VECTOR(2 downto 0) is MESSAGE_IN(13 downto 11);
    ALIAS ACCOUNT_ID : STD_LOGIC_VECTOR(4 downto 0) is MESSAGE_IN(10 downto 6);
    ALIAS ACCOUNT_PIN : STD_LOGIC_VECTOR(3 downto 0) is MESSAGE_IN(5 downto 2);
    ALIAS NOMINAL : STD_LOGIC_VECTOR(7 downto 0) is MESSAGE_IN(10 downto 3);

begin

    ACCOUNT_ADDRESS_ID <= ACCOUNT_ID; 

    TRANSITION : PROCESS(CLK)
        variable MONEY_TEMP : INTEGER := 0;
        variable RESPONSE_TYPE : STD_LOGIC := '0'; -- NAK 0, ACK 1
        variable ACCOUNT_ACTIVE : ACCOUNT := EmptyAccount;
    begin
        if rising_edge(CLK) and FSM_EN = '1' then
            case STATE is
                when IDLE =>
                    SEND_MESSAGE <= '0';
                    ACCOUNT_WRITE <= '0';
                    STATE <= EXECUTE;

                when EXECUTE =>
                    case OPCODE is
                        when "11" => -- LOGIN
                            if ACCOUNT_PIN /= ACCOUNT_DATA.PIN then
                                RESPONSE_TYPE := '0';
                            else
                                ACCOUNT_ACTIVE := ACCOUNT_DATA;
                                ACCOUNT_ACTIVE.ATM := ATM_ID;
                                RESPONSE_TYPE := '1';
                            end if;

                        when "01" => -- WITHDRAW
                            if to_integer(unsigned(ACCOUNT_ACTIVE.MONEY)) < to_integer(unsigned(NOMINAL)) or ACCOUNT_ACTIVE.ATM /= ATM_ID then
                                RESPONSE_TYPE := '0';
                            else
                                MONEY_TEMP := to_integer(unsigned(ACCOUNT_ACTIVE.MONEY)) - to_integer(unsigned(NOMINAL));
                                ACCOUNT_ACTIVE.MONEY := STD_LOGIC_VECTOR(to_unsigned(MONEY_TEMP, ACCOUNT_ACTIVE.MONEY'length));
                                RESPONSE_TYPE := '1';
                            end if;

                        when "10" => -- STORE
                            if ACCOUNT_ACTIVE.ATM /= ATM_ID then
                                RESPONSE_TYPE := '0';
                            else
                                MONEY_TEMP := to_integer(unsigned(ACCOUNT_ACTIVE.MONEY)) + to_integer(unsigned(NOMINAL));
                                ACCOUNT_ACTIVE.MONEY := STD_LOGIC_VECTOR(to_unsigned(MONEY_TEMP, ACCOUNT_ACTIVE.MONEY'length));
                                RESPONSE_TYPE := '1';
                            end if;

                        when "00" => -- LOGOUT
                            if ACCOUNT_ACTIVE.ATM /= ATM_ID then
                                RESPONSE_TYPE := '0';
                            else
                                ACCOUNT_ACTIVE.ATM := (others => '0');
                                RESPONSE_TYPE := '1';
                            end if;

                        when others =>
                            RESPONSE_TYPE := '0';
                    end case;
                    STATE <= RESPONSE;

                when RESPONSE =>
                    if RESPONSE_TYPE = '1' then -- ACK
                        MESSAGE_OUT <= '1' & ACCOUNT_ACTIVE.MONEY(14 downto 0);
                        ACCOUNT_UPDATE <= ACCOUNT_ACTIVE;
                        ACCOUNT_WRITE <= '1';
                    else    -- NAK
                        MESSAGE_OUT <= (others => '0');
                    end if;
                    SEND_MESSAGE <= '1';
                    STATE <= IDLE;

            end case;
        end if;
    end process;
    
end architecture rtl;