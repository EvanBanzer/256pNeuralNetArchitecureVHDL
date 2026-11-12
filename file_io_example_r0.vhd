-------------------------------------------------------------------------------
-- ECE 341 Fall 2026 - ANN project
-- file_io_example.vhd : HOW TO READ AND WRITE THE PROVIDED TEST FILES IN VHDL
--
-- This is NOT part of the design. It only shows the std.textio calls you need
-- in your own testbenches:
--   * read weights.txt  (one line per neuron: N_IN weights, then the bias)
--   * read inputs.txt   (one line per test input: N_IN pixels)
--   * read targets.txt  (one line per test input: N_OUT expected outputs)
--   * convert the integers to signed / unsigned std_logic_vectors
--   * write numbers to a new text file
-- Simulation only (file I/O cannot be synthesized).
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity file_io_example is
  generic (
    DIR   : string   := "data/set1_4in_1neuron/";  -- folder with the three files
    N_IN  : positive := 4;                          -- inputs per test case
    N_OUT : positive := 1;                          -- neurons
    N_IMG : positive := 5                           -- test cases (lines in inputs.txt)
  );
end entity;

architecture example of file_io_example is

  -- storage for the data read from the files
  type weight_matrix is array (0 to N_OUT-1, 0 to N_IN-1) of signed(15 downto 0);
  type bias_vector   is array (0 to N_OUT-1) of signed(15 downto 0);
  type pixel_vector  is array (0 to N_IN-1)  of unsigned(7 downto 0);
  type output_vector is array (0 to N_OUT-1) of signed(15 downto 0);

  signal weights : weight_matrix;
  signal biases  : bias_vector;

begin

  process
    file     f_w, f_in, f_tgt, f_out : text;   -- file handles
    variable l_in, l_out : line;               -- one line of text
    variable value  : integer;                 -- one number from a line
    variable pixels : pixel_vector;
    variable target : output_vector;
  begin
    ---------------------------------------------------------------------------
    -- 1. weights.txt : line j = weights of neuron j, followed by its bias
    ---------------------------------------------------------------------------
    file_open(f_w, DIR & "weights.txt", read_mode);
    for j in 0 to N_OUT-1 loop
      readline(f_w, l_in);                     -- get the next line
      for i in 0 to N_IN-1 loop
        read(l_in, value);                     -- next number on that line
        weights(j, i) <= to_signed(value, 16); -- integer -> 16-bit signed
      end loop;
      read(l_in, value);                       -- last number = bias
      biases(j) <= to_signed(value, 16);
    end loop;
    file_close(f_w);
    wait for 1 ns;                             -- let the signals update

    report "neuron 0: first weight = " & integer'image(to_integer(weights(0, 0))) &
           ", bias = " & integer'image(to_integer(biases(0)));

    ---------------------------------------------------------------------------
    -- 2. inputs.txt and targets.txt : one line per test case
    -- 3. write an output file (here: the targets again, as an example)
    ---------------------------------------------------------------------------
    file_open(f_in,  DIR & "inputs.txt",  read_mode);
    file_open(f_tgt, DIR & "targets.txt", read_mode);
    file_open(f_out, "example_output.txt", write_mode);

    for k in 0 to N_IMG-1 loop
      readline(f_in, l_in);
      for i in 0 to N_IN-1 loop
        read(l_in, value);
        pixels(i) := to_unsigned(value, 8);    -- integer -> 8-bit unsigned
      end loop;

      readline(f_tgt, l_in);
      for j in 0 to N_OUT-1 loop
        read(l_in, value);
        target(j) := to_signed(value, 16);
      end loop;

      -- (your testbench would now send 'pixels' to your design, wait for
      --  Done, and compare the design's outputs with 'target')

      report "test " & integer'image(k) &
             ": first pixel = " & integer'image(to_integer(pixels(0))) &
             ", target of neuron 0 = " & integer'image(to_integer(target(0)));

      -- write one line: test number followed by the N_OUT values
      write(l_out, k);
      for j in 0 to N_OUT-1 loop
        write(l_out, string'(" "));
        write(l_out, to_integer(target(j)));
      end loop;
      writeline(f_out, l_out);
    end loop;

    file_close(f_in);
    file_close(f_tgt);
    file_close(f_out);
    report "done - see example_output.txt";
    wait;                                      -- stop this process for good
  end process;

end architecture;
