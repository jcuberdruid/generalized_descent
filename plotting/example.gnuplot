set datafile separator ','
set title "Part 1C Error Plot: Newton Method Informed Descent 𝛄 = 2 (Not Log Scale)"
set xlabel "Iteration"
set ylabel "f(x^k) - p*, p* = 0.0"

#set logscale y
set terminal pngcairo enhanced size 800,600
set output 'newton_method_results_gamma_2.0.png' 

plot '../newton_method_results_gamma_2.0.csv' using 1:($4 - 0.0) with linespoints linewidth 2 pointtype 7 pointsize 1.5 title 'Error'

set output
