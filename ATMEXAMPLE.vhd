library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ATM is
    Port (
        clk      : in  STD_LOGIC;
        rst      : in  STD_LOGIC;
        id       : in  INTEGER range 0 to 99;
        pin      : in  INTEGER range 0 to 9999;
        amount   : in  INTEGER;
        spi_out  : out STD_LOGIC_VECTOR(7 downto 0);
        spi_done : out STD_LOGIC
    );
end ATM;

architecture Behavioral of ATM is
    type state_type is (IDLE, LOGIN, TRANSACT, LOGOUT);
    signal current_state, next_state : state_type;
    signal opcode : STD_LOGIC_VECTOR(7 downto 0);
begin
    process (clk, rst)
    begin
        if rst = '1' then
            current_state <= IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    process (current_state, id, pin, amount)
    begin
        case current_state is
            when IDLE =>
                opcode <= "00000000"; -- No operation
                spi_done <= '0';
                if id /= 0 and pin /= 0 then
                    next_state <= LOGIN;
                else
                    next_state <= IDLE;
                end if;

            when LOGIN =>
                opcode <= "00000001"; -- LOGIN opcode
                spi_done <= '1';
                next_state <= TRANSACT;

            when TRANSACT =>
                if amount > 0 then
                    opcode <= "00000010"; -- DEPOSIT opcode
                else
                    opcode <= "00000011"; -- WITHDRAW opcode
                end if;
                spi_done <= '1';
                next_state <= LOGOUT;

            when LOGOUT =>
                opcode <= "00000100"; -- LOGOUT opcode
                spi_done <= '1';
                next_state <= IDLE;

            when others =>
                next_state <= IDLE;
        end case;
    end process;

    spi_out <= opcode;

end Behavioral;
