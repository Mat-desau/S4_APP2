---------------------------------------------------------------------------------------------
-- circuit mef_decod_i2s_v1b.vhd                   Version mise en oeuvre avec des compteurs
---------------------------------------------------------------------------------------------
-- Universit� de Sherbrooke - D�partement de GEGI
-- Version         : 1.0
-- Nomenclature    : 0.8 GRAMS
-- Date            : 7 mai 2019
-- Auteur(s)       : Daniel Dalle
-- Technologies    : FPGA Zynq (carte ZYBO Z7-10 ZYBO Z7-20)
--
-- Outils          : vivado 2019.1
---------------------------------------------------------------------------------------------
-- Description:
-- MEF pour decodeur I2S version 1b
-- La MEF est substituee par un compteur
--
-- notes
-- frequences (peuvent varier un peu selon les contraintes de mise en oeuvre)
-- i_lrc        ~ 48.    KHz    (~ 20.8    us)
-- d_ac_mclk,   ~ 12.288 MHz    (~ 80,715  ns) (non utilisee dans le codeur)
-- i_bclk       ~ 3,10   MHz    (~ 322,857 ns) freq mclk/4
-- La dur�e d'une p�riode reclrc est de 64,5 p�riodes de bclk ...
--
-- Revision  
-- Revision 14 mai 2019 (version ..._v1b) composants dans entit�s et fichiers distincts
---------------------------------------------------------------------------------------------
-- � faire :
--
--
---------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;  -- pour les additions dans les compteurs

entity mef_decod_i2s_v1b is
   Port ( 
   i_bclk      : in std_logic;
   i_reset     : in std_logic; 
   i_lrc       : in std_logic;
   i_cpt_bits  : in std_logic_vector(6 downto 0);
 --  
   o_bit_enable     : out std_logic ;  --
   o_load_left      : out std_logic ;  --
   o_load_right     : out std_logic ;  --
   o_str_dat        : out std_logic ;  --  
   o_cpt_bit_reset  : out std_logic   -- 
   
);
end mef_decod_i2s_v1b;

architecture Behavioral of mef_decod_i2s_v1b is
   
type fonction_etat is (
     initiale,
     compt_gauche,
     save_gauche,
     att_droite,
     compt_droite,
     save_droite,
     send
     );
     
    signal etat_present, etat_suivant: fonction_etat;    
      
begin

   -- Assignation du prochain �tat
process(i_bclk, i_reset)
    begin
       if (i_reset = '1') then
             etat_present <= initiale;
       else
           if rising_edge(i_bclk) then
                 etat_present <= etat_suivant;
           end if;
       end if;
end process;

process(etat_present, i_lrc, i_cpt_bits)
begin
    case etat_present is
        when initiale =>
            if (i_lrc = '0') then
                etat_suivant <= compt_gauche;
            else
                etat_suivant <= initiale;
            end if;
            
        when compt_gauche =>
            if (i_cpt_bits = 23) then
                etat_suivant <= save_gauche;
            else
                etat_suivant <= compt_gauche;
            end if;
        
        when save_gauche =>
            etat_suivant <= att_droite;
            
            
        when att_droite =>
            if (i_lrc = '1') then
                etat_suivant <= compt_droite;
            else
                etat_suivant <= att_droite;
            end if;

        when compt_droite =>
            if (i_cpt_bits = 23) then
                etat_suivant <= save_droite;
            else 
                etat_suivant <= compt_droite;
            end if;
         
        when save_droite =>
            etat_suivant <= send;
            
        when send =>
            etat_suivant <= initiale;            
            
    end case;
    
end process;


process(etat_present)
begin
    case etat_present is
        when initiale =>
            o_cpt_bit_reset     <= '1';
            o_load_left         <= '0';
            o_load_right        <= '0';
            o_bit_enable        <= '0';
            o_str_dat           <= '0'; 
            
        when compt_gauche =>
            o_cpt_bit_reset     <= '0';
            o_load_left         <= '0';
            o_load_right        <= '0';
            o_bit_enable        <= '1';
            o_str_dat           <= '0'; 
 
        when save_gauche =>
            o_cpt_bit_reset     <= '0';
            o_load_left         <= '1';
            o_load_right        <= '0';
            o_bit_enable        <= '0';
            o_str_dat           <= '0'; 
            
        when att_droite =>
            o_cpt_bit_reset     <= '1';
            o_load_left         <= '0';
            o_load_right        <= '0';
            o_bit_enable        <= '0';
            o_str_dat           <= '0'; 

        when compt_droite =>
            o_cpt_bit_reset     <= '0';
            o_load_left         <= '0';
            o_load_right        <= '0';
            o_bit_enable        <= '1';
            o_str_dat           <= '0';

        when save_droite =>
            o_cpt_bit_reset     <= '0';
            o_load_left         <= '0';
            o_load_right        <= '1';
            o_bit_enable        <= '0';
            o_str_dat           <= '0';
         
        when send =>
            o_cpt_bit_reset     <= '0';
            o_load_left         <= '0';
            o_load_right        <= '0';
            o_bit_enable        <= '0';
            o_str_dat           <= '1';
        
    end case;
end process;

end Behavioral;